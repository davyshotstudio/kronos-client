--------------------------------------------------------------------
-- SceneRouter is a centralized router for navigation.
-- It helps determine what scene to navigate to based on the
-- provided state inside the core game experience
--------------------------------------------------------------------
local composer = require("composer")

local SceneRouter = {}

local SCENE_STATES = {
  BATTER_ATHLETE_SELECTION_SCENE = "batter-athlete-selection-scene",
  BATTER_STRIKE_ZONE_CREATION_SCENE = "batter-strike-zone-creation-scene",
  BATTER_SWING_SELECTION_SCENE = "batter-swing-selection-scene",
  BATTER_RESULT_SCENE = "batter-result-scene"
}

-- Instantiate SceneRouter (constructor)
function SceneRouter:new(options)
  local id = options.id
  local state = options.state

  local sceneRouter = {
    id = id,
    state = state
  }

  setmetatable(sceneRouter, self)
  self.__index = self

  self.registerServerListener()

  return sceneRouter
end

function SceneRouter:registerServerListener()
  -- If the server state updates, trigger nextScene()
  self.nextScene()
end

-------------------------------------
-- Getters for SceneRouter properties
-------------------------------------

-- SceneRouter:navigateToScene infers the next scene to go to
-- based on the current page. This gives us a centralized place
-- to refer to for core game scene navigation instead of having
-- spaghetti navigation code being determined by each scene. This
-- also makes it easy for us to listen to state changes from the server
-- and route accordingly
function SceneRouter:nextScene(param)
  local state = self.state
  -- Batter flow scenes
  if (self.state == SCENE_STATES.BATTER_ATHLETE_SELECTION_SCENE) then
    self.state = SCENE_STATES.BATTER_STRIKE_ZONE_CREATION_SCENE
  elseif (self.state == SCENE_STATES.BATTER_STRIKE_ZONE_CREATION_SCENE) then
    self.state = SCENE_STATES.BATTER_SWING_SELECTION_SCENE
  elseif (self.state == SCENE_STATES.BATTER_SWING_SELECTION_SCENE) then
    self.state = SCENE_STATES.BATTER_RESULT_SCENE
  elseif (self.state == SCENE_STATES.BATTER_RESULT_SCENE) then
    -- If half inning is over, swap batter to the pitcher
    if (params.nextBatter) then
    end
  end
  -- Pitcher flow scenes
  -- Common game scenes
  -- else
  --   error("SceneRouter is in an invalid state: " .. state)
  -- end

  self.state = state
  composer.gotoScene(state)
end

function SceneRouter:getId()
  return self.id
end

function SceneRouter:getState()
  return self.state
end

return SceneRouter
