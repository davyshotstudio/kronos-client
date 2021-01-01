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

local nextPitch
local nextBatter

-- -----------------------------------------------------------------------------------
-- Scene event lifecycle functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  viewManager = composer.getVariable("viewManager")
  batterManager = composer.getVariable("batterManager")
  inningManager = composer.getVariable("inningManager")
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

    -- Show the result of the pitch
    local pitcherRoll, batterRoll = batterManager:getResolverManager():getLastRolls()
    -- Add result
    viewManager:addComponent(
      "TEXT_RESULT_SCENE",
      (function()
        local resultText =
          display.newText(
          sceneGroup,
          "Result: " ..
            batterManager:getResolverManager():getPitchResultState() ..
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

    if (batterManager:getState() == constants.STATE_BATTER_RESULT) then
      if (batterManager:getIsNextAtBat()) then
        -- Next batter button
        viewManager:addComponent(
          "NEXT_BATTER",
          (function()
            local nextBatterButton =
              widget.newButton {
              sceneGroup = sceneGroup,
              label = "Next batter",
              labelColor = {default = {1.0}, over = {0.5}},
              defaultFile = resolveAssetPath("button.png"),
              overFile = resolveAssetPath("button-over.png"),
              width = 100,
              height = 40,
              onRelease = nextBatter
            }
            nextBatterButton.x = display.contentCenterX
            nextBatterButton.y = display.contentCenterY + 60
            return nextBatterButton
          end)()
        )
      else
        -- Next pitch button
        viewManager:addComponent(
          "NEXT_PITCH",
          (function()
            local nextPitchButton =
              widget.newButton {
              sceneGroup = sceneGroup,
              label = "Next pitch",
              labelColor = {default = {1.0}, over = {0.5}},
              defaultFile = resolveAssetPath("button.png"),
              overFile = resolveAssetPath("button-over.png"),
              width = 100,
              height = 40,
              onRelease = nextPitch
            }
            nextPitchButton.x = display.contentCenterX
            nextPitchButton.y = display.contentCenterY + 60
            return nextPitchButton
          end)()
        )
      end
    end
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif (phase == "did") then
    -- Code here runs immediately after the scene goes entirely off screen
    viewManager:removeComponents(
      {
        "NEXT_PITCH",
        "NEXT_BATTER",
        "TEXT_RESULT_SCENE"
      }
    )
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

function nextPitch()
  batterManager:updateGameState(constants.ACTION_BATTER_NEXT_PITCH)
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
end

function nextBatter()
  batterManager:updateGameState(constants.ACTION_BATTER_NEXT_BATTER)
  composer.gotoScene("scenes.game.batter-swing-selection-scene")
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
