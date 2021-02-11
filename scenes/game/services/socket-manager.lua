--------------------------------------------------------------------
-- SocketManager listens to responses from the provided websocket server
-- and triggers actions based upon incoming responses
--------------------------------------------------------------------
local SolarWebSockets = require("plugin.solarwebsockets")
local json = require("json")

local SocketManager = {}

-- Instantiate SocketManager (constructor)
function SocketManager:new(options)
  local dataStore = options.dataStore

  local socketManager = {
    dataStore = dataStore
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
  print("sending message: " .. message)
  SolarWebSockets.sendServer(message)
end

-- For websocket debugging purposes
local message = display.newText("debug messages here", 120, 320, nil, 6)

-- Helper function for listener initialization logic
function SocketManager:_socketListener(event)
  message.text = json.encode(event)
  if event.isClient then
    -- Connection events
    if event.name == "join" then
      print("socket connection established")
    end
    if event.name == "message" then
      print("got message from server")
      message = json.decode(event.message)
      -- Listen to updates in the game state
      if message.type == "game_update" then
        for key, value in pairs(message.body) do
          self:setData(key, value)
        end
      end
    end
    if event.name == "leave" then
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
    availableBatters = ds.setAvailableBatters
  }

  -- Update datastore for the provided key
  mappings[fieldKey](ds, value)
end

return SocketManager
