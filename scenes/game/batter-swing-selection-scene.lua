--------------------------------------------------------------------
-- batter-swing-selection-scene.lua is the view layer
-- for selecting where the batter wants to take their swing
--------------------------------------------------------------------

-- Public imports
local composer = require("composer")
local widget = require("widget")

-- Local imports
local assetUtil = require("scenes.game.utilities.asset-util")
local constants = require("scenes.game.utilities.constants")
local eventHandlers = require("scenes.game.utilities.event-handlers")
local modals = require("scenes.game.utilities.modals")

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = constants.SCENE_NAME_BATTER_SWING_SELECTION
local sceneGroup

-- Services
local viewManager
local batterManager

-- Local functions
local onGuessZone
local onGuessPitch
local renderMatchup
local renderBackground
local renderZoneGuessSelection
local renderPitchGuessSelection
local renderStatus
local getPitchByID
local getActionCardByPitchID

-- Local variables
local guessedPitch = 0
local guessedZone = 0

-- -----------------------------------------------------------------------------------
-- Scene event lifecycle functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
  sceneGroup = self.view

  -- Retrieve DI instances of the managers
  viewManager = composer.getVariable("viewManager")
  batterManager = composer.getVariable("batterManager")

  -- Register scene domain into the ViewManager
  viewManager:registerScene(SCENE_NAME)
end

function scene:show(event)
  local phase = event.phase

  if (phase == "will") then
    renderBackground()
    renderZoneGuessSelection()
    renderPitchGuessSelection()
    renderConfirmButton()
    renderMatchup()
  end
end

function scene:hide(event)
  local phase = event.phase

  if (phase == "did") then
    viewManager:removeComponents(SCENE_NAME)
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

function onGuessZone(event, zone)
  local tapFunction = function()
    guessedZone = zone
    renderStatus()
    renderZoneGuessSelection()
  end

  local holdFunction = function()
  end

  eventHandlers.onUserActionEvent(event, {hold = holdFunction, tap = tapFunction}, {})
end

function onGuessPitch(event, pitchID)
  local tapFunction = function()
    guessedPitch = pitchID
    renderStatus()
    renderPitchGuessSelection()
  end

  local holdFunction = function()
    local card = getActionCardByPitchID(pitchID)
    if (card == nil) then
      return
    end
    modals.showCardModal(card, card:getPitchingAction():getPictureURL())
  end

  eventHandlers.onUserActionEvent(event, {hold = holdFunction, tap = tapFunction}, {})
end

function onConfirm()
  local newState =
    batterManager:updateGameState(
    constants.ACTION_BATTER_SELECT_ZONE,
    {guessedZone = guessedZone, guessedPitch = guessedPitch}
  )
  -- In multiplayer, this should be triggered automatically when both players have finished their selections
  newState = batterManager:updateGameState(constants.ACTION_BATTER_RESOLVE_PITCH)

  -- Execute the pitch
  composer.gotoScene("scenes.game.batter-result-scene")
end

-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

function renderBackground()
  -- Background
  viewManager:addComponent(
    SCENE_NAME,
    "TEXT_BUILD_STRIKE_ZONE",
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
end

function renderConfirmButton()
  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_CONFIRM_GUESSES",
    (function()
      local confirmGuessButton =
        widget.newButton {
        label = "Confirm swing",
        labelColor = {default = {1.0}, over = {0.5}},
        width = 150,
        height = 50,
        shape = "roundedRect",
        fillColor = {default = {1, 0.2, 0.1, 0.7}, over = {1, 0.2, 0.5, 1}},
        onRelease = function()
          onConfirm()
        end
      }
      confirmGuessButton.x = display.contentWidth - 100
      confirmGuessButton.y = 300
      sceneGroup:insert(confirmGuessButton)
      return confirmGuessButton
    end)()
  )
end

function renderPitchGuessSelection()
  local group = display.newGroup()

  local pitchCardsMap = batterManager:getDataStore():getInPlayPitcherActionCardsMap()
  local index = 1
  for pitchID, actionCardID in pairs(pitchCardsMap) do
    -- Get pitch information
    local pitch = getPitchByID(pitchID)
    -- Get action card information
    local pitcherActionCard = getActionCardByPitchID(pitchID)
    if (pitcherActionCard == nil) then
      error("pitch action card not assigned to pitch: " .. pitchID)
      return
    end

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_GUESS_PITCH_CARD_" .. pitch:getID(),
      (function()
        local guessPitchButton =
          widget.newButton {
          width = 50,
          height = 70,
          label = pitch:getID(),
          defaultFile = assetUtil.resolveAssetPath(pitcherActionCard:getPitchingAction():getPictureURL()),
          onEvent = function(event)
            onGuessPitch(event, pitch:getID())
          end
        }
        guessPitchButton.anchorX = 1
        guessPitchButton.anchorY = 0
        guessPitchButton.x = display.contentWidth - 150
        guessPitchButton.y = 10 + (index - 1) * 85

        -- Apply highlight to the card if selected
        if (guessedPitch == pitch:getID()) then
          guessPitchButton:setFillColor(1, 0.75, 0, 1)
        end
        group:insert(guessPitchButton)
        return guessPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_GUESS_PITCH_ICON_" .. pitch:getID(),
      (function()
        local guessPitchIconButton =
          widget.newButton {
          label = pitch:getAbbreviation(),
          labelColor = {default = {1.0}, over = {0.5}},
          width = 30,
          height = 30,
          shape = "roundedRect",
          cornerRadius = "50",
          fillColor = {default = {1, 0.2, 0.5, 0.7}, over = {1, 0.2, 0.5, 1}},
          onEvent = function(event)
            onGuessPitch(event, pitch:getID())
          end
        }
        guessPitchIconButton.anchorX = 1
        guessPitchIconButton.anchorY = 0
        guessPitchIconButton.x = display.contentWidth - 140
        guessPitchIconButton.y = 60 + (index - 1) * 85
        group:insert(guessPitchIconButton)
        return guessPitchIconButton
      end)()
    )
    index = index + 1
  end

  sceneGroup:insert(group)
