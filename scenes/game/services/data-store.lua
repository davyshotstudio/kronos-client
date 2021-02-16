--------------------------------------------------------------------
-- DataStore manages all of the state in a game. This is the local
-- clients source of truth, all data here will be synced with the
-- server and cached in this file
--------------------------------------------------------------------
local constants = require("scenes.game.utilities.constants")
local config = require("scenes.game.utilities.config")
-- TODO: Remove when no more mocks are needed
local mockData = require("scenes.game.utilities.fixtures.mock-data")

local athleteCard = require("scenes.game.entities.athlete-card")
local skill = require("scenes.game.entities.skill")
local pitch = require("scenes.game.entities.pitch")

local DataStore = {}

-- Instantiate DataStore (constructor)
function DataStore:new(options)
  local state = constants.STATE_BATTER_START
  local pitchResultState = constants.NONE
  local balls = options.balls or 0
  local strikes = options.strikes or 0
  local outs = options.outs or 0
  local inning = options.inning or 0
  local pitcher = options.pitcher or mockData.pitchingStaff[1]
  local batter = options.batter or mockData.battingLineup[1]
  local pitcherSelectedZone = options.pitcherSelectedZone or 1
  local pitcherSelectedPitch = options.pitcherSelectedPitch or 1
  local batterGuessedZone = options.batterGuessedZone or 0
  local batterGuessedPitch = options.batterGuessedPitch or 0
  local lastPitcherRoll = -1
  local lastBatterRoll = -1
  local availableBatters = options.availableBatters or mockData.battingLineup
  -- (List) Deck containing available action cards a pitcher can use
  local pitcherActionCards = options.pitcherActionCards or mockData.pitcherActionCards
  -- (List) Deck containing available action cards a batter can use
  local batterActionCards = options.batterActionCards or mockData.batterActionCards
  -- Map containing key of pitchID and value of the action card ID the pitcher has assigned
  local inPlayPitcherActionCardsMap = options.inPlayPitcherActionCardsMap or mockData.inPlayPitcherActionCardsMap
  -- Map containing key of zone and value of the action card ID the batter has assigned
  local inPlayBatterActionCardsMap = options.inPlayBatterActionCardsMap or mockData.inPlayBatterActionCardsMap
  local awayScore = options.awayScore or 0
  local homeScore = options.homeScore or 0
  local awayTeam = options.awayTeam or mockData.awayTeam
  local homeTeam = options.homeTeam or mockData.homeTeam

  local listeners = {}

  local dataStore = {
    state = state,
    pitchResultState = pitchResultState,
    balls = balls,
    strikes = strikes,
    outs = outs,
    inning = inning,
    pitcher = pitcher,
    batter = batter,
    pitcherSelectedZone = pitcherSelectedZone,
    pitcherSelectedPitch = pitcherSelectedPitch,
    batterGuessedZone = batterGuessedZone,
    batterGuessedPitch = batterGuessedPitch,
    lastPitcherRoll = lastPitcherRoll,
    lastBatterRoll = lastBatterRoll,
    availableBatters = availableBatters,
    pitcherActionCards = pitcherActionCards,
    batterActionCards = batterActionCards,
    inPlayPitcherActionCardsMap = inPlayPitcherActionCardsMap,
    inPlayBatterActionCardsMap = inPlayBatterActionCardsMap,
    awayScore = awayScore,
    homeScore = homeScore,
    awayTeam = awayTeam,
    homeTeam = homeTeam,
    listeners = listeners
  }

  setmetatable(dataStore, self)
  self.__index = self

  return dataStore
end

-- -- Listeners to server push events
function DataStore:addStateListener(listenerFunction)
  table.insert(self.listeners, listenerFunction)
end

-- ---------------------------------------------------------
-- Getters and setters for individual fields
-- ---------------------------------------------------------

function DataStore:getState()
  return self.state
end

function DataStore:setState(nextState)
  local currentState = self.state

  -- Execute the listeners functions to any state updates
  for i, listener in ipairs(self.listeners) do
    listener(self, currentState, nextState)
  end

  self.state = nextState
end

function DataStore:getBatter()
  return self.batter
end

function DataStore:setBatter(batter)
  local mappedBatter =
    athleteCard:new(
    {
      id = batter.id,
      name = batter.name,
      pictureURL = batter.pictureURL,
      positions = batter.positions,
      skill = skill:new(
        {
          floor = batter.skill.floor,
          ceiling = batter.skill.ceiling
        }
      )
    }
  )

  self.batter = mappedBatter
end

function DataStore:getPitcher()
  return self.pitcher
end

