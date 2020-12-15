-----------------------------------------------------------------------------------------
--
-- game.lua
-- This file runs a game between two players
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require "widget"

local athleteCard = require("scenes.game.entities.athlete-card")
local skill = require("scenes.game.entities.skill")
local atBatManagerModule = require("scenes.game.at-bat-manager")
local inningManagerModule = require("scenes.game.inning-manager")
local constants = require("scenes.game.constants")

-- Initialize scene variables
local scene = composer.newScene()

-- Local variables (TODO: move to state table)
local pitchingStaff = {
  athleteCard:new(
    {
      id = "0",
      name = "Kronos",
      pictureURL = "kronos.jpg",
      positions = {"p", "ss"},
      skill = skill:new({floor = 0, ceiling = 100})
    }
  )
}

local battingLineup = {
  athleteCard:new(
    {
      id = "1",
      name = "Zeus",
      pictureURL = "zeus.jpg",
      positions = {"p", "2b"},
      skill = skill:new({floor = 30, ceiling = 70})
    }
  ),
  athleteCard:new(
    {
      id = "2",
      name = "Poseidon",
      pictureURL = "poseidon.jpg",
      positions = {"p", "2b"},
      skill = skill:new({floor = 30, ceiling = 70})
    }
  ),
  athleteCard:new(
    {
      id = "3",
      name = "Hades",
      pictureURL = "hades.jpg",
      positions = {"p", "2b"},
      skill = skill:new({floor = 30, ceiling = 70})
    }
  )
}

local resolveButton
local resultText
local scoreText
local pitcherImg
local pitcherName
local batterImg
local batterName

local atBatManager = atBatManagerModule:new({balls = 0, strikes = 0})
local inningManager =
  inningManagerModule:new(
  {
    inning = 1,
    outs = 0,
    runs = 0,
    bases = {nil, nil, nil},
    batterIndex = 1,
    pitcherIndex = 1,
    pitchingStaff = pitchingStaff,
    battingLineup = battingLineup
  }
)

-- -----------------------------------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------------------------------

-- Constant for root path to local asset folder
local ASSET_PATH = "scenes/game/assets/"
local function resolveAssetPath(fileName)
  return ASSET_PATH .. fileName
end

-- Cleanup previous state
local function clearMatchup()
  display.remove(resultText)
  display.remove(scoreText)
  display.remove(pitcherImg)
  display.remove(pitcherName)
  display.remove(batterImg)
  display.remove(batterName)
  scoreText = nil
  resultText = nil
  pitcherImg = nil
  pitcherName = nil
  batterImg = nil
  batterName = nil
end

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
-- Scene event functions
-- -----------------------------------------------------------------------------------

function onResolveButtonRelease()
  clearMatchup()

  local pitcher = inningManager:getCurrentPitcher()
  local batter = inningManager:getCurrentBatter()
  local resultState, pitcherRoll, batterRoll = atBatManager:throwPitch(pitcher, batter)
  local action, params = getActionAndParamFromResolveState(resultState)
  local inningState = inningManager:updateGameState(action, params)
  if (inningState == constants.STATE_INNING_END) then
    -- TODO: for now, just remove button to symbolize inning over
    display.remove(resolveButton)
    resolveButton = nil
  elseif (inningState == constants.STATE_AT_BAT_END) then
    -- TODO: logic if the at bat has ended
  elseif (inningState == constants.STATE_AT_BAT_ONGOING) then
  -- TODO: logic if the at bat is still going on
  end

  -- Testing logs
  print("Result log:")
  print(pitcherRoll)
  print(batterRoll)
  print("Inning state: " .. inningManager:getState())
  print("Result state: " .. resultState)
  print("Runs: " .. inningManager:getRuns())
  print("Outs: " .. inningManager:getOuts())
  print("Inning: " .. inningManager:getInning())
  print("---------")

  ----------------
  -- TODO: move this out, we should have UI managed separately from core logic
  ----------------
  -- Add result
  resultText =
    display.newText(
    "Result: " .. resultState .. " (" .. batterRoll - pitcherRoll .. ")",
    400,
    80,
    native.systemFont,
    24
  )
  resultText.x = display.contentCenterX
  resultText.y = display.contentCenterY
  resultText:setFillColor(1, 0, 0)

  -- Add score
  scoreText =
    display.newText(
    "Runs this inning: " .. inningManager:getRuns() .. " Outs: " .. inningManager:getOuts(),
    400,
    80,
    native.systemFont,
    24
  )
  scoreText.x = display.contentCenterX
  scoreText.y = 20
  scoreText:setFillColor(1, 0, 1)

  -- Add pitcher
  pitcherImg = display.newImageRect(resolveAssetPath(pitcher:getPictureURL()), 90, 90)
  pitcherImg.x = 30
  pitcherImg.y = display.contentCenterY

  pitcherName = display.newText(pitcher:getName() .. " roll: " .. pitcherRoll, 100, 200, native.systemFont, 16)
  pitcherName.x = 30
  pitcherName.y = display.contentCenterY - 60
  pitcherName:setFillColor(1, 0, 0.5)

  -- Add batter
  batterImg = display.newImageRect(resolveAssetPath(batter:getPictureURL()), 90, 90)
  batterImg.x = display.contentWidth - 30
  batterImg.y = display.contentCenterY

  batterName = display.newText(batter:getName() .. " roll: " .. batterRoll, 100, 200, native.systemFont, 16)
  batterName.x = display.contentWidth - 30
  batterName.y = display.contentCenterY - 60
  batterName:setFillColor(1, 0, 0.5)
end

-- create()
function scene:create(event)
  local sceneGroup = self.view

  -- Add background
  local background = display.newImageRect(sceneGroup, resolveAssetPath("baseball-field.jpg"), 320, 480)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  -- Create resolve button to resolve pitch
  resolveButton =
    widget.newButton {
    label = "Throw pitch",
    labelColor = {default = {1.0}, over = {0.5}},
    defaultFile = resolveAssetPath("button.png"),
    overFile = resolveAssetPath("button-over.png"),
    width = 154,
    height = 40,
    onRelease = onResolveButtonRelease
  }
  resolveButton.x = display.contentCenterX
  resolveButton.y = display.contentHeight - 50
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

return scene
