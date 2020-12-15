local config = {
  -- Config state (represents upper from the previous highest result)
  -- ex. SINGLE_CUTOFF means a single is recorded if the batter rolls between
  -- 0 to SINGLE_CUTOFF, a double is recorded from SINGLE_CUTOFF to DOUBLE_CUTOFF, etc.
  SINGLE_CUTOFF = 15,
  DOUBLE_CUTOFF = 25,
  TRIPLE_CUTOFF = 35,
  HOME_RUN_CUTOFF = 40,
  -- Max number of outs in an inning
  MAX_OUTS = 3,
  -- Max number of innings in a game
  MAX_INNINGS = 3
}

return config
