-- Scoreboard is a widget that displays the current score between two teams
local composer = require("composer")

local function inningTracker(parentSceneGroup, sceneName)
  -- Retrieve DI instances of the managers
  local viewManager = composer.getVariable("viewManager")
  local batterManager = composer.getVariable("batterManager")

  -- Register scene domain into the ViewManager
  viewManager:registerScene(sceneName)

  local sceneGroup = display.newGroup()
  parentSceneGroup:insert(sceneGroup)
  sceneGroup.anchorX = 0
  sceneGroup.anchorY = 0
  sceneGroup.y = 30

  local outsCount = batterManager:getDataStore():getOuts()
  local ballsCount, strikesCount = batterManager:getDataStore():getCount()
  local inningCount = batterManager:getDataStore():getInning()

  local outs = "Outs: " .. outsCount or ""
  local balls = "Balls: " .. ballsCount or ""
  local strikes = "Strikes: " .. strikesCount or ""
  local inning = inningCount or ""

  viewManager:addComponent(
    sceneName,
    "INNING_TRACKER_BACKGROUND",
    (function()
      local background = display.newRoundedRect(sceneGroup, 0, 0, 200, 50, 10)
      background.anchorX = 0
      background.anchorY = 0
      background:setFillColor(0.85)
      return background
    end)()
  )

  -- Offset for the balls/strikes/outs from the inning label
  local xBodyOffset = 50
  local defaultFontSize = 12

  viewManager:addComponent(
    sceneName,
    "TEXT_OUTS",
    (function()
      local text = display.newText(sceneGroup, outs, 400, 80, "asul.ttf", defaultFontSize)
      text.anchorX = 0
      text.anchorY = 0
      text.x = xBodyOffset
      text.y = 2
      text:setFillColor(0)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_BALLS",
    (function()
      local text = display.newText(sceneGroup, balls, 400, 80, "asul.ttf", defaultFontSize)
      text.anchorX = 0
      text.anchorY = 0
      text.x = xBodyOffset
      text.y = 16
      text:setFillColor(0)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_STRIKES",
    (function()
      local text = display.newText(sceneGroup, strikes, 400, 80, "asul.ttf", defaultFontSize)
      text.anchorX = 0
      text.anchorY = 0
      text.x = xBodyOffset
      text.y = 30
      text:setFillColor(0)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_INNING",
    (function()
      local text = display.newText(sceneGroup, inning, 400, 80, "asul.ttf", 20)
      text.x = 25
      text.y = 25
      text:setFillColor(0)
      return text
    end)()
  )
end

return inningTracker
