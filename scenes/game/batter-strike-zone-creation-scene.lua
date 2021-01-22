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
local renderSelectZoneText
local renderConfirmButton
local renderCardHand

-- Local variables
local selectedZone = 1
-- Strike zone is a table map of zone id to the card being used
local strikeZone = {}

-- Action cards to use
-- TODO (wilbert): remove when we have real action cards
local actionCards = mockData.batterActionCards

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
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Header text
    viewManager:addComponent(
      SCENE_NAME,
      "TEXT_BUILD_STRIKE_ZONE",
      (function()
        local resultText = display.newText(sceneGroup, "Build your strike zone", 400, 80, native.systemFont, 24)
        resultText.x = display.contentCenterX
        resultText.y = 40
        resultText:setFillColor(1, 1, 1)
        return resultText
      end)()
    )

    -- Strike zone
    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_ZONE_1",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 1",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = assetUtil.resolveAssetPath("button.png"),
          overFile = assetUtil.resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(1)
          end
        }
        throwPitchButton.x = 20
        throwPitchButton.y = display.contentCenterY - 40
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_ZONE_2",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 2",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = assetUtil.resolveAssetPath("button.png"),
          overFile = assetUtil.resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(2)
          end
        }
        throwPitchButton.x = 100
        throwPitchButton.y = display.contentCenterY - 40
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_ZONE_3",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 3",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = assetUtil.resolveAssetPath("button.png"),
          overFile = assetUtil.resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(3)
          end
        }
        throwPitchButton.x = 20
        throwPitchButton.y = display.contentCenterY + 40
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_ZONE_4",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 4",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = assetUtil.resolveAssetPath("button.png"),
          overFile = assetUtil.resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(4)
          end
        }
        throwPitchButton.x = 100
        throwPitchButton.y = display.contentCenterY + 40
        return throwPitchButton
      end)()
    )
  end
  renderCardHand()
  renderSelectZoneText()
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

function onSelectZone(zone)
  selectedZone = zone
  renderSelectZoneText()
end

function onSelectCard(card)
  strikeZone[selectedZone] = card

  -- Move to the next zone as long as there's still
  -- zones left
  if (selectedZone < 4) then
    selectedZone = selectedZone + 1
  end

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

  -- TODO (wilbert): remove when UI is built out for this
  renderSelectZoneText()
end

function onConfirmStrikeZone()
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
end

-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

function renderSelectZoneText()
  viewManager:addComponent(
    SCENE_NAME,
    "TEXT_ZONE_SELECTED",
    (function()
      local resultText =
        display.newText(
        sceneGroup,
        "Selected zone: " .. selectedZone .. ", CardID: " .. (strikeZone[selectedZone] or "unassigned"),
        400,
        80,
        native.systemFont,
        24
      )
      resultText.x = 50
      resultText.y = 275
      resultText:setFillColor(1, 1, 1)
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
        label = "Confirm strike zone",
        labelColor = {default = {1.0}, over = {0.5}},
        defaultFile = assetUtil.resolveAssetPath("button.png"),
        overFile = assetUtil.resolveAssetPath("button-over.png"),
        width = 154,
        height = 40,
        onRelease = onConfirmStrikeZone
      }
      batterConfirmZoneButton.x = display.contentCenterX + 60
      batterConfirmZoneButton.y = 275
      return batterConfirmZoneButton
    end)()
  )
end

function renderCardHand()
  for i, card in ipairs(actionCards) do
    -- 4 cards on top row, 3 cards on bottom
    local x, y
    if (i <= 4) then
      x = 200 + ((i - 1) * 90)
      y = display.contentCenterY - 40
    else
      x = 200 + (((i - 4) - 1) * 90)
      y = display.contentCenterY + 50
    end

    viewManager:addComponent(
      SCENE_NAME,
      "ACTION_CARD_" .. card:getID(),
      (function()
        local cardButton =
          widget.newButton {
          label = "Card: " .. card:getID(),
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = assetUtil.resolveAssetPath("button.png"),
          overFile = assetUtil.resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectCard(card:getID())
          end
        }
        cardButton.x = x
        cardButton.y = y
        cardButton:setFillColor(1, 0, 0.7)
        return cardButton
      end)()
    )
  end
end

return scene
