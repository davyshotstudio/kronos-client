--------------------------------------------------------------------
-- InningManager is a state machine that manages an individual half inning
-- including managing the outs, runs, bases, and active pitcher and better
-- for a given matchup
--------------------------------------------------------------------

local constants = require("scenes.game.constants")
local config = require("scenes.game.config")
local InningManager = {}

-- Instantiate InningManager (constructor)
function InningManager:new(options)
  local inning = options.inning or 1
  local outs = options.outs or 0
  local runs = options.runs or 0
  local bases = options.bases or {nil, nil, nil}

  -- Lua is indexed off 1 not 0 :/
  local batterIndex = options.batterIndex or 1
  local pitcherIndex = options.pitcherIndex or 1

  local pitchingStaff = options.pitchingStaff
  local battingLineup = options.battingLineup

  -- Initial state for the inning state machine
  local state = STATE_AT_BAT_ONGOING

  local inningManager = {
    inning = inning,
    outs = outs,
    runs = runs,
    bases = bases,
    batterIndex = batterIndex,
    pitcherIndex = pitcherIndex,
    battingLineup = battingLineup,
    pitchingStaff = pitchingStaff,
    state = state
  }

  setmetatable(inningManager, self)
  self.__index = self

  return inningManager
end

-- Update the inning state machine based on an incoming action
function InningManager:updateGameState(action, params)
  if (action == constants.ACTION_HIT) then
    -- If action is a hit, do the following:
    -- (1) update the bases and calculate runs
    -- (2) update the inning state to at bat over
    -- (3) update the batter and pitcher indexes (who's currently at bat/pitching)
    self:resolveBasesAndRuns(params.type)
    self.state = constants.STATE_AT_BAT_END

    -- TODO: update based on user input
    self.batterIndex = params.batterIndex or self.batterIndex + 1
    self.pitcherIndex = params.pitcherIndex or 0
  elseif (action == constants.ACTION_OUT) then
    -- If action is an out, do the following:
    -- (1) update the total outs
    -- (2) if the outs are equal to or more (shouldn't happen) than the
    --     maximum number of outs per inning, then update the state to inning over
    -- (3) otherwise update the batter and pitcher indexes
    -- (4) update the inning state to at bat over
    local outs = self:incrementOuts()
    if outs >= config.MAX_OUTS then
      self.state = constants.STATE_INNING_END
      return self.state
    end

    self.state = constants.STATE_AT_BAT_END
    -- TODO: update based on user input
    self.batterIndex = params.batterIndex or self.batterIndex + 1
    self.pitcherIndex = params.pitcherIndex or 1
  elseif (action == constants.ACTION_FOUL) then
    -- If action is a foul ball, do the following
    -- (1) update the state to at bat ongoing
    self.state = constants.STATE_AT_BAT_ONGOING
  else
    self.state = constants.STATE_AT_BAT_ONGOING
  end

  return self.state
end

-- Update the runners on the bases and calculate the runs scored
function InningManager:resolveBasesAndRuns(type)
  -- TODO: provide correct logic here
  local runs = self:getRuns() + 1
  local bases = self.bases

  self.runs = runs
  self.bases = bases
  return runs, updatedBases
end

-- Update the number of outs by 1
function InningManager:incrementOuts()
  local outs = self:getOuts() + 1
  self.outs = outs
  return outs
end

-------------------------------------
-- Getters for InningManager properties
-------------------------------------

function InningManager:getState()
  return self.state
end

function InningManager:getInning()
  return self.inning
end

function InningManager:getOuts()
  return self.outs
end

function InningManager:getRuns()
  return self.runs
end

function InningManager:getBases()
  return self.bases
end

function InningManager:getCurrentBatter()
  return self.battingLineup[((self.batterIndex - 1) % #self.battingLineup) + 1]
end

function InningManager:getCurrentPitcher()
  return self.pitchingStaff[((self.pitcherIndex - 1) % #self.pitchingStaff) + 1]
end

return InningManager
