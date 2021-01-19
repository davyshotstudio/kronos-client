--------------------------------------------------------------------
-- batter-swing-selection-scene.lua is the view layer
-- for selecting where the batter wants to take their swing
--------------------------------------------------------------------

-- Public imports
local composer = require("composer")
local widget = require("widget")

-- Local imports
local constants = require("scenes.game.utilities.constants")
local assetUtil = require("scenes.game.utilities.asset-util")

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = "BATTER_SWING_SELECTION_SCENE"
local sceneGroup

-- Services
local viewManager
local batterManager

-- Local functions
local onSelectZone
local renderMatchup

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
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    -- Create resolve button to resolve pitch
    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_SELECT_PITCH_1",
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
        throwPitchButton.x = display.contentCenterX
        throwPitchButton.y = display.contentCenterY - 80
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_SELECT_PITCH_2",
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
        throwPitchButton.x = display.contentCenterX + 80
        throwPitchButton.y = display.contentCenterY - 80
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_SELECT_PITCH_3",
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
        throwPitchButton.x = display.contentCenterX + 80
        throwPitchButton.y = display.contentCenterY
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_SELECT_PITCH_4",
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
        throwPitchButton.x = display.contentCenterX
        throwPitchButton.y = display.contentCenterY
        return throwPitchButton
      end)()
    )

    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_SELECT_NO_SWING",
      (function()
        local throwPitchButton =
          widget.newButton {
          label = "No swing",
          labelColor = {default = {1.0}, over = {0.5}},
          defaultFile = assetUtil.resolveAssetPath("button.png"),
          overFile = assetUtil.resolveAssetPath("button-over.png"),
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

    renderMatchup()
  end
end

function scene:hide(event)
  local phase = event.phase

  if (phase == "did") then
    -- Code here runs immediately after the scene goes entirely off screen
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

function onSelectZone(selectedZone)
  local newState = batterManager:updateGameState(constants.ACTION_BATTER_SELECT_ZONE, {selectedZone = selectedZone})
  -- In multiplayer, this should be triggered automatically when both players have finished their selections
  newState = batterManager:updateGameState(constants.ACTION_BATTER_RESOLVE_PITCH)

  -- Execute the pitch
  composer.gotoScene("scenes.game.batter-result-scene")
end

-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

function renderMatchup()
  local batter = batterManager:getResolverManager():getBatter()
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
      batterImg.x = 30
      batterImg.y = display.contentCenterY
      return batterImg
    end)()
  )

  local pitcher = batterManager:getResolverManager():getPitcher()
  viewManager:addComponent(
    SCENE_NAME,
    "CARD_ACTIVE_PITCHER",
    (function()
      local pitcherImg =
        widget.newButton(
        {
          defaultFile = assetUtil.resolveAssetPath(pitcher:getPictureURL()),
          width = 150,
          height = 210
        }
      )
      pitcherImg.x = display.contentWidth - 30
      pitcherImg.y = display.contentCenterY
      return pitcherImg
    end)()
  )

  local balls, strikes = batterManager:getResolverManager():getCount()
  viewManager:addComponent(
    SCENE_NAME,
    "SWING_SELECTION_COUNT",
    (function()
      local resultText =
        display.newText(sceneGroup, "Count: " .. balls .. " - " .. strikes, 400, 80, native.systemFont, 24)
      resultText.x = display.contentCenterX
      resultText.y = 20
      resultText:setFillColor(1, 1, 1)
      return resultText
    end)()
  )
end

return scene
