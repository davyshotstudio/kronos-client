--------------------------------------------------------------------
-- AtBatManager is a state machine that manages an individual at bat
-- between a pitcher and a batter, including calculating the result of
-- of an at bat
--------------------------------------------------------------------

local constants = require("scenes.game.constants")
local config = require("scenes.game.config")
local AtBatManager = {}

-- Instantiate AtBatManager (constructor)
function AtBatManager:new(options)
  local balls = options.balls or 0
  local strikes = options.strikes or 0
  local state = constants.NONE

  local atBatManager = {
    balls = balls,
    strikes = strikes,
    state = state
  }

  setmetatable(atBatManager, self)
  self.__index = self

  return atBatManager
end

-- Roll a random result between the player's floor and ceiling
-- TODO: add additional logic for determining the roll
local function roll(player)
  return math.random(player:getSkill():getFloor(), player:getSkill():getCeiling())
end

-- Run the matchup for a single pitch
function AtBatManager:throwPitch(pitcher, batter)
  local pitcherRoll = roll(pitcher)
  local batterRoll = roll(batter)

  local resultState = self:updateState(pitcherRoll, batterRoll)

  return resultState, pitcherRoll, batterRoll
end

-- Update state machine for the at bat
function AtBatManager:updateState(pitcherRoll, batterRoll)
  local result = batterRoll - pitcherRoll

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
  self.state = state
  return state
end

function AtBatManager:getState()
  return self.state
end

return AtBatManager
