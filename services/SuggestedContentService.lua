--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
Builds the list of suggestion cards shown on the Suggested Content tab.

Everything here is driven by PlayerContextService -- level, faction and client -- and
never by the Classic/Burning Crusade dropdown on the Dungeons and Raids tabs. That
dropdown is a browsing preference; a suggestion has to describe what this character
can actually do right now. Hence GetAllDungeons/GetAllRaids rather than
GetDungeons/GetRaids.

A card is a plain table of data:

	{ type, priority, title, subtitle, description, thumbnail, levelRange,
	  instance | zone }

Lower priority sorts first. Cards carry no behaviour: what clicking one does is the
view's business (ui/SuggestedContent.lua), keyed off `type`, so this service stays
free of UI lookups and can be exercised headlessly.
]]

SuggestedContentService = { }

local PRIORITY = {
	EVENT = 10,
	ZONE = 20,
	DUNGEON = 30,
	RAID = 40,      -- reserved for Phase 3
}

local MAX_DUNGEON_CARDS = 4

--[[
Live world events. These outrank everything else: a holiday is time-limited and will
be gone next week, whereas the zone to level in will still be there tomorrow.
]]
local function BuildEventCards(today)
	local cards = { }
	for _, event in ipairs(WorldEventService.GetActiveEvents(today)) do
		local locations = WorldEventService.GetLocations(event, today)
		local names = { }
		for _, location in ipairs(locations) do
			table.insert(names, location.name)
		end
		local uiMapID = locations[1] and locations[1].uiMapID

		local daysLeft = WorldEventService.GetDaysRemaining(event, today)
		local shortSubtitle
		if daysLeft == 1 then
			shortSubtitle = "Ends today"
		elseif daysLeft == 2 then
			shortSubtitle = "Ends tomorrow"
		elseif daysLeft then
			shortSubtitle = ("Ends in %d days"):format(daysLeft - 1)
		else
			shortSubtitle = "Live now"
		end
		local subtitle = shortSubtitle
		if #names > 0 then
			subtitle = ("%s  |  %s"):format(table.concat(names, ", "), shortSubtitle)
		end

		table.insert(cards, {
			type = "event",
			priority = PRIORITY.EVENT,
			title = event.name,
			subtitle = subtitle,
			shortSubtitle = shortSubtitle,
			description = event.note and (event.summary .. " " .. event.note) or event.summary,
			uiMapID = uiMapID,
			daysRemaining = daysLeft,
			event = event,
		})
	end
	return cards
end

local function BuildZoneCard(level, faction, race)
	local zone = ZoneService.GetBestZoneForLevel(level, faction, race)
	if not zone then return nil end

	return {
		type = "zone",
		priority = PRIORITY.ZONE,
		title = zone.name,
		subtitle = ("Levels %d-%d"):format(zone.levelRange.min, zone.levelRange.max),
		description = zone.overview,
		continent = zone.continent,
		levelRange = zone.levelRange,
		uiMapID = zone.uiMapID,
		zone = zone,
	}
end

--[[
Dungeons whose level band contains the player's level, closest recommended level
first so the most appropriate one leads.
]]
local function BuildDungeonCards(level, faction)
	local candidates = InstanceService.GetInstancesForLevelRange(
		InstanceService.GetAllDungeons(), level, level, faction)

	table.sort(candidates, function(a, b)
		local aDist = math.abs((a.recommendedLevel or a.levelRange.min) - level)
		local bDist = math.abs((b.recommendedLevel or b.levelRange.min) - level)
		if aDist ~= bDist then return aDist < bDist end
		return a.name < b.name
	end)

	local cards = { }
	for index, instance in ipairs(candidates) do
		if index > MAX_DUNGEON_CARDS then break end
		table.insert(cards, {
			type = "dungeon",
			priority = PRIORITY.DUNGEON,
			title = instance.name,
			subtitle = ("Levels %d-%d"):format(instance.levelRange.min, instance.levelRange.max),
			description = instance.overview,
			thumbnail = instance.thumbnail,
			levelRange = instance.levelRange,
			instance = instance,
		})
	end
	return cards
end

--[[
Returns the ordered card list for the given level/faction, defaulting to the current
character. Level and faction are parameters rather than being read inline so the
whole tab can be previewed at any level -- see AGC_TestSuggestionsAt.
]]
function SuggestedContentService.GetSuggestions(level, faction, race)
	level = level or PlayerContextService.GetLevel()
	faction = faction or PlayerContextService.GetFaction()
	race = race or PlayerContextService.GetRace()
	local maxLevel = PlayerContextService.GetMaxLevel()

	local cards = { }

	for _, card in ipairs(BuildEventCards()) do
		table.insert(cards, card)
	end

	-- No point suggesting somewhere to level once there are no levels left to gain.
	if level < maxLevel then
		local zoneCard = BuildZoneCard(level, faction, race)
		if zoneCard then
			table.insert(cards, zoneCard)
		end
	end

	for _, card in ipairs(BuildDungeonCards(level, faction)) do
		table.insert(cards, card)
	end

	-- Sort by priority only, preserving the order each builder chose within its own
	-- group -- BuildDungeonCards has already ranked its cards by how close the player
	-- is to each dungeon's recommended level, and that must survive. table.sort is not
	-- stable, so carry an explicit tiebreaker rather than relying on insertion order.
	for index, card in ipairs(cards) do
		card.order = index
	end
	table.sort(cards, function(a, b)
		if a.priority ~= b.priority then return a.priority < b.priority end
		return a.order < b.order
	end)

	return cards
end

--[[
The single card that leads the tab. Currently the zone card while levelling, and the
best-matched dungeon at max level; once world events land in Phase 2 a live event
outranks both.
]]
function SuggestedContentService.GetPrimarySuggestion(level, faction, race)
	return SuggestedContentService.GetSuggestions(level, faction, race)[1]
end

function SuggestedContentService.GetPriorities()
	return PRIORITY
end

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_TestSuggestionsAt = function(level, faction)
	level = level or PlayerContextService.GetLevel()
	faction = faction or PlayerContextService.GetFaction()
	local cards = SuggestedContentService.GetSuggestions(level, faction)
	print(("|cff33ff99[AGC]|r %d suggestions at level %d (%s):"):format(#cards, level, tostring(faction)))
	for index, card in ipairs(cards) do
		print(("  %d. [%s] %s -- %s"):format(index, card.type, card.title, card.subtitle))
	end
end
