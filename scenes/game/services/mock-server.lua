--------------------------------------------------------------------
-- MockServer simulates the logic of the server backend
--------------------------------------------------------------------

local constants = require("scenes.game.utilities.constants")
local config = require("scenes.game.utilities.config")
local mockData = require("scenes.game.utilities.fixtures.mock-data")

local MockServer = {}

-- Instantiate MockServer (constructor)
function MockServer:new(options)
  local dataStore = options.dataStore
  local socketManager = options.socketManager
  local serverState = constants.STATE_PLAYERS_ATHLETE_PENDING
  local mockServerDataStore = {
    batterGuessedZone = -1,
    pitcherSelectedZone = -1,
    balls = 0,
    strikes = 0,
    outs = 0
  }

  local mockServer = {
    socketManager = socketManager,
    -- Mock state of the server state machine
    serverState = serverState,
    dataStore = dataStore,
    mockServerDataStore = mockServerDataStore
  }

  setmetatable(mockServer, self)
  self.__index = self

  return mockServer
end

function MockServer:sendMockGameUpdateEvent(eventAction, eventActionParams, message)
  self.socketManager:sendMessage(
    {
      statusCode = 200,
      type = "game_update",
      eventAction = eventAction,
      eventActionParams = eventActionParams,
      body = message
    }
  )
end

function MockServer:updateState(action, params)
  local stateActionMapping = {
    [constants.STATE_PLAYERS_ATHLETE_PENDING] = self.handleAthletePending,
    [constants.STATE_PLAYERS_ZONE_CREATION_PENDING] = self.handleZoneCreationPending,
    [constants.STATE_PLAYERS_PITCH_PENDING] = self.handlePitchPending,
    [constants.STATE_PLAYERS_PITCH_RESOLVED] = self.handlePitchResolved,
    [constants.STATE_PLAYERS_AT_BAT_RESOLVED] = self.handleAtBatResolved
  }

  if (stateActionMapping[self.serverState] == nil) then
    error("server state not handled in mock-server: " .. self.serverState)
  end

  local newServerState = stateActionMapping[self.serverState](self, action, params)
  if (newServerState == nil or newServerState == "") then
    error("new server state is invalid: " .. newServerState)
  end

  self.serverState = newServerState
  return newServerState
end

function MockServer:handleAthletePending(action, params)
  local newServerState = self.serverState
  if (action == constants.ACTION_RESOLVER_BATTER_SELECT_ATHLETE) then
    self:sendMockGameUpdateEvent(
      constants.ACTION_BATTER_SELECT_ATHLETE_READY,
      nil,
      {
        batter = params.selectedBatterCard,
        pitcher = mockData.pitchingStaff[1]
      }
    )

    newServerState = constants.STATE_PLAYERS_ZONE_CREATION_PENDING
  end
  return newServerState
end

function MockServer:handleZoneCreationPending(action, params)
  local newServerState = self.serverState
  if (action == constants.ACTION_RESOLVER_BATTER_CREATE_ZONE) then
    self:sendMockGameUpdateEvent(
      constants.ACTION_BATTER_CREATE_ZONE_READY,
      nil,
      {
        inPlayBatterActionCardsMap = params.inPlayBatterActionCardsMap,
        inPlayPitcherActionCardsMap = mockData.inPlayPitcherActionCardsMap
      }
    )
    newServerState = constants.STATE_PLAYERS_PITCH_PENDING
  end
  return newServerState
end

