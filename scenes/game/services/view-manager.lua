--------------------------------------------------------------------
-- ViewManager manages the components of the UI within a game.
-- UI components should be stored here and managed. This allows us access
-- to any of these components at any time from any place and provides
-- custom logic
--------------------------------------------------------------------

local ViewManager = {}

-- Instantiate ViewManager (constructor)
function ViewManager:new(options)
  -- Components is a table with a string key for the component scene name,
  -- with the value being another table that represents the individual
  -- components within the scene
  -- Ex. components = {
  --       "BATTER_SELECTION_SCENE" = {
  --          "TEXT_PITCH_NAME" = display.newText(...)
  --       }
  --     }
  local viewManager = {
    components = {}
  }

  setmetatable(viewManager, self)
  self.__index = self

  return viewManager
end

-- Register the scene name domain in the constructor for each scene.
-- Make sure to do this for each scene or you will have null errors
function ViewManager:registerScene(sceneName)
  self.components[sceneName] = {}
end

-- Insert a component into the ViewManager.
-- Remove the component first if it already exists
function ViewManager:addComponent(sceneName, componentName, component)
  -- If component name is nil or empty string, throw error
  if (componentName == nil or componentName == "") then
    error("component name cannot be null")
    return
  end

  -- If component exists already, remove it first
  if (self:getComponent(sceneName, componentName) ~= nil) then
    self:removeComponents(sceneName, {componentName})
  end

  -- Else store component in the ViewManager
  self.components[sceneName][componentName] = component
end

-- Retrieve a component from the ViewManager given a key
function ViewManager:getComponent(sceneName, componentName)
  return self.components[sceneName][componentName]
end

-- Remove components from the ViewManager given a scene and table of component names
function ViewManager:removeComponents(sceneName, componentNames)
  -- Fetch all the component names in the given scene if not provided
  if (componentNames == nil) then
    local sceneComponents = self.components[sceneName]
    componentNames = {}
    for sceneComponentName, _ in pairs(sceneComponents) do
      table.insert(componentNames, sceneComponentName)
    end
  end

  -- Remove all components from componentNames
  for _, componentName in ipairs(componentNames) do
    local component = self:getComponent(sceneName, componentName)
    if (component ~= nil) then
      display.remove(component)
      self.components[sceneName][componentName] = nil
    end
  end
end

return ViewManager
