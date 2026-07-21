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

local ITEM_CLASS_ARMOR = 4
local GetItemInfoInstantCompat = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant

--[[
	Whether a class can trade this token in. `ANY` marks tokens that aren't
	class-specific, so those pass for everyone.
]]
function TierTokenService.HasClass(tokenId, class)
	local entry = tokens[tokenId]
	if not entry then return false end
	if entry.ANY then return true end
	if not class then return true end
	return entry[class] ~= nil or entry[class .. "_SOD"] ~= nil
end

--[[
	Whether the pieces this token grants are of a given armour type. Used so the
	armour filter can place tokens, which carry no armour type themselves. When a
	class filter is also active only that class's piece is considered, otherwise
	any class's piece counts.

	GetItemInfoInstant is safe here: it resolves from static client data and so
	works for items that have never been cached.
]]
function TierTokenService.HasArmorType(tokenId, armorSubclass, class)
	local entry = tokens[tokenId]
	if not entry then return false end

	local function AnyMatches(itemIds)
		for _, itemId in ipairs(itemIds) do
			local _, _, _, _, _, classID, subclassID = GetItemInfoInstantCompat(itemId)
			if classID == ITEM_CLASS_ARMOR and subclassID == armorSubclass then
				return true
			end
		end
		return false
	end

	if class then
		local ids = entry[class] or entry.ANY
		return ids ~= nil and AnyMatches(ids)
	end

	for key, ids in pairs(entry) do
		if not key:find("_SOD$") and AnyMatches(ids) then return true end
	end
	return false
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
