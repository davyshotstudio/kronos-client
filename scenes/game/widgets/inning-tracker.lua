-- Scoreboard is a widget that displays the current score between two teams
local composer = require("composer")
local config = require("scenes.game.utilities.config")

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

  local outs = "Outs: "
  local balls = "Balls: "
  local strikes = "Strikes: "
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
  local defaultFontSize = 10

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

  for i = 1, config.MAX_OUTS do
    viewManager:addComponent(
      sceneName,
      "OUTS_MARKER_" .. i,
      (function()
        local outsView = display.newRoundedRect(sceneGroup, 0, 0, 8, 8, 4)
        outsView.anchorX = 0
        outsView.anchorY = 0
        outsView.x = xBodyOffset + 22 + (15 * i)
        outsView.y = 2 + 2
        outsView:setFillColor(0, 0, 1)
        outsView:setStrokeColor(0.25)
        outsView.strokeWidth = 1
        if (i > outsCount) then
          outsView:setFillColor(1)
        end
        return outsView
      end)()
    )
  end

  viewManager:addComponent(
    sceneName,
    "TEXT_BALLS",
    (function()
      local text = display.newText(sceneGroup, balls, 400, 80, "asul.ttf", defaultFontSize)
      text.anchorX = 0
      text.anchorY = 0
      text.x = xBodyOffset
      text.y = 18
      text:setFillColor(0)
      return text
    end)()
  )

  for i = 1, config.MAX_BALLS do
    viewManager:addComponent(
      sceneName,
      "BALLS_MARKER_" .. i,
      (function()
        local ballsView = display.newRoundedRect(sceneGroup, 0, 0, 8, 8, 4)
        ballsView.anchorX = 0
        ballsView.anchorY = 0
        ballsView.x = xBodyOffset + 22 + (15 * i)
        ballsView.y = 18 + 2
        ballsView:setFillColor(0, 1, 0)
        ballsView:setStrokeColor(0.25)
        ballsView.strokeWidth = 1
        if (i > ballsCount) then
          ballsView:setFillColor(1)
        end
        return ballsView
      end)()
    )
  end

  viewManager:addComponent(
    sceneName,
    "TEXT_STRIKES",
    (function()
      local text = display.newText(sceneGroup, strikes, 400, 80, "asul.ttf", defaultFontSize)
      text.anchorX = 0
      text.anchorY = 0
      text.x = xBodyOffset
      text.y = 34
      text:setFillColor(0)
      return text
    end)()
  )

  for i = 1, config.MAX_STRIKES do
    viewManager:addComponent(
      sceneName,
      "STRIKES_MARKER_" .. i,
      (function()
        local strikesView = display.newRoundedRect(sceneGroup, 0, 0, 8, 8, 4)
        strikesView.anchorX = 0
        strikesView.anchorY = 0
        strikesView.x = xBodyOffset + 22 + (15 * i)
        strikesView.y = 34 + 2
        strikesView:setFillColor(1, 0, 0)
        strikesView:setStrokeColor(0.25)
        strikesView.strokeWidth = 1
        if (i > strikesCount) then
          strikesView:setFillColor(1)
        end
        return strikesView
      end)()
    )
  end

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
