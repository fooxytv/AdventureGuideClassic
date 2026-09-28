--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
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

-- `ANY` marks tokens that are not class-specific, so those pass for everyone.
function TierTokenService.HasClass(tokenId, class)
	local entry = tokens[tokenId]
	if not entry then return false end
	if entry.ANY then return true end
	if not class then return true end
	return entry[class] ~= nil or entry[class .. "_SOD"] ~= nil
end

-- GetItemInfoInstant resolves from static client data, so it works for uncached items.
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
	return Compat.IsSoD()
end

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
