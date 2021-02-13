--------------------------------------------------------------------
-- DataStore manages all of the state in a game. This is the local
-- clients source of truth, all data here will be synced with the
-- server and cached in this file
--------------------------------------------------------------------
local constants = require("scenes.game.utilities.constants")
local config = require("scenes.game.utilities.config")
-- TODO: Remove when no more mocks are needed
local mockData = require("scenes.game.utilities.fixtures.mock-data")

local DataStore = {}

-- Instantiate DataStore (constructor)
function DataStore:new(options)
  local state = constants.STATE_PLAYERS_PITCH_PENDING
  local pitchResultState = constants.NONE
  local balls = options.balls or 0
  local strikes = options.strikes or 0
  local pitcher = options.pitcher or mockData.pitchingStaff[1]
  local batter = options.batter or mockData.battingLineup[1]
  local pitcherSelectedZone = options.pitcherSelectedZone or 0
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

  local dataStore = {
    state = state,
    pitchResultState = pitchResultState,
    balls = balls,
    strikes = strikes,
    pitcher = pitcher,
    batter = batter,
    pitcherSelectedZone = pitcherSelectedZone,
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
    homeTeam = homeTeam
  }

  setmetatable(dataStore, self)
  self.__index = self

  return dataStore
end

-- Listeners to server push events
function listeners()
  -- Map datafields to the proper field
end

function DataStore:updateState(action, params)
  if (self.state == constants.STATE_PLAYERS_PITCH_PENDING) then
    if (action == constants.ACTION_RESOLVER_BATTER_SELECT_ZONE) then
      self.batterGuessedZone = params.batterGuessedZone
    end

    if (action == constants.ACTION_RESOLVER_PITCHER_SELECT_ZONE) then
      self.pitcherSelectedZone = params.pitcherSelectedZone
    end

    if (self.batterGuessedZone > -1 and self.pitcherSelectedZone > -1) then
      -- Resolve the pitch
      local pitchResultState, pitcherRoll, batterRoll = self:resolvePitch(self.pitcher, self.batter)
      self.pitchResultState = pitchResultState
      self.state = constants.STATE_PLAYERS_PITCH_RESOLVED
      -- If the pitch is a terminal pitch (results in a hit or out or walk), move state to at bat finished
      if
        (pitchResultState ~= constants.BALL and pitchResultState ~= constants.STRIKE and
          pitchResultState ~= constants.FOUL)
       then
        self.state = constants.STATE_PLAYERS_AT_BAT_RESOLVED
        self.balls = 0
        self.strikes = 0
      end

      -- Reset batter/pitcher selected zones
      self.pitcherSelectedZone = -1
      self.batterGuessedZone = -1
    end
  elseif (self.state == constants.STATE_PLAYERS_PITCH_RESOLVED) then
    if (action == constants.ACTION_RESOLVER_NEXT_PITCH) then
      self.state = constants.STATE_PLAYERS_PITCH_PENDING
    end
  elseif (self.state == constants.STATE_PLAYERS_AT_BAT_RESOLVED) then
    -- If both pitcher and batter player are ready for the next at bat,
    -- move to the next player
    if (action == constants.ACTION_RESOLVER_NEXT_BATTER) then
      self.state = constants.STATE_PLAYERS_PITCH_PENDING
    -- TODO (wilbert): reset at bat
    end
  end

  return self.state
end

-- Roll a random result between the player's floor and ceiling
-- TODO: add additional logic for determining the roll
local function roll(player)
  return math.random(player:getSkill():getFloor(), player:getSkill():getCeiling())
end

-- Run the matchup for a single pitch
function DataStore:resolvePitch(pitcher, batter)
  local pitcherRoll = roll(pitcher)
  local batterRoll = roll(batter)

  local pitchResultState = self:calculatePitchResultState(pitcherRoll, batterRoll)
  if (pitchResultState == constants.BALL) then
    self.balls = self.balls + 1
    if (self.balls >= config.MAX_BALLS) then
      pitchResultState = constants.WALK
    end
  end
  if (pitchResultState == constants.STRIKE) then
    self.strikes = self.strikes + 1
    if (self.strikes >= config.MAX_STRIKES) then
      pitchResultState = constants.STRIKEOUT
    end
  end
  self.lastPitcherRoll = pitcherRoll
  self.lastBatterRoll = batterRoll
  return pitchResultState, pitcherRoll, batterRoll
end

-- Update state machine for the at bat
function DataStore:calculatePitchResultState(pitcherRoll, batterRoll)
  local result = batterRoll - pitcherRoll

  -- If zone is 0, that means that the batter isn't swinging
  -- Check the potential for a ball
  if (self.batterGuessedZone == 0) then
    if (batterRoll * 1.2 > pitcherRoll) then
      state = constants.BALL
    else
      state = constants.STRIKE
    end
    return state
  end

  -- Positive value means batter wins,
  -- negative value means pitcher wins,
  -- tie means foul ball
  if (result == 0) then
    state = constants.FOUL
  elseif (result > config.TRIPLE_CUTOFF) then
    state = constants.HOME_RUN
  elseif (result > config.DOUBLE_CUTOFF) then
    state = constants.TRIPLE
  elseif (result > config.SINGLE_CUTOFF) then
    state = constants.DOUBLE
  elseif (result > 0) then
    state = constants.SINGLE
  elseif (result < 0) then
    state = constants.OUT
  end

  -- Update state machine and return state
  return state
end

-- ---------------------------------------------------------
-- Getters and setters for individual fields
-- ---------------------------------------------------------

function DataStore:getState()
  return self.state
end

function DataStore:setState(state)
  self.state = state
end

function DataStore:getBatter()
  return self.batter
end

function DataStore:setBatter(batter)
  self.batter = batter
end

function DataStore:getPitcher()
  return self.pitcher
end

function DataStore:setPitcher(pitcher)
  self.pitcher = pitcher
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

return DataStore
