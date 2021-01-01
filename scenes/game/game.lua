-----------------------------------------------------------------------------------------
--
-- game.lua
-- This file runs a game between two players
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")

-- DI modules
local resolverManagerModule = require("scenes.game.resolver-manager")
local batterManagerModule = require("scenes.game.batter-manager")
local inningManagerModule = require("scenes.game.inning-manager")
local viewManagerModule = require("scenes.game.view-manager")

-- Static data
local constants = require("scenes.game.constants")
local mockData = require("scenes.game.mock-data")

-- Initialize scene variables
local scene = composer.newScene()

-- Constant for root path to local asset folder
local ASSET_PATH = "scenes/game/assets/"
local function resolveAssetPath(fileName)
  return ASSET_PATH .. fileName
end

-- Local function declarations
local initializeSceneView
local updateSceneUI
local clearMatchup

-- -----------------------------------------------------------------------------------
-- Initialize scene
-- -----------------------------------------------------------------------------------

local sceneGroup
local viewManager
local resolverManager
local batterManager
local inningManager

-- create() is executed on first load and runs only once (initialize values here)
function scene:create(event)
  sceneGroup = self.view
  viewManager = viewManagerModule:new()
  resolverManager = resolverManagerModule:new({balls = 0, strikes = 0})
  batterManager = batterManagerModule:new({resolverManager = resolverManager})
  inningManager =
    inningManagerModule:new(
    {
      inning = 1,
      outs = 0,
      runs = 0,
      bases = {nil, nil, nil},
      batterIndex = 1,
      pitcherIndex = 1,
      pitchingStaff = mockData.pitchingStaff,
      battingLineup = mockData.battingLineup
    }
  )

  composer.setVariable("viewManager", viewManager)
  composer.setVariable("batterManager", batterManager)
  composer.setVariable("inningManager", inningManager)

  initializeSceneView()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function onThrowPitch()
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
end

-- -----------------------------------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------------------------------

function getActionAndParamFromResolveState(resultState)
  local action
  local params
  if
    (resultState == constants.SINGLE or resultState == constants.DOUBLE or resultState == constants.TRIPLE or
      resultState == constants.HOME_RUN)
   then
    action = constants.ACTION_HIT
    params = {type = resultState}
  elseif (resultState == constants.OUT) then
    -- TODO choose batter and pitcher by user?
    action = constants.ACTION_OUT
    params = {batterIndex = 0, pitcherIndex = 0}
  elseif (resultState == constants.FOUL) then
    action = constants.action_FOUL
  end
  return action, params
end

-- -----------------------------------------------------------------------------------
-- UI instantions and updates
-- -----------------------------------------------------------------------------------

function initializeSceneView()
  -- Add background field
  viewManager:addComponent(
    "BACKGROUND_FIELD",
    (function()
      local backgroundField = display.newImageRect(sceneGroup, resolveAssetPath("baseball-field.jpg"), 320, 480)
      backgroundField.x = display.contentCenterX
      backgroundField.y = display.contentCenterY
      return backgroundField
    end)()
  )

  -- Create resolve button to resolve pitch
  viewManager:addComponent(
    "BUTTON_THROW_PITCH",
    (function()
      local throwPitchButton =
        widget.newButton {
        label = "Throw pitch",
        labelColor = {default = {1.0}, over = {0.5}},
        defaultFile = resolveAssetPath("button.png"),
        overFile = resolveAssetPath("button-over.png"),
        width = 154,
        height = 40,
        onRelease = onThrowPitch
      }
      throwPitchButton.x = display.contentCenterX
      throwPitchButton.y = display.contentHeight - 50
      return throwPitchButton
    end)()
  )

  -- On initialization, just set the pitcher and batter roll to -1 for the time being
  updateSceneUI(-1, -1)
end

-- Cleanup previous state
function clearMatchup()
  viewManager:removeComponents(
    {
      "TEXT_PITCH_RESULT",
      "TEXT_SCORE",
      "CARD_PITCHER",
      "TEXT_PITCHER_NAME",
      "TEXT_PITCHER_SKILL_RANGE",
      "CARD_BATTER",
      "TEXT_BATTER_NAME",
      "TEXT_BATTER_SKILL_RANGE"
    }
  )
end

