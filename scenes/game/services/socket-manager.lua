--------------------------------------------------------------------
-- SocketManager listens to responses from the provided websocket server
-- and triggers actions based upon incoming responses
--------------------------------------------------------------------
local SolarWebSockets = require("plugin.solarwebsockets")
local json = require("json")
local composer = require("composer")

local SocketManager = {}

-- Instantiate SocketManager (constructor)
function SocketManager:new(options)
  local dataStore = options.dataStore
  local actionListeners = {}

  local socketManager = {
    dataStore = dataStore,
    actionListeners = actionListeners
  }

  setmetatable(socketManager, self)
  self.__index = self

  return socketManager
end

-- Establish connection
function SocketManager:connect(socketConnectionURL)
  -- Initialize websocket listeners
  SolarWebSockets.init(
    function(event)
      self:_socketListener(event)
    end
  )

  SolarWebSockets.connect(socketConnectionURL)
end

-- Terminate connection
function SocketManager:disconnect()
  SolarWebSockets.disconnect()
end

-- Send a message up to the server
function SocketManager:sendMessage(message)
  print("sending message: " .. json.encode(message))
  if (message == nil or message == {}) then
    error("cannot send empty message")
  end
  SolarWebSockets.sendServer(json.encode(message))
end

-- For websocket debugging purposes
local message = display.newText("debug messages here", 120, 320, nil, 6)
message.anchorY = 1
message.y = display.contentHeight

function SocketManager:addActionListener(actionListener)
  table.insert(self.actionListeners, actionListener)
end

-- Helper function for listener initialization logic
function SocketManager:_socketListener(event)
  message.text = json.encode(event)
  if (event.isClient) then
    -- Connection events
    if (event.name == "join") then
      print("socket connection established")

      -- Reload the current scene when connected
      local currentScene = composer.getSceneName("current")
      composer.gotoScene(
        currentScene,
        {
          params = {isSocketConnectionReady = true}
        }
      )
    end

    if (event.name == "message") then
      print("got message from server")
      message = json.decode(event.message)
      if (message.type == "game_update") then
        -- Listen to updates in the game state
        for key, value in pairs(message.body) do
          self:setData(key, value)
        end

        -- Listen to updates to the event action, if available.
        -- The event action will be used to trigger state changes in the client
        if (message.eventAction ~= nil and message.eventAction ~= "") then
          for i, actionListener in ipairs(self.actionListeners) do
            actionListener.listener(actionListener.self, message.eventAction, message.eventActionParams)
          end
        end
      end
    end

    if (event.name == "leave") then
      -- not connected anymore
      print("disconnected from socket")
      print("error code: ", tostring(event.errorCode))
      print("error message: ", tostring(event.errorMessage))
    end
  end
end

-- Take the fieldKey (key of incoming data field) and update
-- the datastore value for the corresponding key
function SocketManager:setData(fieldKey, value)
  local ds = self.dataStore
  local mappings = {
    state = ds.setState,
    pitchResultState = ds.setPitchResultState,
    batter = ds.setBatter,
    pitcher = ds.setPitcher,
    lastRollsPitcher = ds.setLastRollsPitcher,
    lastRollsBatter = ds.setLastRollsBatter,
    balls = ds.setCountBalls,
    strikes = ds.setCountStrikes,
    availableBatters = ds.setAvailableBatters,
    outs = ds.setOuts,
    inning = ds.setInning,
    pitcherActionCards = ds.setPitcherActionCards,
    batterActionCards = ds.setBatterActionCards,
    inPlayPitcherActionCardsMap = ds.setInPlayPitcherActionCardsMap,
    inPlayBatterActionCardsMap = ds.setInPlayBatterActionCardsMap,
    awayScore = ds.setAwayScore,
    homeScore = ds.setHomeScore,
    awayTeam = ds.setAwayTeam,
    homeTeam = ds.setHomeTeam,
    batterSelectedPitch = ds.setBatterSelectedPitch,
    batterSelectedZone = ds.setBatterSelectedZone,
    pitcherSelectedPitch = ds.setPitcherSelectedPitch,
    pitcherSelectedZone = ds.setPitcherSelectedZone
  }

  -- Update datastore for the provided key
  mappings[fieldKey](ds, value)
end

return SocketManager
