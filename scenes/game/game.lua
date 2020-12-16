-----------------------------------------------------------------------------------------
--
-- game.lua
-- This file runs a game between two players
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require "widget"

-- DI modules
local atBatManagerModule = require("scenes.game.at-bat-manager")
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
local atBatManager
local inningManager

-- create() is executed on first load and runs only once (initialize values here)
function scene:create(event)
  sceneGroup = self.view
  viewManager = viewManagerModule:new()
  atBatManager = atBatManagerModule:new({balls = 0, strikes = 0})
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

  initializeSceneView()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function onThrowPitch()
  -- Reset matchup UI
  clearMatchup()

  -- Throw the pitch and retrieve result of pitch
  local resultState, pitcherRoll, batterRoll =
    atBatManager:throwPitch(inningManager:getCurrentPitcher(), inningManager:getCurrentBatter())

  -- Update the inning game state with the result of the pitch
  local action, params = getActionAndParamFromResolveState(resultState)
  local inningState = inningManager:updateGameState(action, params)

  -- Testing logs
  print("Result log:")
  print("Pitcher roll: " .. pitcherRoll)
  print("Batter roll: " .. batterRoll)
  print("Inning state: " .. inningManager:getState())
  print("Result state: " .. resultState)
  print("Runs: " .. inningManager:getRuns())
  print("Outs: " .. inningManager:getOuts())
  print("Inning: " .. inningManager:getInning())
  print("---------")

  -- Update UI based on the new state
  if (inningState == constants.STATE_INNING_END) then
    -- TODO: for now, just remove button to symbolize inning over
    viewManager:removeComponents({"BUTTON_THROW_PITCH"})
  elseif (inningState == constants.STATE_AT_BAT_END) then
    -- TODO: logic if the at bat has ended
  elseif (inningState == constants.STATE_AT_BAT_ONGOING) then
  -- TODO: logic if the at bat is still going on
  end

  updateSceneUI(batterRoll, pitcherRoll)
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
      "CARD_BATTER",
      "TEXT_BATTER_NAME"
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
        "Result: " .. atBatManager:getState() .. " (" .. batterRoll - pitcherRoll .. ")",
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
      local batterName = display.newText(batter:getName() .. " roll: " .. batterRoll, 100, 200, native.systemFont, 16)
      batterName.x = display.contentWidth - 30
      batterName.y = display.contentCenterY - 60
      batterName:setFillColor(1, 0, 0.5)
      return batterName
    end)()
  )
end

---------------------------------------------------------------------------------

-- Listener setup (default Solar2D events)
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

return scene
