-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

-- Include Corona's "physics" library
local physics = require "physics"

-- Constant for root path to local asset folder
local ASSET_PATH = "scenes/game/assets/"

--------------------------------------------

-- Forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create(event)
	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()

	-- Create a grey rectangle as the backdrop.
	-- The physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect(display.screenOriginX, display.screenOriginY, screenW, screenH)
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor(.5)

	-- Make a crate (off-screen), position it, and rotate slightly
	local crate = display.newImageRect(ASSET_PATH .. "crate.png", 90, 90)
	crate.x, crate.y = 160, -100
	crate.rotation = 15

	-- Add physics to the crate
	physics.addBody(crate, {density = 1.0, friction = 0.3, bounce = 0.3})

	-- Create a grass object and add physics (with custom shape)
	local grass = display.newImageRect(ASSET_PATH .. "grass.png", screenW, 82)
	grass.anchorX = 0
	grass.anchorY = 1
	--  Draw the grass at the very bottom of the screen
	grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY

	-- Define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = {-halfW, -34, halfW, -34, halfW, 34, -halfW, 34}
	physics.addBody(grass, "static", {friction = 0.3, shape = grassShape})

	-- All display objects must be inserted into group
	sceneGroup:insert(background)
	sceneGroup:insert(grass)
	sceneGroup:insert(crate)
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide(event)
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
	-- Called when the scene is now off screen
	end
end

function scene:destroy(event)
	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

return scene
