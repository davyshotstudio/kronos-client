-- Scoreboard is a widget that displays the current score between two teams
local composer = require("composer")

local function scoreboard(parentSceneGroup, sceneName)
  -- Retrieve DI instances of the managers
  local viewManager = composer.getVariable("viewManager")
  local batterManager = composer.getVariable("batterManager")

  -- Register scene domain into the ViewManager
  viewManager:registerScene(sceneName)

  local sceneGroup = display.newGroup()
  parentSceneGroup:insert(sceneGroup)

  local awayTeamName = batterManager:getDataStore():getAwayTeam():getName()
  local homeTeamName = batterManager:getDataStore():getHomeTeam():getName()
  local awayScore, homeScore = batterManager:getDataStore():getScore()

  viewManager:addComponent(
    sceneName,
    "SCOREBOARD_BACKGROUND",
    (function()
      local background = display.newRoundedRect(sceneGroup, 0, 0, 200, 27, 10)
      background.anchorX = 0
      background.anchorY = 0
      background:setFillColor(0.2)
      return background
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_AWAY_TEAM",
    (function()
      local text = display.newText(sceneGroup, awayTeamName, 400, 80, "asul.ttf", 16)
      text.anchorX = 0
      text.anchorY = 0
      text.x = 10
      text.y = 2
      text:setFillColor(0.8, 0, 0)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_AWAY_SCORE",
    (function()
      local text = display.newText(sceneGroup, awayScore, 400, 80, "asul.ttf", 16)
      text.anchorX = 0
      text.anchorY = 0
      text.x = 80
      text.y = 2
      text:setFillColor(1, 1, 1)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_SCORE_HYPHEN",
    (function()
      local text = display.newText(sceneGroup, "-", 400, 80, "asul.ttf", 16)
      text.anchorX = 0
      text.anchorY = 0
      text.x = 95
      text.y = 2
      text:setFillColor(1, 1, 1)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_HOME_SCORE",
    (function()
      local text = display.newText(sceneGroup, homeScore, 400, 80, "asul.ttf", 16)
      text.anchorX = 0
      text.anchorY = 0
      text.x = 105
      text.y = 2
      text:setFillColor(1, 1, 1)
      return text
    end)()
  )

  viewManager:addComponent(
    sceneName,
    "TEXT_HOME_TEAM",
    (function()
      local text = display.newText(sceneGroup, homeTeamName, 400, 80, "asul.ttf", 16)
      text.anchorX = 0
      text.anchorY = 0
      text.x = 140
      text.y = 2
      text:setFillColor(0, 0.8, 0)
      return text
    end)()
  )
end

return scoreboard