end

function renderZoneGuessSelection()
  local group = display.newGroup()

  -- Create resolve button to resolve pitch
  for i = 1, 4 do
    local cardText = i

    local zoneButtonSettings = {
      width = 67,
      height = 91,
      font = "asul.ttf",
      defaultFile = assetUtil.resolveAssetPath("action_card_sample.png"),
      label = cardText,
      labelColor = {default = {1.0}, over = {0.5}},
      onRelease = function(event)
        onGuessZone(event, i)
      end
    }

    -- Strike zone
    local zoneButton =
      viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_GUESS_ZONE_" .. i,
      (function()
        local zoneButton = widget.newButton(zoneButtonSettings)
        if (guessedZone == i) then
          zoneButton:setFillColor(1, 0.75, 0, 1)
        end
        return zoneButton
      end)()
    )
    group:insert(zoneButton)

    -- Divide into top row and bottom row
    zoneButton.x = 70 * ((i - 1) % 2)
    if (i < 3) then
      zoneButton.y = 34
    else
      zoneButton.y = 128
    end

    group.x = 240
    group.y = display.contentHeight - 214
  end

  sceneGroup:insert(group)
end

function renderMatchup()
  local batter = batterManager:getDataStore():getBatter()
  viewManager:addComponent(
    SCENE_NAME,
    "CARD_ACTIVE_BATTER",
    (function()
      local batterImg =
        widget.newButton(
        {
          defaultFile = assetUtil.resolveAssetPath(batter:getPictureURL()),
          width = 150,
          height = 210
        }
      )
      batterImg.anchorX = 0
      batterImg.anchorY = 1
      batterImg.x = 20
      batterImg.y = display.contentHeight - 20
      sceneGroup:insert(batterImg)
      return batterImg
    end)()
  )

  local pitcher = batterManager:getDataStore():getPitcher()
  viewManager:addComponent(
    SCENE_NAME,
    "CARD_ACTIVE_PITCHER",
    (function()
      local pitcherImg =
        widget.newButton(
        {
          defaultFile = assetUtil.resolveAssetPath(pitcher:getPictureURL()),
          width = 150 * 0.7,
          height = 210 * 0.7
        }
      )
      pitcherImg.anchorX = 1
      pitcherImg.anchorY = 0
      pitcherImg.x = display.contentWidth - 10
      pitcherImg.y = 10
      sceneGroup:insert(pitcherImg)
      return pitcherImg
    end)()
  )

  local balls, strikes = batterManager:getDataStore():getCount()
  viewManager:addComponent(
    SCENE_NAME,
    "SWING_SELECTION_COUNT",
    (function()
      local countText = display.newText(sceneGroup, "Count: " .. balls .. " - " .. strikes, 400, 80, "asul.ttf", 24)
      countText.anchorY = 0
      countText.x = display.contentCenterX
      countText.y = 20
      countText:setFillColor(1, 1, 1)
      return countText
    end)()
  )
end

function renderStatus()
  viewManager:addComponent(
    SCENE_NAME,
    "TEXT_GUESSED_PITCHES",
    (function()
      local resultText =
        display.newText(
        sceneGroup,
        "Pitch: " .. guessedPitch .. ", Zone: " .. guessedZone,
        400,
        80,
        native.systemFont,
        24
      )
      resultText.anchorX = 0
      resultText.anchorY = 0
      resultText.x = 20
      resultText.y = 20
      resultText:setFillColor(1, 1, 1)
      return resultText
    end)()
  )
end

-- getPitchByID retrives a pitch entity stored in the current pitcher entity
function getPitchByID(pitchID)
  local pitcher = batterManager:getDataStore():getPitcher()
  local pitch = pitcher:getPitches()[pitchID]
  if (pitch == nil) then
    error("invalid pitch selected: " .. pitchID)
  end
  return pitch
end

-- getActionCardByPitchID gets an action card associated assigned to a provided pitchID
function getActionCardByPitchID(pitchID)
  local pitchCardsMap = batterManager:getDataStore():getInPlayPitcherActionCardsMap()
  if (pitchCardsMap == nil or #pitchCardsMap < 1) then
    error("invalid pitch card")
    return
  end
  local actionCardID = pitchCardsMap[pitchID]
  local pitcherActionCards = batterManager:getDataStore():getPitcherActionCards()
  if (pitcherActionCards == nil or #pitcherActionCards < 1) then
    error("invalid pitcher action cards")
    return
  end
  local card = pitcherActionCards[actionCardID]
  return card
end

return scene
