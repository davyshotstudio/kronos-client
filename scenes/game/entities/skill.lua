--------------------------------------------------------------------
-- Skill represents the roll ranges including ceiling and floor
--------------------------------------------------------------------

local Skill = {}

-- Instantiate Skill (constructor)
function Skill:new(options)
  local floor = options.floor or 0
  local ceiling = options.ceiling or 100

  local skill = {
    floor = floor,
    ceiling = ceiling
  }

  setmetatable(skill, self)
  self.__index = self

  return skill
end

-------------------------------------
-- Getters for Skill properties
-------------------------------------

function Skill:getFloor()
  return self.floor
end

function Skill:getCeiling()
  return self.ceiling
end

return Skill
