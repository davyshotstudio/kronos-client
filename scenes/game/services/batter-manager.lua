--------------------------------------------------------------------
-- BatterManager is a service that acts as a state machine that
-- manages the client side behaviour and data for the batter flow
--------------------------------------------------------------------

local constants = require("scenes.game.utilities.constants")
local config = require("scenes.game.utilities.config")
local mockData = require("scenes.game.utilities.fixtures.mock-data")

local BatterManager = {}

-- Instantiate BatterManager (constructor)
function BatterManager:new(options)
  -- TODO (wilbert): remove for server provided starting state
  local dataStore = options.dataStore
  -- If true, we're still in the at bat (result was a strike or ball or foul)
  local isNextAtBat = false

  -- MockServer for mocking server responses
  local mockServer = options.mockServer

  local socketManager = options.socketManager

  local batterManager = {
    isNextAtBat = isNextAtBat,
    dataStore = dataStore,
    mockServer = mockServer,
    socketManager = socketManager
  }

  setmetatable(batterManager, self)
  self.__index = self

  return batterManager
end

function BatterManager:registerActionListener()
  self.socketManager:addActionListener({self = self, listener = self.updateGameState})
end

-- Update the game state for a batter flow
function BatterManager:updateGameState(action, params)
  -- Grab the correct function to handle the incoming action
  -- based on the current state
  local currentState = self.dataStore:getState()
  local stateActionMapping = {
    [constants.STATE_BATTER_START] = self.handleStart,
    [constants.STATE_BATTER_ATHLETE_SELECT] = self.handleAthleteSelect,
    [constants.STATE_BATTER_ATHLETE_SELECT_PENDING] = self.handleAthleteSelectPending,
    [constants.STATE_BATTER_ZONE_CREATE] = self.handleZoneCreate,
    [constants.STATE_BATTER_ZONE_CREATE_PENDING] = self.handleZoneCreatePending,
    [constants.STATE_BATTER_SWING_SELECT] = self.handleSwingSelect,
    [constants.STATE_BATTER_SWING_SELECT_PENDING] = self.handleSwingSelectPending,
    [constants.STATE_BATTER_RESULT] = self.handleResult
  }

  if (stateActionMapping[currentState] == nil) then
    error("batter state not handled in batter-manager: " .. currentState)
  end

  local nextState = stateActionMapping[currentState](self, currentState, action, params)
  if (nextState == nil or nextState == "") then
    error("next batter state is invalid: " .. nextState)
  end

  -- Update the state and trigger listeners to the state
  self.dataStore:setState(nextState)
  return nextState
end

function BatterManager:handleStart(currentState, action, params)
  local nextState = currentState
  if (action == constants.ACTION_BATTER_START) then
    -- TODO (wilbert): notify the server that the batter is ready to go
    nextState = constants.STATE_BATTER_ATHLETE_SELECT
  end
  return nextState
end

function BatterManager:handleAthleteSelect(currentState, action, params)
  local nextState = currentState
  if (action == constants.ACTION_BATTER_SELECT_ATHLETE) then
    self.mockServer:updateState(
      constants.ACTION_RESOLVER_BATTER_SELECT_ATHLETE,
      {selectedBatterCard = params.selectedBatterCard}
    )
    nextState = constants.STATE_BATTER_ATHLETE_SELECT_PENDING
  end
  return nextState
end

-- This should be triggered when the server notifies the client
-- that both players have selected their athletes
function BatterManager:handleAthleteSelectPending(currentState, action, params)
  local nextState = currentState
  if (action == constants.ACTION_BATTER_SELECT_ATHLETE_READY) then
    nextState = constants.STATE_BATTER_ZONE_CREATE
  end
  return nextState
end

function BatterManager:handleZoneCreate(currentState, action, params)
  local nextState = currentState
  if (action == constants.ACTION_BATTER_CREATE_ZONE) then
    self.mockServer:updateState(
      constants.ACTION_RESOLVER_BATTER_CREATE_ZONE,
      {inPlayBatterActionCardsMap = params.inPlayBatterActionCardsMap}
    )
    nextState = constants.STATE_BATTER_ZONE_CREATE_PENDING
  end
  return nextState
end

-- This should be triggered when the server notifies the client
-- that the client is ready to create the strike zone
function BatterManager:handleZoneCreatePending(currentState, action, params)
  local nextState = currentState
  if (action == constants.ACTION_BATTER_CREATE_ZONE_READY) then
    nextState = constants.STATE_BATTER_SWING_SELECT
  end
  return nextState
end

function BatterManager:handleSwingSelect(currentState, action, params)
  -- When the user selects a zone:
  -- (1) Mark zone as selected
  -- (2) Update the state to STATE_BATTER_SWING_SELECT_PENDING to wait for other player
  local nextState = currentState
  if (action == constants.ACTION_BATTER_SELECT_ZONE) then
    self.mockServer:updateState(
      constants.ACTION_RESOLVER_BATTER_SELECT_ZONE,
      {batterGuessedZone = params.guessedZone, batterGuessedPitch = params.guessedPitch}
    )
    nextState = constants.STATE_BATTER_SWING_SELECT_PENDING
  end
  return nextState
end

-- This should be triggered when the server notifies the client
-- that the client is ready to process a swing
function BatterManager:handleSwingSelectPending(currentState, action, params)
  local nextState = currentState
  -- Wait for resolver to tell batter that the pitch resolving is finished
  if (action == constants.ACTION_BATTER_SELECT_ZONE_READY) then
    self.isNextAtBat = params.isNextAtBat
    nextState = constants.STATE_BATTER_RESULT
  end
  return nextState
end

function BatterManager:handleResult(currentState, action, params)
  local nextState = currentState
  if (action == constants.ACTION_BATTER_NEXT_PITCH) then
    -- When the user presses next pitch, go to next pitch
    self.mockServer:updateState(constants.ACTION_RESOLVER_NEXT_PITCH)
    nextState = constants.STATE_BATTER_SWING_SELECT
  elseif (action == constants.ACTION_BATTER_NEXT_BATTER) then
    -- When the user presses next batter, go to next batter
    self.mockServer:updateState(constants.ACTION_RESOLVER_NEXT_BATTER)
    nextState = constants.STATE_BATTER_ATHLETE_SELECT
  end
  return nextState
end

function BatterManager:getDataStore()
  return self.dataStore
end

function BatterManager:getIsNextAtBat()
  return self.isNextAtBat
end

return BatterManager
