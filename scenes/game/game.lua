----------------------------------------------------------------------------------------
-- game.lua
-- Entry point for a game between two players
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")
local SolarWebSockets = require "plugin.solarwebsockets"
local json = require("json")

local assetUtil = require("scenes.game.utilities.asset-util")

-- DI modules
local dataStoreModule = require("scenes.game.services.data-store")
local batterManagerModule = require("scenes.game.services.batter-manager")
local viewManagerModule = require("scenes.game.services.view-manager")
local socketManagerModule = require("scenes.game.services.socket-manager")

-- Initialize scene variables
local scene = composer.newScene()

local SCENE_NAME = "GAME"

-- Local function declarations
local initializeSceneView
local updateSceneUI
local clearMatchup

-- -----------------------------------------------------------------------------------
-- Initialize scene
-- -----------------------------------------------------------------------------------

local sceneGroup
local viewManager
local batterManager
local socketManager

-- create() is executed on first load and runs only once (initialize values here)
function scene:create(event)
  sceneGroup = self.view

  -- ViewManager manages view state
  viewManager = viewManagerModule:new()
  viewManager:registerScene(SCENE_NAME)

  -- DataStore is a temporary AI to mock the response of the server
  local dataStore = dataStoreModule:new({balls = 0, strikes = 0})
  batterManager = batterManagerModule:new({dataStore = dataStore})

  -- SocketManager manages the socket lifecycle and provides listeners to
  -- for bidirectional client/server requests and responses
  socketManager = socketManagerModule:new({dataStore = dataStore})
  socketManager:connect("wss://echo.websocket.org")

  -- Register the service managers into the global composer for easy access
  composer.setVariable("viewManager", viewManager)
  composer.setVariable("batterManager", batterManager)
  composer.setVariable("socketManager", socketManager)
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    initializeSceneView(sceneGroup)
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function startGame()
  local testResponse = {
    state = "HELLO",
    pitchResultState = "PENIS",
    balls = 1,
    strikes = 2
  }
  SolarWebSockets.sendServer(json.encode({statusCode = 200, type = "game_update", body = testResponse}))
  -- {statusCode = 200, body = "hi"}
  composer.gotoScene("scenes.game.batter-athlete-selection-scene")
end

-- -----------------------------------------------------------------------------------
-- UI instantions and updates
-- -----------------------------------------------------------------------------------

function initializeSceneView(sceneGroup)
  -- Create resolve button to start game
  viewManager:addComponent(
    SCENE_NAME,
    "BUTTON_START_GAME",
    (function()
      local startGameButton =
        widget.newButton {
        font = "asul.ttf",
        label = "Start game",
        labelColor = {default = {1.0}, over = {0.5}},
        shape = "roundedRect",
        fillColor = {default = {0, 0.5, 1, 0.7}, over = {0, 0.5, 1, 1}},
        width = 154,
        height = 40,
        onRelease = startGame
      }
      startGameButton.x = display.contentCenterX
      startGameButton.y = display.contentCenterY
      return startGameButton
    end)()
  )
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == "did" then
    viewManager:removeComponents(SCENE_NAME)
  end
end

function scene:destroy(event)
end

---------------------------------------------------------------------------------
-- Listener setup (default Solar2D events)
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-----------------------------------------------------------------------------------------

return scene
