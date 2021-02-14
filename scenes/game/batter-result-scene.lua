--------------------------------------------------------------------
-- batter-result-scene.lua is the view layer
-- for displaying the result of a pitch
--------------------------------------------------------------------

-- Public imports
local composer = require("composer")
local widget = require("widget")

-- Local imports
local assetUtil = require("scenes.game.utilities.asset-util")
local constants = require("scenes.game.utilities.constants")
local scoreboard = require("scenes.game.widgets.scoreboard")
local inningTracker = require("scenes.game.widgets.inning-tracker")

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = constants.SCENE_NAME_BATTER_RESULT
local sceneGroup

-- Services
local viewManager
local batterManager

-- Local functions
local onNextPitch
local onNextBatter
local renderCurrentBatter
local renderCurrentPitcher
local renderBackground
local renderZoneActionCard
local renderPitchActionCard
local renderResult

-- Local variables

-- -----------------------------------------------------------------------------------
-- Scene event lifecycle functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
  sceneGroup = self.view
  viewManager = composer.getVariable("viewManager")
  batterManager = composer.getVariable("batterManager")

  viewManager:registerScene(SCENE_NAME)
end

function scene:show(event)
  local phase = event.phase

  if (phase == "will") then
    renderBackground()
    renderNextButton()
    scoreboard(sceneGroup, SCENE_NAME)
    inningTracker(sceneGroup, SCENE_NAME)
    renderCurrentBatter()
    renderCurrentPitcher()
    renderZoneActionCard()
    renderPitchActionCard()
    renderResult()
  end

  function scene:hide(event)
    local phase = event.phase

    if (phase == "did") then
      viewManager:removeComponents(SCENE_NAME)
    end
  end
end

function scene:destroy(event)
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Callback functions
-- -----------------------------------------------------------------------------------

function onNextPitch()
  batterManager:updateGameState(constants.ACTION_BATTER_NEXT_PITCH)
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
end

function onNextBatter()
  batterManager:updateGameState(constants.ACTION_BATTER_NEXT_BATTER)
  composer.gotoScene("scenes.game.batter-athlete-selection-scene")
end

-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

