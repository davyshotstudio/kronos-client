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
local renderZoneGuessSelection
local renderPitchGuessSelection
local renderStatus

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

function onGuessZone(zone)
  guessedZone = zone
  renderStatus()
end

function onGuessPitch(pitchID)
  guessedPitch = pitchID
  renderStatus()
end

function onConfirm()
  local newState = batterManager:updateGameState(constants.ACTION_BATTER_SELECT_ZONE, {guessedZone = guessedZone, guessedPitch = guessedPitch})
  -- In multiplayer, this should be triggered automatically when both players have finished their selections
  newState = batterManager:updateGameState(constants.ACTION_BATTER_RESOLVE_PITCH)

  -- Execute the pitch
  composer.gotoScene("scenes.game.batter-result-scene")
end
-- -----------------------------------------------------------------------------------
-- Scene render functions
-- -----------------------------------------------------------------------------------

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
        confirmGuessButton.x = display.contentCenterX
        confirmGuessButton.y = 300
        return confirmGuessButton
      end)()
    )
end

function renderPitchGuessSelection()
  local pitches = batterManager:getResolverManager():getPitcher():getPitches()
  for i, pitch in ipairs(pitches) do
    viewManager:addComponent(
      SCENE_NAME,
      "BUTTON_GUESS_PITCH_" .. pitch.id,
      (function()
        local guessZoneButton =
          widget.newButton {
          label = pitch.abbreviation,
          labelColor = {default = {1.0}, over = {0.5}},
          width = 50,
          height = 50,
          shape = "roundedRect",
          cornerRadius = "50",
          fillColor = {default = {1, 0.2, 0.5, 0.7}, over = {1, 0.2, 0.5, 1}},
          onRelease = function()
            onGuessPitch(pitch.id)
          end
        }
        guessZoneButton.x = 150
        guessZoneButton.y = 100 + (i - 1) * 60
        return guessZoneButton
      end)()
    )
  end
end

function renderZoneGuessSelection()
  -- Create resolve button to resolve pitch
  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_GUESS_ZONE_1",
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
          onGuessZone(1)
        end
      }
      throwPitchButton.x = display.contentCenterX
      throwPitchButton.y = display.contentCenterY - 80
      return throwPitchButton
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_GUESS_ZONE_2",
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
          onGuessZone(2)
        end
      }
      throwPitchButton.x = display.contentCenterX + 80
      throwPitchButton.y = display.contentCenterY - 80
      return throwPitchButton
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_GUESS_ZONE_3",
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
          onGuessZone(3)
        end
      }
      throwPitchButton.x = display.contentCenterX + 80
      throwPitchButton.y = display.contentCenterY
      return throwPitchButton
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_GUESS_ZONE_4",
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
          onGuessZone(4)
        end
      }
      throwPitchButton.x = display.contentCenterX
      throwPitchButton.y = display.contentCenterY
      return throwPitchButton
    end)()
  )

  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_NO_SWING",
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
          onGuessZone(0)
        end
      }
      throwPitchButton.x = display.contentCenterX + 40
      throwPitchButton.y = display.contentCenterY + 80
      return throwPitchButton
    end)()
  )
end

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

function renderStatus()
  viewManager:addComponent(
    SCENE_NAME,
    "TEXT_GUESSED_PITCHES",
    (function()
      local resultText = display.newText(sceneGroup, "Pitch: " .. guessedPitch .. ", Zone: " .. guessedZone, 400, 80, native.systemFont, 24)
      resultText.x = 20
      resultText.y = 20
      resultText:setFillColor(1, 1, 1)
      return resultText
    end)()
  )
end

return scene