function DataStore:setPitcher(pitcher)
  local mappedPitcher =
    athleteCard:new(
    {
      id = pitcher.id,
      name = pitcher.name,
      pictureURL = pitcher.pictureURL,
      positions = pitcher.positions,
      skill = skill:new(
        {
          floor = pitcher.skill.floor,
          ceiling = pitcher.skill.ceiling
        }
      ),
      -- TODO (wilbert): map these fields instead of hardcoding them
      pitches = {
        [1] = pitch:new({id = 1, name = "FASTBALL", abbreviation = "FB"}),
        [2] = pitch:new({id = 2, name = "CHANGEUP", abbreviation = "CH"}),
        [3] = pitch:new({id = 3, name = "CURVEBALL", abbreviation = "CB"}),
        [4] = pitch:new({id = 4, name = "SLIDER", abbreviation = "SL"}),
        [5] = pitch:new({id = 5, name = "KNUCKLEBALL", abbreviation = "KN"}),
        [6] = pitch:new({id = 6, name = "SCREWBALL", abbreviation = "SB"}),
        [7] = pitch:new({id = 7, name = "SPLITTER", abbreviation = "SP"})
      }
    }
  )

  self.pitcher = mappedPitcher
end

function DataStore:getPitcherSelectedPitch()
  return self.pitcherSelectedPitch
end

function DataStore:setPitcherSelectedPitch(pitcherSelectedPitch)
  self.pitcherSelectedPitch = pitcherSelectedPitch
end

function DataStore:getPitcherSelectedZone()
  return self.pitcherSelectedZone
end

function DataStore:setPitcherSelectedZone(pitcherSelectedZone)
  self.pitcherSelectedZone = pitcherSelectedZone
end

function DataStore:getBatterGuessedPitch()
  return self.batterGuessedPitch
end

function DataStore:getBatterGuessedPitch(batterGuessedPitch)
  self.batterGuessedPitch = batterGuessedPitch
end

function DataStore:getBatterGuessedZone()
  return self.batterGuessedZone
end

function DataStore:setBatterGuessedZone(batterGuessedZone)
  self.batterGuessedZone = batterGuessedZone
end

function DataStore:getLastRolls()
  return self.lastPitcherRoll, self.lastBatterRoll
end

function DataStore:setLastRollsPitcher(lastPitcherRoll)
  self.lastPitcherRoll = lastPitcherRoll
end

function DataStore:setLastRollsBatter(lastBatterRoll)
  self.lastBatterRoll = lastBatterRoll
end

function DataStore:getPitchResultState()
  return self.pitchResultState
end

function DataStore:setPitchResultState(pitchResultState)
  self.pitchResultState = pitchResultState
end

function DataStore:getCount()
  return self.balls, self.strikes
end

function DataStore:setCountBalls(balls)
  self.balls = balls
end

function DataStore:setCountStrikes(strikes)
  self.strikes = strikes
end

function DataStore:getAvailableBatters()
  return self.availableBatters
end

function DataStore:setAvailableBatters(availableBatters)
  self.availableBatters = availableBatters
end

function DataStore:getBatterActionCards()
  return self.batterActionCards
end

function DataStore:setBatterActionCards(batterActionCards)
  self.batterActionCards = batterActionCards
end

function DataStore:getPitcherActionCards()
  return self.pitcherActionCards
end

function DataStore:setPitcherActionCards(pitcherActionCards)
  self.pitcherActionCards = pitcherActionCards
end

function DataStore:getInPlayBatterActionCardsMap()
  return self.inPlayBatterActionCardsMap
end

function DataStore:setInPlayBatterActionCardsMap(inPlayBatterActionCardsMap)
  self.inPlayBatterActionCardsMap = inPlayBatterActionCardsMap
end

function DataStore:getInPlayPitcherActionCardsMap()
  return self.inPlayPitcherActionCardsMap
end

function DataStore:setInPlayPitcherActionCardsMap(inPlayPitcherActionCardsMap)
  self.inPlayPitcherActionCardsMap = inPlayPitcherActionCardsMap
end

function DataStore:getScore()
  return self.awayScore, self.homeScore
end

function DataStore:setAwayScore(awayScore)
  self.awayScore = awayScore
end

function DataStore:setHomeScore(homeScore)
  self.homeScore = homeScore
end

function DataStore:getHomeTeam()
  return self.homeTeam
end

function DataStore:setHomeTeam(homeTeam)
  self.homeTeam = homeTeam
end

function DataStore:getAwayTeam()
  return self.awayTeam
end

function DataStore:setAwayTeam(awayTeam)
  self.awayTeam = awayTeam
end

function DataStore:getInning()
  return self.inning
end

function DataStore:setInning(inning)
  self.inning = inning
end

function DataStore:getOuts()
  return self.outs
end

function DataStore:setOuts(outs)
  self.outs = outs
end

return DataStore
