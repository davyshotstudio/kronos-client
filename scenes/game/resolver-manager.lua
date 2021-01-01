--------------------------------------------------------------------
--
--------------------------------------------------------------------

local constants = require("scenes.game.constants")
local config = require("scenes.game.config")
local ResolverManager = {}

-- TODO: Remove when no more mocks are needed
local mockData = require("scenes.game.mock-data")

-- Instantiate ResolverManager (constructor)
function ResolverManager:new(options)
  local state = constants.STATE_PLAYERS_PITCH_PENDING
  local pitchResultState = constants.NONE
  local balls = options.balls or 0
  local strikes = options.strikes or 0
  local pitcher = options.pitcher or mockData.pitchingStaff[1]
  local batter = options.batter or mockData.battingLineup[1]
  local pitcherSelectedZone = options.pitcherSelectedZone or 0
  local batterSelectedZone = options.batterSelectedZone or 0
  local lastPitcherRoll = -1
  local lastBatterRoll = -1

  local resolverManager = {
    state = state,
    pitchResultState = pitchResultState,
    balls = balls,
    strikes = strikes,
    pitcher = pitcher,
    batter = batter,
    pitcherSelectedZone = pitcherSelectedZone,
    batterSelectedZone = batterSelectedZone,
    lastPitcherRoll = lastPitcherRoll,
    lastBatterRoll = lastBatterRoll
  }

  setmetatable(resolverManager, self)
  self.__index = self

  return resolverManager
end

function ResolverManager:updateState(action, params)
  if (self.state == constants.STATE_PLAYERS_PITCH_PENDING) then
    if (action == constants.ACTION_RESOLVER_BATTER_SELECT_ZONE) then
      self.batterSelectedZone = params.batterSelectedZone
    end

    if (action == constants.ACTION_RESOLVER_PITCHER_SELECT_ZONE) then
      self.pitcherSelectedZone = params.pitcherSelectedZone
    end

    if (self.batterSelectedZone > -1 and self.pitcherSelectedZone > -1) then
      -- Resolve the pitch
      local pitchResultState, pitcherRoll, batterRoll = self:resolvePitch(self.pitcher, self.batter)
      print("resp;ve: " .. pitchResultState)
      self.pitchResultState = pitchResultState
      self.state = constants.STATE_PLAYERS_PITCH_RESOLVED
      -- If the pitch is a terminal pitch (results in a hit or out or walk), move state to at bat finished
      if
        (pitchResultState ~= constants.BALL and pitchResultState ~= constants.STRIKE and
          pitchResultState ~= constants.FOUL)
       then
        self.state = constants.STATE_PLAYERS_AT_BAT_RESOLVED
        self.balls = 0
        self.strikes = 0
      end

      -- Reset batter/pitcher selected zones
      self.pitcherSelectedZone = -1
      self.batterSelectedZone = -1
    end
  elseif (self.state == constants.STATE_PLAYERS_PITCH_RESOLVED) then
    if (action == constants.ACTION_RESOLVER_NEXT_PITCH) then
      self.state = constants.STATE_PLAYERS_PITCH_PENDING
    end
  elseif (self.state == constants.STATE_PLAYERS_AT_BAT_RESOLVED) then
    -- If both pitcher and batter player are ready for the next at bat,
    -- move to the next player
    if (action == constants.ACTION_RESOLVER_NEXT_BATTER) then
      self.state = constants.STATE_PLAYERS_PITCH_PENDING
    -- TODO (wilbert): reset at bat
    end
  end

  return self.state
end

-- Roll a random result between the player's floor and ceiling
-- TODO: add additional logic for determining the roll
local function roll(player)
  return math.random(player:getSkill():getFloor(), player:getSkill():getCeiling())
end

-- Run the matchup for a single pitch
function ResolverManager:resolvePitch(pitcher, batter)
  local pitcherRoll = roll(pitcher)
  local batterRoll = roll(batter)

  local pitchResultState = self:calculatePitchResultState(pitcherRoll, batterRoll)
  if (pitchResultState == constants.BALL) then
    self.balls = self.balls + 1
    if (self.balls >= config.MAX_BALLS) then
      pitchResultState = constants.WALK
    end
  end
  if (pitchResultState == constants.STRIKE) then
    self.strikes = self.strikes + 1
    if (self.strikes >= config.MAX_STRIKES) then
      pitchResultState = constants.STRIKEOUT
    end
  end
  self.lastPitcherRoll = pitcherRoll
  self.lastBatterRoll = batterRoll
  return pitchResultState, pitcherRoll, batterRoll
end

-- Update state machine for the at bat
function ResolverManager:calculatePitchResultState(pitcherRoll, batterRoll)
  local result = batterRoll - pitcherRoll

  -- If zone is 0, that means that the batter isn't swinging
  -- Check the potential for a ball
  if (self.batterSelectedZone == 0) then
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

function ResolverManager:getState()
  return self.state
end

function ResolverManager:getLastRolls()
  return self.lastPitcherRoll, self.lastBatterRoll
end

function ResolverManager:getPitchResultState()
  return self.pitchResultState
end

return ResolverManager
