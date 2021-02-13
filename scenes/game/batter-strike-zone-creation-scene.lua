--------------------------------------------------------------------
-- batter-strike-zone-creation-scene.lua is the view layer
-- for choosing the batter's strike zone cards
--------------------------------------------------------------------

-- Public imports
local composer = require("composer")
local widget = require("widget")

-- Local imports
local assetUtil = require("scenes.game.utilities.asset-util")
local constants = require("scenes.game.utilities.constants")
local mockData = require("scenes.game.utilities.fixtures.mock-data")
local eventHandlers = require("scenes.game.utilities.event-handlers")
local modals = require("scenes.game.utilities.modals")

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = constants.SCENE_NAME_BATTER_STRIKE_ZONE_CREATION
local sceneGroup

-- Services
local viewManager
local batterManager

-- Local functions
local onSelectZone
local onSelectCard
local onConfirmStrikeZone
local onCardSwipe
local onCurrentBatterZoom
local renderSelectZoneText
local renderConfirmButton
local renderCardHand
local renderSelectedCard
local renderStrikeZone
local renderCurrentBatter
local popAwayBatterCard

-- Local variables
local selectedZone
local strikeZone
local actionCards
-- These two variables are used to help track when the user is holding down on a card
local selectCardStartTime
local selectCardHold
local batterCardZoomed

function initializeVariables()
  selectedZone = 1
  -- Strike zone is a table map of zone id to the card being used
  strikeZone = {}

  -- Action cards to use
  -- TODO (wilbert): remove when we have real action cards
  actionCards = batterManager:getDataStore():getBatterActionCards()

  selectCardHold = false
  batterCardZoomed = false
end

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
  initializeVariables()
end

function scene:show(event)
  local phase = event.phase

  if (phase == "will") then
    -- Header text
    viewManager:addComponent(
      SCENE_NAME,
      "TEXT_BUILD_STRIKE_ZONE",
      (function()
        local resultText = display.newText(sceneGroup, "Build your strike zone", 400, 80, "asul.ttf", 24)
        resultText.x = display.contentCenterX
        resultText.y = 40
        resultText:setFillColor(1, 1, 1)
        return resultText
      end)()
    )

    renderStrikeZone()
    renderCardHand()
    renderCurrentBatter()
    renderSelectZoneText()
  end
end

function scene:hide(event)
  local phase = event.phase

  if (phase == "did") then
    viewManager:removeComponents(SCENE_NAME)
    initializeVariables()
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

function onSelectZone(zone)
  selectedZone = zone
  renderSelectZoneText()
  renderStrikeZone()
end

-- Handle actions for selecting a card from the hand
function onSelectCard(event, card, scrollView)
  local holdFunction = function()
    modals.showCardModal(card, card:getBattingAction():getPictureURL())
  end

  local tapFunction = function()
    local previousCardID = nil
    if (strikeZone[selectedZone]) then
      previousCardID = strikeZone[selectedZone]:getID()
    end
    strikeZone[selectedZone] = card
    -- Move to the next zone as long as there's still
    -- zones left
    if (selectedZone < 4) then
      selectedZone = selectedZone + 1
    end

    renderSelectZoneText()
    renderStrikeZone()
    renderSelectedCard(card:getID(), previousCardID)

    -- If there are no more zones to fill,
    -- show the confirm button
    local allZonesFilled = true
    for zone = 1, 4 do
      if (strikeZone[zone] == nil) then
        allZonesFilled = false
        break
      end
    end
    if (allZonesFilled) then
      if (viewManager:getComponent(SCENE_NAME, "BUTTON_CONFIRM_ZONE_CREATION") == nil) then
        renderConfirmButton()
      end
    end
  end

  eventHandlers.onUserActionEvent(event, {hold = holdFunction, tap = tapFunction}, {scrollView = scrollView})
end

-- Handle when user clicks on a the batter card
function onCurrentBatterZoom(event)
  -- Pop the batter card to the top
  event.target:toFront()
  if (batterCardZoomed) then
    popAwayBatterCard()
    return
  end
  transition.moveTo(event.target, {y = display.contentHeight - 100, time = 300, transition = easing.outBack})
  batterCardZoomed = true
end

function onConfirmStrikeZone()
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
end

-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

