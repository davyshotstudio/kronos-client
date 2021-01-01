--------------------------------------------------------------------
-- ActionCard is an entity that represents a given action card that
-- the player will play to enhance their actions, contains a pitcher
-- and a batter action
--------------------------------------------------------------------

local ActionCard = {}

-- Instantiate Action Card (constructor)
function ActionCard:new(options)
  local id = options.id
  local pictureURL = options.pictureURL or ""
  local pitchingAction = options.pitchingAction
  local battingAction = options.battingAction

  local actionCard = {
    id = id,
    pictureURL = pictureURL,
    pitchingAction = pitchingAction,
    battingAction = battingAction
  }

  setmetatable(actionCard, self)
  self.__index = self

  return actionCard
end

-------------------------------------
-- Getters for ActionCard properties
-------------------------------------

function ActionCard:getId()
  return self.id
end

function ActionCard:getPictureURL()
  return self.pictureURL
end

function ActionCard:getPitchingAction()
  return self.pitchingAction
end

function ActionCard:getBattingAction()
  return self.battingAction
end

return ActionCard
