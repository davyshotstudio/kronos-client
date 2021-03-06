--------------------------------------------------------------------
-- Pitch represents an individual pitch including type and action
--------------------------------------------------------------------

local Pitch = {}

-- Instantiate Pitch (constructor)
function Pitch:new(options)
  local id = options.id
  local name = options.name or ""
  local abbreviation = options.abbreviation or ""
  local iconURL = options.iconURL or ""

  local pitch = {
    id = id,
    name = name,
    abbreviation = abbreviation,
    iconURL = iconURL
  }

  setmetatable(pitch, self)
  self.__index = self

  return pitch
end

-------------------------------------
-- Getters for Pitch properties
-------------------------------------

function Pitch:getID()
  return self.id
end

function Pitch:getName()
  return self.name
end

function Pitch:getAbbreviation()
  return self.abbreviation
end

function Pitch:getIconURL()
  return self.iconURL
end

return Pitch