function MockServer:handlePitchPending(action, params)
  local newServerState = self.serverState
  if (action == constants.ACTION_RESOLVER_BATTER_SELECT_ZONE) then
    self.mockServerDataStore.batterGuessedZone = params.batterGuessedZone
    -- Simulate pitcher making a zone selection
    self.mockServerDataStore.pitcherSelectedZone = 1
  end

  if (self.mockServerDataStore.batterGuessedZone > -1 and self.mockServerDataStore.pitcherSelectedZone > -1) then
    -- Resolve the pitch
    local pitchResultState, pitcherRoll, batterRoll =
      self:resolvePitch(self.dataStore:getPitcher(), self.dataStore:getBatter())
    newServerState = constants.STATE_PLAYERS_PITCH_RESOLVED
    isNextAtBat = false
    -- If the pitch is a terminal pitch (results in a hit or out or walk), move state to at bat finished
    if
      (pitchResultState ~= constants.BALL and pitchResultState ~= constants.STRIKE and
        pitchResultState ~= constants.FOUL)
     then
      newServerState = constants.STATE_PLAYERS_AT_BAT_RESOLVED
      isNextAtBat = true
      self.mockServerDataStore.balls = 0
      self.mockServerDataStore.strikes = 0
      if (pitchResultState == constants.OUT) then
        self.outs = self.outs + 1
      end
    end

    self:sendMockGameUpdateEvent(
      constants.ACTION_BATTER_SELECT_ZONE_READY,
      {
        isNextAtBat = isNextAtBat
      },
      {
        pitchResultState = pitchResultState,
        balls = self.mockServerDataStore.balls,
        strikes = self.mockServerDataStore.strikes,
        outs = self.mockServerDataStore.outs,
        lastRollsPitcher = pitcherRoll,
        lastRollsBatter = batterRoll
      }
    )
  end
  return newServerState
end

function MockServer:handleAtBatResolved(action, params)
  local newServerState = self.serverState
  -- If both pitcher and batter player are ready for the next at bat,
  -- move to the next player
  if (action == constants.ACTION_RESOLVER_NEXT_BATTER) then
    newServerState = constants.STATE_PLAYERS_ATHLETE_PENDING
  end
  return newServerState
end

function MockServer:handlePitchResolved(action, params)
  local newServerState = self.serverState
  if (action == constants.ACTION_RESOLVER_NEXT_PITCH) then
    newServerState = constants.STATE_PLAYERS_PITCH_PENDING
  end
  return newServerState
end

-- ------------------------------
-- Mock helper methods
-- ------------------------------

-- Roll a random result between the player's floor and ceiling
-- Roughly mocking the response from the real server, which is what is really resolving this logic
local function roll(player)
  return math.random(player:getSkill():getFloor(), player:getSkill():getCeiling())
end

function MockServer:resolvePitch(pitcher, batter)
  local pitcherRoll = roll(pitcher)
  local batterRoll = roll(batter)

  local pitchResultState = self:calculatePitchResultState(pitcherRoll, batterRoll)
  local balls, strikes = self.mockServerDataStore.balls, self.mockServerDataStore.strikes
  if (pitchResultState == constants.BALL) then
    self.mockServerDataStore.balls = balls + 1
    if (self.mockServerDataStore.balls >= config.MAX_BALLS) then
      pitchResultState = constants.WALK
    end
  end
  if (pitchResultState == constants.STRIKE) then
    self.mockServerDataStore.strikes = strikes + 1
    if (self.mockServerDataStore.strikes >= config.MAX_STRIKES) then
      pitchResultState = constants.STRIKEOUT
    end
  end
  return pitchResultState, pitcherRoll, batterRoll
end

function MockServer:calculatePitchResultState(pitcherRoll, batterRoll)
  local result = batterRoll - pitcherRoll

  -- If zone is 0, that means that the batter isn't swinging
  -- Check the potential for a ball
  if (self.mockServerDataStore.batterGuessedZone == 0) then
    if (batterRoll * 1.2 > pitcherRoll) then
      state = constants.BALL
    else
      state = constants.STRIKE
    end
    return state
  end

  -- Positive value means batter wins,
  -- negative value means pitcher wins,
  -- tie means foul ball
  if (result == 0) then
    state = constants.FOUL
  elseif (result > config.TRIPLE_CUTOFF) then
    state = constants.HOME_RUN
  elseif (result > config.DOUBLE_CUTOFF) then
    state = constants.TRIPLE
  elseif (result > config.SINGLE_CUTOFF) then
    state = constants.DOUBLE
  elseif (result > 0) then
    state = constants.SINGLE
  elseif (result < 0) then
    state = constants.OUT
  end

  -- Update state machine and return state
  return state
end

return MockServer
