--------------------------------------------------------------------
-- SceneRouter is a centralized router for navigation.
-- It helps determine what scene to navigate to based on the
-- provided state inside the core game experience
--------------------------------------------------------------------
local composer = require("composer")
local constants = require("scenes.game.utilities.constants")

local SceneRouter = {}

local SCENE_TITLES = {
  BATTER_START_SCENE = "game",
  BATTER_ATHLETE_SELECTION_SCENE = "batter-athlete-selection-scene",
  BATTER_STRIKE_ZONE_CREATION_SCENE = "batter-strike-zone-creation-scene",
  BATTER_SWING_SELECTION_SCENE = "batter-swing-selection-scene",
  BATTER_RESULT_SCENE = "batter-result-scene"
}

-- Instantiate SceneRouter (constructor)
function SceneRouter:new(options)
  local dataStore = options.dataStore
  local id = options.id or 0

  local sceneRouter = {
    id = id,
    dataStore = dataStore
  }

  setmetatable(sceneRouter, self)
  self.__index = self

  return sceneRouter
end

-- Handler to listen to changes in the state
function SceneRouter:registerStateListener()
  self.dataStore:addStateListener(self.nextScene)
end

-- SceneRouter:navigateToScene gets the next scene to go to given
-- a provided state. This gives us a centralized place
-- to refer to for core game scene navigation instead of having
-- spaghetti navigation code being determined by each scene. This
-- also makes it easy for us to listen to state changes from the server
-- and route accordingly.
function SceneRouter:nextScene(currentState, nextState)
  -- Retrieve current client stat
  local stateSceneMapper = {
    -- Batter flow scenes
    STATE_BATTER_START = SCENE_TITLES.BATTER_START_SCENE,
    STATE_BATTER_ATHLETE_SELECT = SCENE_TITLES.BATTER_ATHLETE_SELECTION_SCENE,
    STATE_BATTER_ZONE_CREATE = SCENE_TITLES.BATTER_STRIKE_ZONE_CREATION_SCENE,
    STATE_BATTER_SWING_SELECT = SCENE_TITLES.BATTER_SWING_SELECTION_SCENE,
    STATE_BATTER_PENDING_PITCH = SCENE_TITLES.BATTER_SWING_SELECTION_SCENE,
    STATE_BATTER_RESULT = SCENE_TITLES.BATTER_RESULT_SCENE
    -- Pitcher flow scenes
  }

  local sceneName = stateSceneMapper[nextState]
  if (sceneName == nil or sceneName == "") then
    error("invalid scene to navigate to in the router")
  end

  composer.gotoScene("scenes.game." .. sceneName)
end

-------------------------------------
-- Getters for SceneRouter properties
-------------------------------------

function SceneRouter:getId()
  return self.id
end

return SceneRouter
