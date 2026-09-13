--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
Registry of levelling zones, and the ranking that answers "where should this character
be questing right now?".

Zones are registered from data/Zones/*.lua. Burning Crusade zones are filtered out on
an Era client, so the data files can register everything unconditionally.
]]

ZoneService = { }

local zones = { }

function ZoneService.AddZone(zone)
	table.insert(zones, zone)
end

--[[
Map id resolution.

uiMapIDs are NOT hard-coded in the data files. Classic Era, BCC and retail all number
their maps differently -- Elwynn Forest is 1429 on Era but 37 on retail -- so any list
we wrote by hand would be wrong on at least one client, and wrong silently: the card
still renders, it just opens the wrong map.

Instead the data carries only the zone's name, and the client is asked for the id. It
always knows, on every client, in every locale it ships the zone under.
]]
local mapIDsByName

local MAP_TYPE_ZONE = 3

local function IndexMap(info)
	if not (info and info.name and info.mapID) then return end
	local existing = mapIDsByName[info.name]
	-- Prefer a true Zone over a micro-dungeon or continent sharing the name.
	if not existing or (info.mapType == MAP_TYPE_ZONE and existing.mapType ~= MAP_TYPE_ZONE) then
		mapIDsByName[info.name] = { mapID = info.mapID, mapType = info.mapType }
	end
end

local function CountIndex()
	local count = 0
	for _ in pairs(mapIDsByName) do count = count + 1 end
	return count
end

local function BuildMapIndex()
	mapIDsByName = { }
	if not (C_Map and C_Map.GetMapInfo) then return end

	-- Walk down from the cosmic/world roots where possible; it is far cheaper than a
	-- scan and needs no knowledge of the client's id ranges.
	if C_Map.GetMapChildrenInfo then
		for _, root in ipairs({ 946, 947 }) do
			local ok, children = pcall(C_Map.GetMapChildrenInfo, root, nil, true)
			if ok and type(children) == "table" then
				for _, info in ipairs(children) do
					IndexMap(info)
				end
			end
		end
	end

	-- If the tree walk found little or nothing, fall back to a bounded scan. Runs at
	-- most once per session, lazily, the first time a map id is actually needed.
	if CountIndex() < 20 then
		for id = 1, 2500 do
			local ok, info = pcall(C_Map.GetMapInfo, id)
			if ok then IndexMap(info) end
		end
	end
end

function ZoneService.GetMapIDByName(name)
	if not name then return nil end
	if not mapIDsByName then BuildMapIndex() end
	local entry = mapIDsByName[name]
	return entry and entry.mapID or nil
end

-- Resolved id for a zone, cached per zone. `false` records "looked up, not found" so
-- a miss isn't retried on every refresh.
function ZoneService.GetZoneMapID(zone)
	if not zone then return nil end
	if zone.resolvedMapID == nil then
		zone.resolvedMapID = ZoneService.GetMapIDByName(zone.name) or false
	end
	return zone.resolvedMapID or nil
end

function ZoneService.RebuildMapIndex()
	mapIDsByName = nil
	for _, zone in ipairs(zones) do
		zone.resolvedMapID = nil
	end
end

local function IsBurningCrusade()
	return select(4, GetBuildInfo()) >= 20000
end

local function PassesClientRules(zone)
	if zone.expansion == "tbc" and not IsBurningCrusade() then
		return false
	end
	return true
end

local function PassesFaction(zone, faction)
	if not faction then return true end
	if not zone.faction then return true end
	return zone.faction == faction
end

function ZoneService.GetAllZones()
	local result = { }
	for _, zone in ipairs(zones) do
		if PassesClientRules(zone) then
			table.insert(result, zone)
		end
	end
	return result
end

function ZoneService.GetZoneByMapID(uiMapID)
	for _, zone in ipairs(zones) do
		if ZoneService.GetZoneMapID(zone) == uiMapID then
			return zone
		end
	end
	return nil
end

function ZoneService.GetZoneByName(name)
	for _, zone in ipairs(zones) do
		if zone.name == name then
			return zone
		end
	end
	return nil
end

--[[
Every zone whose level band contains `level` and whose faction allows this character,
ordered best-first. Ranking, in order of weight:

  1. the character's own racial zone, where one applies. Without this the three
     Alliance starting zones tie on every other measure and fall to alphabetical
     order, which sends every level 1 Alliance character to Dun Morogh -- telling a
     night elf to go to Ironforge.
  2. how close the player is to the zone's recommended level
  3. faction-specific zones ahead of contested ones, since their quest density is
     higher for that faction
  4. name, purely so the ordering is stable between calls

Deliberately does NOT prefer the zone the player is standing in -- the point of the
suggestion is to tell them where to go next.
]]
local function IsRacialZone(zone, race)
	if not (zone.races and race) then return false end
	for _, zoneRace in ipairs(zone.races) do
		if zoneRace == race then return true end
	end
	return false
end

function ZoneService.GetZonesForLevel(level, faction, race)
	race = race or (PlayerContextService and PlayerContextService.GetRace())

	local matches = { }
	for _, zone in ipairs(zones) do
		if PassesClientRules(zone)
			and PassesFaction(zone, faction)
			and level >= zone.levelRange.min
			and level <= zone.levelRange.max then
			table.insert(matches, zone)
		end
	end

	table.sort(matches, function(a, b)
		local aRacial = IsRacialZone(a, race)
		local bRacial = IsRacialZone(b, race)
		if aRacial ~= bRacial then return aRacial end

		local aDist = math.abs((a.rec or a.levelRange.min) - level)
		local bDist = math.abs((b.rec or b.levelRange.min) - level)
		if aDist ~= bDist then return aDist < bDist end

		local aSpecific = a.faction ~= nil
		local bSpecific = b.faction ~= nil
		if aSpecific ~= bSpecific then return aSpecific end

		return a.name < b.name
	end)

	return matches
end

function ZoneService.GetBestZoneForLevel(level, faction, race)
	return ZoneService.GetZonesForLevel(level, faction, race)[1]
end

-- Debug helpers (see todo.md) -------------------------------------------------

--[[
Reports any zone whose name the client does not recognise as a map. A miss is not
fatal -- the card still works, its click just won't open a map -- but it means either
a typo in our name or a zone this client spells differently.
]]
_G.AGC_VerifyZoneMapIDs = function()
	if not (C_Map and C_Map.GetMapInfo) then
		print("|cffff5555[AGC]|r C_Map.GetMapInfo unavailable on this client.")
		return
	end
	ZoneService.RebuildMapIndex()
	local checked, unresolved = 0, 0
	for _, zone in ipairs(zones) do
		if PassesClientRules(zone) then
			checked = checked + 1
			if not ZoneService.GetZoneMapID(zone) then
				unresolved = unresolved + 1
				print(("|cffff5555[AGC]|r %s: this client has no map by that name"):format(zone.name))
			end
		end
	end
	print(("|cff33ff99[AGC]|r resolved %d of %d zone map ids (%d unresolved)."):format(
		checked - unresolved, checked, unresolved))
end

-- Prints the id the client resolved for each zone, for reference.
_G.AGC_DumpZoneMapIDs = function()
	for _, zone in ipairs(zones) do
		if PassesClientRules(zone) then
			print(("  %-28s %s"):format(zone.name, tostring(ZoneService.GetZoneMapID(zone) or "unresolved")))
		end
	end
end

_G.AGC_ZonesForLevel = function(level, faction)
	level = level or PlayerContextService.GetLevel()
	faction = faction or PlayerContextService.GetFaction()
	local matches = ZoneService.GetZonesForLevel(level, faction)
	print(("|cff33ff99[AGC]|r zones at level %d (%s): %d"):format(level, tostring(faction), #matches))
	for index, zone in ipairs(matches) do
		print(("  %d. %s (%d-%d, rec %d)"):format(
			index, zone.name, zone.levelRange.min, zone.levelRange.max, zone.rec))
	end
end
