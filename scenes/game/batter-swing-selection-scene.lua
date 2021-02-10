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
local renderBackground
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

function onGuessZone(zone)
  guessedZone = zone
  renderStatus()
  renderZoneGuessSelection()
end

function onGuessPitch(pitchID)
  guessedPitch = pitchID
  renderStatus()
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
      background.x = 0 + display.screenOriginX
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
        guessZoneButton.anchorX = 1
        guessZoneButton.anchorY = 0
        guessZoneButton.x = display.contentWidth - 150
        guessZoneButton.y = 10 + (i - 1) * 60
        return guessZoneButton
      end)()
    )
  end
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
      onRelease = function()
        onGuessZone(i)
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
      batterImg.anchorX = 0
      batterImg.anchorY = 1
      batterImg.x = 20
      batterImg.y = display.contentHeight - 20
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
          width = 150 * 0.7,
          height = 210 * 0.7
        }
      )
      pitcherImg.anchorX = 1
      pitcherImg.anchorY = 0
      pitcherImg.x = display.contentWidth - 10
      pitcherImg.y = 10
      return pitcherImg
    end)()
  )

  local balls, strikes = batterManager:getResolverManager():getCount()
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

return scene
