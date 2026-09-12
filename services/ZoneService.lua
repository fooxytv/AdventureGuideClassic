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
		if zone.uiMapID == uiMapID then
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
Checks every registered uiMapID against the client's own map data. The ids are
hand-entered, and a wrong one fails silently (the suggestion still renders, it just
points at the wrong map), so this is the cheap way to catch a typo.
]]
_G.AGC_VerifyZoneMapIDs = function()
	if not (C_Map and C_Map.GetMapInfo) then
		print("|cffff5555[AGC]|r C_Map.GetMapInfo unavailable on this client.")
		return
	end
	local checked, problems = 0, 0
	for _, zone in ipairs(zones) do
		checked = checked + 1
		local info = C_Map.GetMapInfo(zone.uiMapID)
		if not info then
			problems = problems + 1
			print(("|cffff5555[AGC]|r %s: uiMapID %d does not exist"):format(zone.name, zone.uiMapID))
		elseif info.name ~= zone.name then
			problems = problems + 1
			print(("|cffff5555[AGC]|r %s: uiMapID %d is actually \"%s\""):format(
				zone.name, zone.uiMapID, tostring(info.name)))
		end
	end
	print(("|cff33ff99[AGC]|r checked %d zone map ids, %d problems."):format(checked, problems))
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
