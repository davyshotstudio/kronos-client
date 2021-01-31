-- Public imports
local composer = require("composer")
local widget = require("widget")

-- Local imports
local assetUtil = require("scenes.game.utilities.asset-util")
local constants = require("scenes.game.utilities.constants")

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = constants.SCENE_NAME_BATTER_CARD_ZOOMED_OVERLAY
local sceneGroup

-- Services
local viewManager
local batterManager

local onBackgroundClick

function scene:create(event)
  -- Retrieve DI instances of the managers
  viewManager = composer.getVariable("viewManager")
  batterManager = composer.getVariable("batterManager")

  -- Register scene domain into the ViewManager
  viewManager:registerScene(SCENE_NAME)
end

function scene:show(event)
  sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent -- Reference to the parent scene object

  local card = event.params["card"]

  if (phase == "did") then
    -- Fake tin that covers the existing screen
    local backgroundTintOverlay =
      viewManager:addComponent(
      SCENE_NAME,
      "BACKGROUND_TINT_OVERLAY",
      (function()
        local backgroundTint =
          widget.newButton(
          {
            shape = "rect",
            width = display.actualContentWidth,
            height = display.actualContentHeight + 100,
            left = 0,
            top = -100,
            onRelease = onBackgroundClick
          }
        )
        backgroundTint:setFillColor(0.1)
        backgroundTint.alpha = 0.75
        sceneGroup:insert(backgroundTint)
        return backgroundTint
      end)()
    )

    local actionCardView =
      viewManager:addComponent(
      SCENE_NAME,
      "ACTION_CARD_" .. card:getID(),
      (function()
        local cardButton =
          widget.newButton {
          font = "asul.ttf",
          defaultFile = assetUtil.resolveAssetPath(card:getBattingAction():getPictureURL())
        }
        cardButton.x = display.contentCenterX
        cardButton.y = display.contentCenterY
        sceneGroup:insert(cardButton)
        return cardButton
      end)()
    )
  end
end

function scene:hide(event)
  local phase = event.phase

  if (phase == "did") then
    viewManager:removeComponents(SCENE_NAME)
  end
end

scene:addEventListener("hide", scene)
scene:addEventListener("show", scene)
scene:addEventListener("create", scene)

-- Exit from overlay
function onBackgroundClick()
  composer.hideOverlay("fade", 200)
end

return scene
