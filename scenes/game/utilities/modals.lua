local composer = require("composer")

local function showCardModal(card, cardImageURL)
  -- Options table for the overlay scene "pause.lua"
  local options = {
    isModal = true,
    effect = "zoomInOut",
    time = 200,
    params = {
      card = card,
      cardImageURL = cardImageURL
    }
  }

  -- Show the overlay for a given card
  composer.showOverlay("scenes.game.batter-card-zoomed-overlay", options)
end

return {
  showCardModal = showCardModal
}
