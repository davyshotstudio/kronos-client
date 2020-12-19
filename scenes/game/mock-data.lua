-- Entities
local athleteCard = require("scenes.game.entities.athlete-card")
local skill = require("scenes.game.entities.skill")

local pitchingStaff = {
  athleteCard:new(
    {
      id = "0",
      name = "Kronos",
      pictureURL = "kronos.jpg",
      positions = {"p", "ss"},
      skill = skill:new({floor = 0, ceiling = 100})
    }
  )
}

local battingLineup = {
  athleteCard:new(
    {
      id = "1",
      name = "Zeus",
      pictureURL = "zeus.jpg",
      positions = {"p", "2b"},
      skill = skill:new({floor = 30, ceiling = 70})
    }
  ),
  athleteCard:new(
    {
      id = "2",
      name = "Poseidon",
      pictureURL = "poseidon.jpg",
      positions = {"p", "2b"},
      skill = skill:new({floor = 0, ceiling = 110})
    }
  ),
  athleteCard:new(
    {
      id = "3",
      name = "Hades",
      pictureURL = "hades.jpg",
      positions = {"p", "2b"},
      skill = skill:new({floor = 50, ceiling = 60})
    }
  )
}

return {
  pitchingStaff = pitchingStaff,
  battingLineup = battingLineup
}
