local constants = {
  -- InningManager state constants
  STATE_AT_BAT_END = "STATE_AT_BAT_END",
  STATE_INNING_END = "STATE_INNING_END",
  STATE_AT_BAT_ONGOING = "STATE_AT_BAT_ONGOING",
  -- InningManager action constants
  ACTION_HIT = "HIT",
  ACTION_FOUL = "FOUL",
  ACTION_OUT = "OUT",
  -- Resolver constants
  NONE = "NONE",
  SINGLE = "SINGLE",
  DOUBLE = "DOUBLE",
  TRIPLE = "TRIPLE",
  HOME_RUN = "HOME_RUN",
  OUT = "OUT",
  STRIKE = "STRIKE",
  BALL = "BALL",
  FOUL = "FOUL"
}

return constants
