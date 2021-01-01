--------------------------------------------------------------------
-- BatterManager is a state machine that manages an individual at bat
-- between a pitcher and a batter, including calculating the result of
-- of an at bat
--------------------------------------------------------------------

local constants = require("scenes.game.constants")
local config = require("scenes.game.config")
local BatterManager = {}

-- Instantiate BatterManager (constructor)
function BatterManager:new(options)
  local state = constants.STATE_BATTER_ZONE_SELECT
  local selectedZone = -1
  local resolverManager = options.resolverManager
  -- If true, we're still in the at bat (result was a strike or ball or foul)
  local isNextAtBat = false

  local batterManager = {
    state = state,
    selectedZone = selectedZone,
    isNextAtBat = isNextAtBat,
    resolverManager = resolverManager
  }

  setmetatable(batterManager, self)
  self.__index = self

  return batterManager
end

function BatterManager:updateGameState(action, params)
  if (self.state == constants.STATE_BATTER_ZONE_SELECT) then
    -- When the user selects a zone:
    -- (1) Mark zone as selected
    -- (2) Update the state to STATE_BATTER_PITCH_PENDING to wait for other player
    if (action == constants.ACTION_BATTER_SELECT_ZONE) then
      self.selectedZone = params.selectedZone
      self.resolverManager:updateState(
        constants.ACTION_RESOLVER_BATTER_SELECT_ZONE,
        {batterSelectedZone = params.selectedZone}
      )
      -- TODO (wilbert): Remove this when pitcher flow exists, for now this is manually triggering a "fake" pitcher zone select
      self.resolverManager:updateState(constants.ACTION_RESOLVER_PITCHER_SELECT_ZONE, {pitcherSelectedZone = 1})
      self.state = constants.STATE_BATTER_PENDING_PITCH
    end
  elseif (self.state == constants.STATE_BATTER_PENDING_PITCH) then
    -- Wait for resolver to tell batter that the pitch resolving is finished
    -- TODO: in the future, this needs to be triggered by a server
    if (action == constants.ACTION_BATTER_RESOLVE_PITCH) then
      self.state = constants.STATE_BATTER_RESULT
      if (self.resolverManager:getState() == constants.STATE_PLAYERS_PITCH_RESOLVED) then
        self.isNextAtBat = false
      elseif (self.resolverManager:getState() == constants.STATE_PLAYERS_AT_BAT_RESOLVED) then
        self.isNextAtBat = true
      end
    end
  elseif (self.state == constants.STATE_BATTER_RESULT) then
    if (action == constants.ACTION_BATTER_NEXT_PITCH) then
      -- When the user presses next pitch, go to next pitch
      self.state = constants.STATE_BATTER_ZONE_SELECT
      self.resolverManager:updateState(constants.ACTION_RESOLVER_NEXT_PITCH)
    elseif (action == constants.ACTION_BATTER_NEXT_BATTER) then
      -- When the user presses next batter, go to next batter
      self.state = constants.STATE_BATTER_ZONE_SELECT
      self.resolverManager:updateState(constants.ACTION_RESOLVER_NEXT_BATTER)
    end
  end

  return self.state
end

function BatterManager:getState()
  return self.state
end

function BatterManager:getResolverManager()
  return self.resolverManager
end

function BatterManager:getIsNextAtBat()
  return self.isNextAtBat
end

return BatterManager
