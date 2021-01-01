local composer = require("composer")
local widget = require("widget")

local constants = require("scenes.game.constants")

local scene = composer.newScene()

-- Constant for root path to local asset folder
local ASSET_PATH = "scenes/game/assets/"
local function resolveAssetPath(fileName)
  return ASSET_PATH .. fileName
end

local viewManager
local batterManager
local inningManager

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  viewManager = composer.getVariable("viewManager")
  batterManager = composer.getVariable("batterManager")
  inningManager = composer.getVariable("inningManager")
end

function onSelectZone(selectedZone)
  local newState = batterManager:updateGameState(constants.ACTION_BATTER_SELECT_ZONE, {selectedZone = selectedZone})
  -- In multiplayer, this should be triggered automatically when both players have finished their selections
  newState = batterManager:updateGameState(constants.ACTION_BATTER_RESOLVE_PITCH)

  -- Execute the pitch
  composer.gotoScene("scenes.game.batter-result-scene")
end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    -- Create resolve button to resolve pitch
    viewManager:addComponent(
      "BUTTON_SELECT_PITCH_1",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 1",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = resolveAssetPath("button.png"),
          overFile = resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(1)
          end
        }
        throwPitchButton.x = display.contentCenterX
        throwPitchButton.y = display.contentCenterY - 80
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      "BUTTON_SELECT_PITCH_2",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 2",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = resolveAssetPath("button.png"),
          overFile = resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(2)
          end
        }
        throwPitchButton.x = display.contentCenterX + 80
        throwPitchButton.y = display.contentCenterY - 80
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      "BUTTON_SELECT_PITCH_3",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 3",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = resolveAssetPath("button.png"),
          overFile = resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(3)
          end
        }
        throwPitchButton.x = display.contentCenterX + 80
        throwPitchButton.y = display.contentCenterY
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      "BUTTON_SELECT_PITCH_4",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "Zone 4",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = resolveAssetPath("button.png"),
          overFile = resolveAssetPath("button-over.png"),
          width = 80,
          height = 80,
          onRelease = function()
            onSelectZone(4)
          end
        }
        throwPitchButton.x = display.contentCenterX
        throwPitchButton.y = display.contentCenterY
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      "BUTTON_SELECT_NO_SWING",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "No swing",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = resolveAssetPath("button.png"),
          overFile = resolveAssetPath("button-over.png"),
          width = 160,
          height = 80,
          onRelease = function()
            onSelectZone(0)
          end
        }
        throwPitchButton.x = display.contentCenterX + 40
        throwPitchButton.y = display.contentCenterY + 80
        return throwPitchButton
      end)()
    )
  elseif (phase == "did") then
  -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif (phase == "did") then
    -- Code here runs immediately after the scene goes entirely off screen
    viewManager:removeComponents(
      {
        "BUTTON_SELECT_PITCH_1",
        "BUTTON_SELECT_PITCH_2",
        "BUTTON_SELECT_PITCH_3",
        "BUTTON_SELECT_PITCH_4",
        "BUTTON_SELECT_NO_SWING"
      }
    )
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