function renderStrikeZone()
  -- Close any popups
  popAwayBatterCard()

  -- Create new group for the strike zone
  local group = display.newGroup()

  for i = 1, 4 do
    local cardText = i
    local cardImage = ""
    if (strikeZone[i] ~= nil) then
      cardText = "Card: " .. strikeZone[i]:getID()
      cardImage = assetUtil.resolveAssetPath(strikeZone[i]:getBattingAction():getPictureURL())
    end

    local zoneButtonSettings = {
      width = 67,
      height = 91,
      onRelease = function()
        onSelectZone(i)
      end,
      font = "asul.ttf"
    }

    if (cardImage == "") then
      zoneButtonSettings["label"] = cardText
      zoneButtonSettings["labelColor"] = {default = {1.0}, over = {0.5}}
      zoneButtonSettings["shape"] = "rect"
    else
      zoneButtonSettings["defaultFile"] = cardImage
    end

    -- Strike zone
    local zoneButton =
      viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_ZONE_" .. i,
      (function()
        local zoneButton = widget.newButton(zoneButtonSettings)
        if (cardImage == "") then
          zoneButton:setFillColor(0.6)
        end

        if (selectedZone == i) then
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

    group.x = 60
    group.y = 40
  end

  sceneGroup:insert(group)
end

function renderSelectZoneText()
  -- This is for debugging purposes only
  if (system.getInfo("environment") ~= "x") then
    return
  end

  local cardID = ""
  print("selectedZone: " .. selectedZone)
  if strikeZone[selectedZone] then
    cardID = strikeZone[selectedZone]:getID()
  end
  print("cardID: " .. cardID)
  viewManager:addComponent(
    SCENE_NAME,
    "TEXT_ZONE_SELECTED",
    (function()
      local resultText =
        display.newText(
        sceneGroup,
        "Selected zone: " .. selectedZone .. ", CardID: " .. (cardID or "unassigned"),
        400,
        80,
        system.nativeFont,
        24
      )
      resultText.x = 50
      resultText.y = 275
      resultText:setFillColor(1, 0, 0)
      return resultText
    end)()
  )
end

function renderConfirmButton()
  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_CONFIRM_ZONE_CREATION",
    (function()
      local batterConfirmZoneButton =
        widget.newButton {
        label = "Confirm zone cards",
        shape = "roundedRect",
        labelColor = {default = {1.0}, over = {0.5}},
        fillColor = {default = {0, 0.5, 1, 0.7}, over = {0, 0.5, 1, 1}},
        width = 160,
        height = 40,
        onRelease = onConfirmStrikeZone,
        font = "asul.ttf",
        x = display.contentWidth - 100,
        y = display.contentHeight - 40
      }
      return batterConfirmZoneButton
    end)()
  )
end

function renderCardHand()
  local scrollView =
    widget.newScrollView(
    ({
      y = display.contentCenterY,
      left = display.contentCenterX - 170,
      width = display.actualContentWidth / 2 + 90,
      height = display.actualContentHeight,
      hideBackground = true,
      verticalScrollDisabled = true,
      friction = 0.85
    })
  )

  for i, card in ipairs(actionCards) do
    local x, y
    x = 75 + ((i - 1) * 150)
    y = display.contentCenterY

    local actionCardView =
      viewManager:addComponent(
      SCENE_NAME,
      "ACTION_CARD_" .. card:getID(),
      (function()
        local cardButton =
          widget.newButton {
          label = "Card: " .. card:getID(),
          labelColor = {default = {0.5}, over = {1}},
          font = "asul.ttf",
          defaultFile = assetUtil.resolveAssetPath(card:getBattingAction():getPictureURL()),
          width = 130,
          height = 182,
          onEvent = function(event)
            onSelectCard(event, card, scrollView)
          end
        }
        return cardButton
      end)()
    )

    scrollView:insert(actionCardView)
    actionCardView.x = x
    actionCardView.y = y
  end

  sceneGroup:insert(scrollView)
end

-- Apply styling to selected cards in the hand
-- Optionally take in the previous card to remove its styling
function renderSelectedCard(selectedCardID, previousCardID)
  if (previousCardID ~= nil) then
    local previousCardActionView = viewManager:getComponent(SCENE_NAME, "ACTION_CARD_" .. previousCardID)
    previousCardActionView:setFillColor(1)
  end

  local actionCardView = viewManager:getComponent(SCENE_NAME, "ACTION_CARD_" .. selectedCardID)
  actionCardView:setFillColor(0.3)
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
      currentBatterView.x = 95
      currentBatterView.y = display.contentHeight
      sceneGroup:insert(currentBatterView)
      return currentBatterView
    end)()
  )
end

-- -----------------------------------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------------------------------

function popAwayBatterCard()
  local currentBatterCardView = viewManager:getComponent(SCENE_NAME, "CURRENT_BATTER_CARD")
  transition.moveTo(currentBatterCardView, {y = display.contentHeight, time = 300, transition = easing.inBack})
  batterCardZoomed = false
end

return scene