function renderBackground()
  -- Background
  viewManager:addComponent(
    SCENE_NAME,
    "BACKGROUND_FIELD",
    (function()
      local background =
        display.newImageRect(
        sceneGroup,
        assetUtil.resolveAssetPath("field.png"),
        display.actualContentWidth,
        display.actualContentHeight
      )
      background.anchorX = 0
      background.anchorY = 0
      background.x = display.screenOriginX
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "IMAGE_BALL_TRAIL",
    (function()
      local ball = display.newImageRect(sceneGroup, assetUtil.resolveAssetPath("batted-ball-trail.png"), 370, 200)
      ball.anchorX = 0
      ball.anchorY = 1
      ball.x = 216
      ball.y = display.contentHeight - 80
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "IMAGE_BALL",
    (function()
      local ball = display.newImageRect(sceneGroup, assetUtil.resolveAssetPath("batted-ball.png"), 30, 30)
      ball.anchorX = 0
      ball.anchorY = 0
      ball.x = 200
      ball.y = display.contentHeight - 100
    end)()
  )
end

function renderNextButton()
  if (batterManager:getState() == constants.STATE_BATTER_RESULT) then
    if (batterManager:getIsNextAtBat()) then
      -- Next batter button
      viewManager:addComponent(
        SCENE_NAME,
        "NEXT_BATTER",
        (function()
          local nextBatterButton =
            widget.newButton {
            label = "Next batter",
            labelColor = {default = {1.0}, over = {0.5}},
            shape = "roundedRect",
            fillColor = {default = {0, 0.5, 1, 0.7}, over = {0, 0.5, 1, 1}},
            width = 100,
            height = 40,
            onRelease = onNextBatter
          }
          nextBatterButton.anchorY = 1
          nextBatterButton.x = display.contentCenterX
          nextBatterButton.y = display.contentHeight - 30
          sceneGroup:insert(nextBatterButton)
          return nextBatterButton
        end)()
      )
    else
      -- Next pitch button
      viewManager:addComponent(
        SCENE_NAME,
        "NEXT_PITCH",
        (function()
          local nextPitchButton =
            widget.newButton {
            label = "Next pitch",
            labelColor = {default = {1.0}, over = {0.5}},
            shape = "roundedRect",
            fillColor = {default = {0, 0.5, 1, 0.7}, over = {0, 0.5, 1, 1}},
            width = 100,
            height = 40,
            onRelease = onNextPitch
          }
          nextPitchButton.anchorY = 1
          nextPitchButton.x = display.contentCenterX
          nextPitchButton.y = display.contentHeight - 30
          sceneGroup:insert(nextPitchButton)
          return nextPitchButton
        end)()
      )
    end
  end
end

function renderCurrentBatter()
  local batter = batterManager:getDataStore():getBatter()
  local currentBatterView =
    viewManager:addComponent(
    SCENE_NAME,
    "CURRENT_BATTER_CARD",
    (function()
      local currentBatterView =
        widget.newButton {
        font = "asul.ttf",
        defaultFile = assetUtil.resolveAssetPath(batter:getPictureURL()),
        width = 130,
        height = 182,
        onPress = onCurrentBatterZoom
      }
      currentBatterView.anchorX = 0
      currentBatterView.anchorY = 1
      currentBatterView.x = 20
      currentBatterView.y = display.contentHeight - 20
      sceneGroup:insert(currentBatterView)
      return currentBatterView
    end)()
  )
end

function renderCurrentPitcher()
  local pitcher = batterManager:getDataStore():getPitcher()
  local currentPitcherView =
    viewManager:addComponent(
    SCENE_NAME,
    "CURRENT_PITCHER_CARD",
    (function()
      local currentPitcherView =
        widget.newButton {
        font = "asul.ttf",
        defaultFile = assetUtil.resolveAssetPath(pitcher:getPictureURL()),
        width = 130,
        height = 182,
        onPress = onCurrentBatterZoom
      }
      currentPitcherView.anchorX = 1
      currentPitcherView.anchorY = 1
      currentPitcherView.x = display.contentWidth - 20
      currentPitcherView.y = display.contentHeight - 20
      sceneGroup:insert(currentPitcherView)
      return currentPitcherView
    end)()
  )
end

-- Displays the action card that was selected by the pitcher's zone
function renderZoneActionCard()
  local group = display.newGroup()
  sceneGroup:insert(group)

  local selectedCardZone = batterManager:getDataStore():getPitcherSelectedZone()
  if (selectedCardZone == nil or selectedCardZone == 0) then
    -- Pitcher did not select a zone to throw to
    error("pitcher missing zone to throw to")
  end

  -- Grab the action card from the batter's active deck since the pitcher is choosing one of the batter's zones
  local getInPlayBatterActionCardsMap = batterManager:getDataStore():getInPlayBatterActionCardsMap()
  if (getInPlayBatterActionCardsMap == nil) then
    error("batter cards not assigned")
  end

  local actionCardID = getInPlayBatterActionCardsMap[selectedCardZone]
  if (actionCardID == nil) then
    error("invalid zone card selected by the pitcher")
  end

  local card = batterManager:getDataStore():getBatterActionCards()[actionCardID]
  if (card == nil) then
    error("action card not available in the batter's deck")
  end

  -- Show the result of the pitch
  local _, batterRoll = batterManager:getDataStore():getLastRolls()

  viewManager:addComponent(
    SCENE_NAME,
    "CURRENT_ZONE_ACTION_CARD",
    (function()
      local cardView =
        widget.newButton {
        font = "asul.ttf",
        label = "Zone " .. selectedCardZone,
        labelYOffset = 50,
        defaultFile = assetUtil.resolveAssetPath(card:getBattingAction():getPictureURL()),
        width = 130,
        height = 182
      }
      cardView.anchorX = 0
      cardView.x = 160
      cardView.y = display.contentCenterY
      cardView:setFillColor(0.5)
      group:insert(cardView)
      return cardView
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "BATTER_ROLL",
    (function()
      local rollView =
        widget.newButton {
        font = "asul.ttf",
        label = batterRoll,
        labelColor = {default = {1.0}, over = {0.5}},
        width = 50,
        height = 50,
        shape = "roundedRect",
        cornerRadius = "50",
        fillColor = {default = {1, 0.2, 0.5, 0.9}, over = {1, 0.2, 0.5, 1}}
      }
      rollView.anchorX = 0
      rollView.x = (160 + 40)
      rollView.y = display.contentCenterY
      group:insert(rollView)
      return rollView
    end)()
  )
end

-- Displays the action card that was selected by the batters's zone
function renderPitchActionCard()
  local group = display.newGroup()
  sceneGroup:insert(group)

  local selectedCardPitch = batterManager:getDataStore():getPitcherSelectedPitch()
  if (selectedCardPitch == nil or selectedCardPitch == 0) then
    -- Pitcher did not select a zone to throw to
    error("pitcher missing pitch to throw to")
  end

  -- Grab the action card from the pitchers's active deck since the pitcher is choosing one of their own pitch's zones
  local inPlayPitcherActionCardsMap = batterManager:getDataStore():getInPlayPitcherActionCardsMap()
  if (inPlayPitcherActionCardsMap == nil) then
    error("pitcher cards not assigned")
  end

  local actionCardID = inPlayPitcherActionCardsMap[selectedCardPitch]
  if (actionCardID == nil) then
    error("invalid pitch card selected by the pitcher")
  end

  local card = batterManager:getDataStore():getPitcherActionCards()[actionCardID]
  if (card == nil) then
    error("action card not available in the pitcher's deck")
  end

  -- Show the result of the pitch
  local pitcherRoll, _ = batterManager:getDataStore():getLastRolls()

  viewManager:addComponent(
    SCENE_NAME,
    "CURRENT_PITCH_ACTION_CARD",
    (function()
      local cardView =
        widget.newButton {
        font = "asul.ttf",
        label = "Pitch " .. selectedCardPitch,
        labelYOffset = 50,
        defaultFile = assetUtil.resolveAssetPath(card:getPitchingAction():getPictureURL()),
        width = 130,
        height = 182
      }
      cardView.anchorX = 1
      cardView.x = display.contentWidth - 160
      cardView.y = display.contentCenterY
      cardView:setFillColor(0.5)
      group:insert(cardView)
      return cardView
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "PITCHER_ROLL",
    (function()
      local rollView =
        widget.newButton {
        label = pitcherRoll,
        labelColor = {default = {1.0}, over = {0.5}},
        width = 50,
        height = 50,
        shape = "roundedRect",
        cornerRadius = "50",
        font = "asul.ttf",
        fillColor = {default = {1, 0.2, 0.5, 0.9}, over = {1, 0.2, 0.5, 1}}
      }
      rollView.anchorX = 1
      rollView.x = display.contentWidth - (160 + 40)
      rollView.y = display.contentCenterY
      group:insert(rollView)
      return rollView
    end)()
  )
end

function renderResult()
  local result = batterManager:getDataStore():getPitchResultState()
  viewManager:addComponent(
    SCENE_NAME,
    "TEXT_RESULT",
    (function()
      local resultView =
        widget.newButton {
        label = result .. "!",
        labelColor = {default = {1.0}, over = {0.5}},
        font = "asul.ttf",
        width = 200,
        height = 40,
        shape = "roundedRect",
        cornerRadius = "5",
        fillColor = {default = {0.5, 0.7}, over = {0.5, 0.7}}
      }
      resultView.anchorY = 0
      resultView.x = display.contentCenterX
      resultView.y = 40
      sceneGroup:insert(resultView)
      return resultView
    end)()
  )
end

return scene