function updateSceneUI(batterRoll, pitcherRoll)
  local pitcher = inningManager:getCurrentPitcher()
  local batter = inningManager:getCurrentBatter()

  -- Add result
  viewManager:addComponent(
    "TEXT_PITCH_RESULT",
    (function()
      local resultText =
        display.newText(
        sceneGroup,
        "Result: " .. batterManager:getState() .. " (" .. batterRoll - pitcherRoll .. ")",
        400,
        80,
        native.systemFont,
        24
      )
      resultText.x = display.contentCenterX
      resultText.y = display.contentCenterY
      resultText:setFillColor(1, 0, 0)
      return resultText
    end)()
  )

  -- Add score
  viewManager:addComponent(
    "TEXT_SCORE",
    (function()
      local scoreText =
        display.newText(
        sceneGroup,
        "Runs this inning: " .. inningManager:getRuns() .. " Outs: " .. inningManager:getOuts(),
        400,
        80,
        native.systemFont,
        24
      )
      scoreText.x = display.contentCenterX
      scoreText.y = 20
      scoreText:setFillColor(1, 0, 1)
      return scoreText
    end)()
  )

  -- Add pitcher card
  viewManager:addComponent(
    "CARD_PITCHER",
    (function()
      local pitcherImg = display.newImageRect(sceneGroup, resolveAssetPath(pitcher:getPictureURL()), 90, 90)
      pitcherImg.x = 30
      pitcherImg.y = display.contentCenterY
      return pitcherImg
    end)()
  )

  -- Add pitcher name
  viewManager:addComponent(
    "TEXT_PITCHER_NAME",
    (function()
      local pitcherName =
        display.newText(sceneGroup, pitcher:getName() .. " roll: " .. pitcherRoll, 100, 200, native.systemFont, 16)
      pitcherName.x = 30
      pitcherName.y = display.contentCenterY - 60
      pitcherName:setFillColor(1, 0, 0.5)
      return pitcherName
    end)()
  )

  -- Add pitcher skill
  viewManager:addComponent(
    "TEXT_PITCHER_SKILL_RANGE",
    (function()
      local pitcherSkill =
        display.newText(
        sceneGroup,
        "floor: " .. pitcher:getSkill():getFloor() .. ", ceiling: " .. pitcher:getSkill():getCeiling(),
        100,
        200,
        native.systemFont,
        16
      )
      pitcherSkill.x = 30
      pitcherSkill.y = display.contentCenterY + 60
      pitcherSkill:setFillColor(1, 0, 0.5)
      return pitcherSkill
    end)()
  )

  -- Add batter card
  viewManager:addComponent(
    "CARD_BATTER",
    (function()
      local batterImg = display.newImageRect(sceneGroup, resolveAssetPath(batter:getPictureURL()), 90, 90)
      batterImg.x = display.contentWidth - 30
      batterImg.y = display.contentCenterY
      return batterImg
    end)()
  )

  -- Add batter name
  viewManager:addComponent(
    "TEXT_BATTER_NAME",
    (function()
      local batterName =
        display.newText(sceneGroup, batter:getName() .. " roll: " .. batterRoll, 100, 200, native.systemFont, 16)
      batterName.x = display.contentWidth - 30
      batterName.y = display.contentCenterY - 60
      batterName:setFillColor(1, 0, 0.5)
      return batterName
    end)()
  )

  -- Add batter skill
  viewManager:addComponent(
    "TEXT_BATTER_SKILL_RANGE",
    (function()
      local batterSkill =
        display.newText(
        sceneGroup,
        "floor: " .. batter:getSkill():getFloor() .. ", ceiling: " .. batter:getSkill():getCeiling(),
        100,
        200,
        native.systemFont,
        16
      )
      batterSkill.x = display.contentWidth - 30
      batterSkill.y = display.contentCenterY + 60
      batterSkill:setFillColor(1, 0, 0.5)
      return batterSkill
    end)()
  )
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == "did" then
    -- Widgets must be manually removed
    viewManager:removeComponents(
      {
        "BUTTON_THROW_PITCH"
      }
    )
  -- Called when the scene is now off screen
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  if viewManager.get("BUTTON_THROW_PITCH") then
    -- Widgets must be manually removed
    viewManager:removeComponents(
      {
        "BUTTON_THROW_PITCH"
      }
    )
  end
end

---------------------------------------------------------------------------------

-- Listener setup (default Solar2D events)
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

return scene
