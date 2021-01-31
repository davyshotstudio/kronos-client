--------------------------------------------------------------------
-- Action is an entity that represents a given action entity that
-- can store the effects and modifiers of an action
--------------------------------------------------------------------

local Action = {}

-- Instantiate Action (constructor)
function Action:new(options)
  local id = options.id
  local name = options.name or ""
  local description = options.description or ""
  local pictureURL = options.pictureURL or ""
  local skill = options.skill
  -- type can be a PITCHER or BATTER action type
  local type = options.type

  local action = {
    id = id,
    name = name,
    description = description,
    pictureURL = pictureURL,
    skill = skill
  }

  setmetatable(action, self)
  self.__index = self

  return action
end

-------------------------------------
-- Getters for Action properties
-------------------------------------

function Action:getID()
  return self.id
end

function Action:getName()
  return self.name
end

function Action:getPictureURL()
  return self.pictureURL
end

function Action:getDescription()
  return self.description
end

function Action:getSkill()
  return self.skill
end

function Action:getType()
  return self.type
end

return Action
