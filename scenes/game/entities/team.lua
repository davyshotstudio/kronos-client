--------------------------------------------------------------------
-- Team represents one of the teams information
--------------------------------------------------------------------

local Team = {}

-- Instantiate Team (constructor)
function Team:new(options)
  local id = options.id or 0
  local name = options.name or "Team"

  local team = {
    id = id,
    name = name
  }

  setmetatable(team, self)
  self.__index = self

  return team
end

-------------------------------------
-- Getters for Team properties
-------------------------------------

function Team:getID()
  return self.id
end

function Team:getName()
  return self.name
end

return Team
