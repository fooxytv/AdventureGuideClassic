--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

TierTokenService = {}

-- [tokenItemId] = { WARRIOR = { itemId, ... }, WARRIOR_SOD = { ... }, ANY = { ... } }
-- Populated from data/TierTokens.lua, generated from AtlasLoot's Token.lua.
local tokens = {}

function TierTokenService.Register(data)
	for tokenId, byClass in pairs(data) do
		tokens[tokenId] = byClass
	end
end

function TierTokenService.IsToken(itemId)
	return itemId ~= nil and tokens[itemId] ~= nil
end

local function IsSeasonOfDiscovery()
	local activeSeason = C_Seasons and C_Seasons.GetActiveSeason and C_Seasons.GetActiveSeason() or 0
	local tocVersion = select(4, GetBuildInfo())
	return tocVersion < 20000 and activeSeason == 2
end

--[[
	The set piece a token should preview as.

	A token carries no appearance of its own, so previewing it dresses the model
	in nothing. Resolve it to the piece the player's own class trades it for;
	fall back to a non-class-specific list, then to any class's piece, so a token
	always previews as something rather than silently doing nothing.
]]
function TierTokenService.GetPreviewItemId(tokenId, class)
	local entry = tokens[tokenId]
	if not entry then return nil end

	class = class or select(2, UnitClass("player"))

	if class then
		if IsSeasonOfDiscovery() then
			local sod = entry[class .. "_SOD"]
			if sod and sod[1] then return sod[1] end
		end
		local own = entry[class]
		if own and own[1] then return own[1] end
	end

	if entry.ANY and entry.ANY[1] then return entry.ANY[1] end

	-- No piece for this class: show the token's first known piece so the preview
	-- still conveys the set, sorted for a stable pick across sessions.
	local keys = {}
	for key in pairs(entry) do
		if not key:find("_SOD$") then table.insert(keys, key) end
	end
	table.sort(keys)
	for _, key in ipairs(keys) do
		local ids = entry[key]
		if ids and ids[1] then return ids[1] end
	end
	return nil
end
