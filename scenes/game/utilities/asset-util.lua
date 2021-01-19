--------------------------------------------------------------------
-- AssetUtil provides helpers for managing assets
--------------------------------------------------------------------

-- Constant for root path to local asset folder
local ASSET_PATH = "scenes/game/assets/"
local function resolveAssetPath(fileName)
  return ASSET_PATH .. fileName
end

return {
  resolveAssetPath = resolveAssetPath
}
