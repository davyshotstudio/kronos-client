--------------------------------------------------------------------
-- MockServer simulates the logic of the server backend
--------------------------------------------------------------------

local constants = require("scenes.game.utilities.constants")
local config = require("scenes.game.utilities.config")
-- TODO: Remove when no more mocks are needed
local mockData = require("scenes.game.utilities.fixtures.mock-data")

local MockServer = {}

-- Instantiate MockServer (constructor)
function MockServer:new(options)
  local dataStore = options.dataStore
  local socketManager = options.socketManager
  local serverState = constants.STATE_PLAYERS_ATHLETE_PENDING

  local mockServer = {
    dataStore = dataStore,
    socketManager = socketManager,
    -- Mock state of the server state machine
    serverState = serverState
  }

  setmetatable(mockServer, self)
  self.__index = self

  return mockServer
end

function MockServer:updateState(action, params)
  local newServerState = constants.STATE_PLAYERS_ATHLETE_PENDING
  print("serverState: " .. self.serverState)
  if (self.serverState == constants.STATE_PLAYERS_ATHLETE_PENDING) then
    if (action == constants.ACTION_RESOLVER_BATTER_SELECT_ATHLETE) then
      self.dataStore:setBatter(params.selectedBatterCard)
      newServerState = constants.STATE_PLAYERS_ZONE_CREATION_PENDING
    -- local message = {
    --   state = "x"
    -- }
    -- self.socketManager:sendMessage({statusCode = 200, type = "game_update", body = message})
    end
  elseif (self.serverState == constants.STATE_PLAYERS_ZONE_CREATION_PENDING) then
    if (action == constants.ACTION_RESOLVER_BATTER_CREATE_ZONE) then
      self.dataStore:setInPlayBatterActionCardsMap(params.inPlayBatterActionCardsMap)
      -- local message = {
      --   state = "x"
      -- }
      -- self.socketManager:sendMessage({statusCode = 200, type = "game_update", body = message})
      newServerState = constants.STATE_PLAYERS_PITCH_PENDING
    end
  elseif (self.serverState == constants.STATE_PLAYERS_PITCH_PENDING) then
    if (action == constants.ACTION_RESOLVER_BATTER_SELECT_ZONE) then
      self.dataStore:setBatterGuessedZone(params.batterGuessedZone)
    end

    if (action == constants.ACTION_RESOLVER_PITCHER_SELECT_ZONE) then
      self.dataStore:setPitcherSelectedZone(params.pitcherSelectedZone)
    end

    if (self.dataStore:getBatterGuessedZone() > -1 and self.dataStore:getPitcherSelectedZone() > -1) then
      -- Resolve the pitch
      local pitchResultState, pitcherRoll, batterRoll =
        self:resolvePitch(self.dataStore:getPitcher(), self.dataStore:getBatter())
      self.dataStore:setPitchResultState(pitchResultState)
      newServerState = constants.STATE_PLAYERS_PITCH_RESOLVED
      -- If the pitch is a terminal pitch (results in a hit or out or walk), move state to at bat finished
      if
        (pitchResultState ~= constants.BALL and pitchResultState ~= constants.STRIKE and
          pitchResultState ~= constants.FOUL)
       then
        newServerState = constants.STATE_PLAYERS_AT_BAT_RESOLVED
        self.dataStore:setCountBalls(0)
        self.dataStore:setCountStrikes(0)
      end

      -- Send message to the clients of the pitch result
      local message = {}
      self.socketManager:sendMessage({statusCode = 200, type = "game_update", body = message})

    -- Reset batter/pitcher selected zones
    -- self.pitcherSelectedZone = -1
    -- self.batterGuessedZone = -1
    end
  elseif (self.serverState == constants.STATE_PLAYERS_PITCH_RESOLVED) then
    if (action == constants.ACTION_RESOLVER_NEXT_PITCH) then
      newServerState = constants.STATE_PLAYERS_PITCH_PENDING

      local message = {
        state = "STATE_PLAYERS_AT_BAT_RESOLVED"
      }
      self.socketManager:sendMessage({statusCode = 200, type = "game_update", body = message})
    end
  elseif (self.serverState == constants.STATE_PLAYERS_AT_BAT_RESOLVED) then
    -- If both pitcher and batter player are ready for the next at bat,
    -- move to the next player
    if (action == constants.ACTION_RESOLVER_NEXT_BATTER) then
      newServerState = constants.STATE_PLAYERS_PITCH_PENDING
    -- TODO (wilbert): reset at bat
    end
  end

  self.serverState = newServerState
  return newServerState
end

-- Roll a random result between the player's floor and ceiling
-- TODO: add additional logic for determining the roll
local function roll(player)
  return math.random(player:getSkill():getFloor(), player:getSkill():getCeiling())
end

function MockServer:resolvePitch(pitcher, batter)
  local pitcherRoll = roll(pitcher)
  local batterRoll = roll(batter)

  local pitchResultState = self:calculatePitchResultState(pitcherRoll, batterRoll)
  local balls, strikes = self.dataStore:getCount()
  if (pitchResultState == constants.BALL) then
    self.dataStore:setCountBalls(balls + 1)
    if (balls >= config.MAX_BALLS) then
      pitchResultState = constants.WALK
    end
  end
  if (pitchResultState == constants.STRIKE) then
    self.dataStore:setCountStrikes(strikes + 1)
    if (strikes >= config.MAX_STRIKES) then
      pitchResultState = constants.STRIKEOUT
    end
  end
  self.dataStore:setLastRollsPitcher(pitcherRoll)
  self.dataStore:setLastRollsBatter(batterRoll)
  return pitchResultState, pitcherRoll, batterRoll
end

function MockServer:calculatePitchResultState(pitcherRoll, batterRoll)
  local result = batterRoll - pitcherRoll

  -- If zone is 0, that means that the batter isn't swinging
  -- Check the potential for a ball
  if (self.dataStore:getBatterGuessedZone() == 0) then
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
