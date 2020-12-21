--------------------------------------------------------------------
-- ViewManager manages the state of the UI within a game.
-- UI components should be stored here and managed. This allows us access
-- to any of these components at any time from any place
--------------------------------------------------------------------

local ViewManager = {}

-- Instantiate ViewManager (constructor)
function ViewManager:new(options)
  -- Components is a table with a string key for the component name
  -- and the component as the value
  local viewManager = {
    components = {}
  }

  setmetatable(viewManager, self)
  self.__index = self

  return viewManager
end

-- Insert a component into the ViewManager
function ViewManager:addComponent(componentName, component)
  -- If component name is nil or empty string, throw error
  if (componentName == nil or componentName == "") then
    error("component name cannot be null")
    return
  end
  -- If component exists already, throw error
  if (self:getComponent(componentName) ~= nil) then
    error("component already exists: " .. componentName)
    return
  end

  -- Else store component in the ViewManager
  self.components[componentName] = component
end

-- Retrieve a component from the ViewManager given a key
function ViewManager:getComponent(componentName)
  return self.components[componentName]
end

function ViewManager:removeComponents(componentNames)
  for _, componentName in ipairs(componentNames) do
    local component = self:getComponent(componentName)
    if (component == nil) then
      error("cannot get component: " .. componentName)
    end
    display.remove(component)
    self.components[componentName] = nil
  end
end

return ViewManager
