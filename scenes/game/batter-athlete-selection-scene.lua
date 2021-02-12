--------------------------------------------------------------------
-- batter-athlete-selection-scene.lua is the view layer
-- for selecting a batter athlete card to use.
--------------------------------------------------------------------

-- Public imports
local composer = require("composer")
local widget = require("widget")

-- Local imports
local assetUtil = require("scenes.game.utilities.asset-util")
local constants = require("scenes.game.utilities.constants")

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = constants.SCENE_NAME_BATTER_ATHLETE_SELECTION
local sceneGroup

-- Services
local viewManager
local batterManager

-- Local functions
local onConfirmBatterCard
local onSelectBatterCard
local renderBatterSelectConfirmButton
local renderBatterCardSelection

-- Local variables
local selectedBatterCardIndex = 0
local selectedBatterCard

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
    -- Header text
    viewManager:addComponent(
      SCENE_NAME,
      "TEXT_SELECT_BATTER",
      (function()
        local resultText = display.newText(sceneGroup, "Select your batter", 400, 80, "asul.ttf", 24)
        resultText.x = display.contentCenterX
        resultText.y = 40
        resultText:setFillColor(1, 1, 1)
        return resultText
      end)()
    )

    renderBatterCardSelection()
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

-- Action for when the player confirms and locks in a batter athlete card
function onConfirmBatterCard()
  batterManager:getDataStore():setBatter(selectedBatterCard)
  print(batterManager:getDataStore():getBatter():getName())
  composer.gotoScene("scenes.game.batter-strike-zone-creation-scene")
end

-- If batter card is selected, highlight and set the tentative
-- batter card to be that card. Show confirm button.
function onSelectBatterCard(batterCardIndex, batterCard)
  selectedBatterCardIndex = batterCardIndex
  selectedBatterCard = batterCard

  if (selectedBatterCardIndex > 0) then
    -- Display the confirm button
    renderBatterSelectConfirmButton()
  else
    error("invalid batter card index selected")
  end
end

-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

-- Render and display the confirm batter button
function renderBatterSelectConfirmButton()
  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_CONFIRM_BATTER",
    (function()
      local batterConfirmButton =
        widget.newButton {
        shape = "roundedRect",
        label = "Confirm",
        labelColor = {default = {1.0}, over = {0.5}},
        fillColor = {default = {0, 0.5, 1, 0.7}, over = {0, 0.5, 1, 1}},
        font = "asul.ttf",
        width = 152,
        height = 40,
        onRelease = onConfirmBatterCard
      }
      batterConfirmButton.x = display.contentWidth / 4 * selectedBatterCardIndex
      batterConfirmButton.y = 280
      return batterConfirmButton
    end)()
  )
end

-- Display the available athletes options to be the batter
-- Grab the available batters to be selected
function renderBatterCardSelection()
  local availableBatters = batterManager:getDataStore():getAvailableBatters()
  for i, batter in ipairs(availableBatters) do
    -- Create the batter card UI
    viewManager:addComponent(
      SCENE_NAME,
      "CARD_BATTER_" .. i,
      (function()
        local batterImg =
          widget.newButton(
          {
            defaultFile = assetUtil.resolveAssetPath(batter:getPictureURL()),
            width = 150,
            height = 210,
            onRelease = function()
              onSelectBatterCard(i, batter)
            end
          }
        )
        batterImg.x = (display.contentWidth / (#availableBatters + 1) * i)
        batterImg.y = display.contentCenterY + 20
        return batterImg
      end)()
    )
  end
end

return scene
