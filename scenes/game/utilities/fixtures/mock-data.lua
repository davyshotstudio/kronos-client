-- Entities
local actionCard = require("scenes.game.entities.action-card")
local action = require("scenes.game.entities.action")
local athleteCard = require("scenes.game.entities.athlete-card")
local pitch = require("scenes.game.entities.pitch")
local skill = require("scenes.game.entities.skill")

local pitchingStaff = {
  athleteCard:new(
    {
      id = "1",
      name = "Montana",
      pictureURL = "character_card_montana.png",
      positions = {"p", "ss"},
      skill = skill:new({floor = 0, ceiling = 100}),
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
}

local battingLineup = {
  athleteCard:new(
    {
      id = "1",
      name = "Dur",
      pictureURL = "character_card_dur.png",
      positions = {"p", "2b"},
      skill = skill:new({floor = 30, ceiling = 70})
    }
  ),
  athleteCard:new(
    {
      id = "2",
      name = "Dad",
      pictureURL = "character_card_dad.png",
      positions = {"p", "1b"},
      skill = skill:new({floor = 0, ceiling = 110})
    }
  ),
  athleteCard:new(
    {
      id = "3",
      name = "Wlammy",
      pictureURL = "character_card_wlammy.png",
      positions = {"p", "of"},
      skill = skill:new({floor = 50, ceiling = 60})
    }
  )
}

local batterActionCards = {
  actionCard:new(
    {
      id = "1",
      battingAction = action:new(
        {
          id = "1",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  ),
  actionCard:new(
    {
      id = "2",
      battingAction = action:new(
        {
          id = "2",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample_2.png"
        }
      )
    }
  ),
  actionCard:new(
    {
      id = "3",
      battingAction = action:new(
        {
          id = "3",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  ),
  actionCard:new(
    {
      id = "4",
      battingAction = action:new(
        {
          id = "4",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample_2.png"
        }
      )
    }
  ),
  actionCard:new(
    {
      id = "5",
      battingAction = action:new(
        {
          id = "5",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  ),
  actionCard:new(
    {
      id = "6",
      battingAction = action:new(
        {
          id = "6",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample_2.png"
        }
      )
    }
  ),
  actionCard:new(
    {
      id = "7",
      battingAction = action:new(
        {
          id = "7",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your pitch speeds down",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  )
}

local pitcherActionCards = {
  [1] = actionCard:new(
    {
      id = "1",
      pitchingAction = action:new(
        {
          id = "7",
          name = "Herpes",
          description = "Infects herpes and makes your pitch break 40% more.",
          pictureURL = "action_card_sample_2.png"
        }
      )
    }
  ),
  [2] = actionCard:new(
    {
      id = "2",
      pitchingAction = action:new(
        {
          id = "7",
          name = "Gonnorhea",
          description = "Infects gonorrhea and slows your fastball down 90%",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  ),
  [3] = actionCard:new(
    {
      id = "3",
      pitchingAction = action:new(
        {
          id = "8",
          name = "Clamydia",
          description = "Infects clamydia and speeds your pitch up",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  ),
  [4] = actionCard:new(
    {
      id = "4",
      pitchingAction = action:new(
        {
          id = "9",
          name = "Syphillis",
          description = "Infects syphillis and bumps your pitch ceiling up by 69%",
          pictureURL = "action_card_sample_2.png"
        }
      )
    }
  ),
  [5] = actionCard:new(
    {
      id = "5",
      pitchingAction = action:new(
        {
          id = "10",
          name = "Hepatitis",
          description = "Infects hepatitis and drops your pitch speed up by 2%",
          pictureURL = "action_card_sample.png"
        }
      )
    }
  )
}

local inPlayPitcherActionCardsMap = {
  [1] = 1,
  [3] = 4,
  [4] = 5
}

return {
  pitchingStaff = pitchingStaff,
  battingLineup = battingLineup,
  batterActionCards = batterActionCards,
  pitcherActionCards = pitcherActionCards,
  inPlayPitcherActionCardsMap = inPlayPitcherActionCardsMap
}
