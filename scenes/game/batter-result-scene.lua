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

-- Scene setup
local scene = composer.newScene()
local SCENE_NAME = constants.SCENE_NAME_BATTER_RESULT
local sceneGroup

-- Services
local viewManager
local batterManager

-- Local functions

-- Local variables
local onNextPitch
local onNextBatter

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
    -- Show the result of the pitch
    local pitcherRoll, batterRoll = batterManager:getDataStore():getLastRolls()
    -- Add result
    viewManager:addComponent(
      SCENE_NAME,
      "TEXT_RESULT_SCENE",
      (function()
        local resultText =
          display.newText(
          sceneGroup,
          "Result: " ..
            batterManager:getDataStore():getPitchResultState() ..
              " (pitcher: " .. pitcherRoll .. ", batter: " .. batterRoll .. ")",
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

    viewManager:addComponent(
      SCENE_NAME,
      "TEXT_BATTER_COUNT",
      (function()
        local balls, strikes = batterManager:getDataStore():getCount()
        local resultText =
          display.newText(sceneGroup, "Count: " .. ": " .. balls .. " - " .. strikes, 400, 80, native.systemFont, 24)
        resultText.x = display.contentCenterX
        resultText.y = display.contentCenterY + 25
        resultText:setFillColor(1, 0, 0)
        return resultText
      end)()
    )

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
              defaultFile = assetUtil.resolveAssetPath("button.png"),
              overFile = assetUtil.resolveAssetPath("button-over.png"),
              width = 100,
              height = 40,
              onRelease = onNextBatter
            }
            nextBatterButton.x = display.contentCenterX
            nextBatterButton.y = display.contentCenterY + 70
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
              defaultFile = assetUtil.resolveAssetPath("button.png"),
              overFile = assetUtil.resolveAssetPath("button-over.png"),
              width = 100,
              height = 40,
              onRelease = onNextPitch
            }
            nextPitchButton.x = display.contentCenterX
            nextPitchButton.y = display.contentCenterY + 70
            return nextPitchButton
          end)()
        )
      end
    end
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

function onNextPitch()
  batterManager:updateGameState(constants.ACTION_BATTER_NEXT_PITCH)
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
end

function onNextBatter()
  batterManager:updateGameState(constants.ACTION_BATTER_NEXT_BATTER)
  composer.gotoScene("scenes.game.batter-athlete-selection-scene")
end

return scene
