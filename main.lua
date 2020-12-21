-----------------------------------------------------------------------------------------
--
-- main.lua
-- This is the entry point for all code execution in Solar2D
--
-----------------------------------------------------------------------------------------

-- Hide the default OS status bar on mobile devices
display.setStatusBar(display.HiddenStatusBar)

-- Include the Corona "composer" module
local composer = require "composer"

-- Seed the random number generator
math.randomseed(os.time())

-- Load menu screen
composer.gotoScene("scenes.game.game")
