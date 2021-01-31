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
        pitch:new({id = 1, name = "FASTBALL", abbreviation = "FB"}),
        pitch:new({id = 2, name = "CHANGEUP", abbreviation = "CH"}),
        pitch:new({id = 3, name = "CURVEBALL", abbreviation = "CB"})
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

return {
  pitchingStaff = pitchingStaff,
  battingLineup = battingLineup,
  batterActionCards = batterActionCards
}
