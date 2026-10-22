--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

SuggestionService = { }

--[[
	What to do next, ranked.

	Retail answers this with C_AdventureJournal, which exists on no client this
	addon runs on, so the ranking is ours. It is built from three things the guide
	already knows -- the player's level against the instance's, what they have
	beaten, and what they are still hunting -- and deliberately from nothing else.

	A score rather than tiers. Tiers were the first attempt and they rank badly:
	putting "has a wishlist item" above everything means one item parked in Molten
	Core outranks the dungeon a level-20 player should actually be in. A score lets
	a wishlist pull content up without letting it ignore the level entirely.

	Lower is better throughout, so the sort reads like a distance.
]]

--[[
	How far outside the recommended band the player is, in levels. Zero anywhere
	inside it, so every well-matched instance ties and the other terms decide.
]]
local function LevelDistance(instance, playerLevel)
	local range = instance.levelRange
	if not range then return nil end
	local low, high = range[1], range[2]
	if playerLevel < low then return low - playerLevel end
	if playerLevel > high then return playerLevel - high end
	return 0
end

--[[
	What an instance with no level range scores.

	Forever's eleven instances have none -- AtlasLoot has never heard of them and
	nothing in the client records one -- so they cannot be placed against the
	player at all. Twelve puts them below anything that fits and above content the
	player has outgrown by a wide margin, which is the honest position for "we do
	not know": offerable, never confidently first.
]]
local UNKNOWN_LEVEL_DISTANCE = 12

-- Beaten everything here. Not hidden, because a player may want the loot again,
-- but far enough down that it never leads.
local CLEARED_PENALTY = 25

-- A small pull toward somewhere new, enough to break a tie between two instances
-- that fit equally well and no more.
local UNVISITED_BONUS = 2

-- Each still-wanted item pulls an instance up a level's worth of fit, to a limit.
-- Five items is already a reason to go; fifty is not ten times the reason.
local WANTED_WEIGHT = 3
local WANTED_CAP = 5

--[[
	Items still wanted, by the instance they were taken from.

	Keyed on the instance *name*, because that is all a wishlist entry stores.
	RepairSources exists for the same reason and fixes the entries that recorded
	"Unknown" before the loot rows carried their boss.
]]
local function WantedByInstance()
	local counts, samples = { }, { }
	if not WishlistService then return counts, samples end
	for _, data in ipairs(WishlistService.GetAllItems()) do
		local name = data.sourceInstance
		if name and WishlistService.IsWanted(data.itemID) then
			counts[name] = (counts[name] or 0) + 1
			samples[name] = samples[name] or data
		end
	end
	return counts, samples
end

--[[
	Bosses beaten, read from ProgressService rather than DiscoveryService.

	GetProgress answers about *discovery* and returns the total twice while that
	mode is off, which would make every instance look finished to this.
]]
local function DefeatedCount(instance)
	local defeated = 0
	for _, encounter in ipairs(instance) do
		if ProgressService.IsDefeated(instance.name, encounter) then
			defeated = defeated + 1
		end
	end
	return defeated
end

local function PlayerLevel()
	return (UnitLevel and UnitLevel("player")) or 1
end

--[[
	Which of the four things to say about an instance. The view turns this into a
	sentence; the service only decides which one is true, so the choice is testable
	without frames.
]]
local function KindFor(wanted, defeated, total)
	if wanted > 0 then return "wishlist" end
	if defeated == 0 then return "unvisited" end
	if defeated < total then return "partial" end
	return "cleared"
end

--[[
	Every instance this character could walk into today, ranked.

	An instance the player is too low for is left out rather than ranked badly.
	"Suggested content" that cannot be entered is not a suggestion, and the door is
	the one number that is not a matter of taste. An instance with no minLevel --
	Forever's -- has no door to fail, so it stays.
]]
function SuggestionService.GetRanked()
	local playerLevel = PlayerLevel()
	local counts, samples = WantedByInstance()
	local ranked = { }

	local instances = { }
	for _, dungeon in ipairs(InstanceService.GetDungeons()) do
		table.insert(instances, dungeon)
	end
	for _, raid in ipairs(InstanceService.GetRaids()) do
		table.insert(instances, raid)
	end

	for _, instance in ipairs(instances) do
		local total = #instance
		local locked = instance.minLevel and playerLevel < instance.minLevel
		if total > 0 and not locked then
			local wanted = counts[instance.name] or 0
			local defeated = DefeatedCount(instance)
			local distance = LevelDistance(instance, playerLevel) or UNKNOWN_LEVEL_DISTANCE
			local score = distance
			if defeated >= total then
				score = score + CLEARED_PENALTY
			elseif defeated == 0 then
				score = score - UNVISITED_BONUS
			end
			score = score - math.min(wanted, WANTED_CAP) * WANTED_WEIGHT
			table.insert(ranked, {
				instance = instance,
				name = instance.name,
				kind = KindFor(wanted, defeated, total),
				score = score,
				wanted = wanted,
				wantedItem = samples[instance.name],
				defeated = defeated,
				total = total,
				levelRange = instance.levelRange,
			})
		end
	end

	-- Name breaks ties, so the order is stable rather than dependent on which way
	-- the instance lists happened to be built.
	table.sort(ranked, function(a, b)
		if a.score ~= b.score then return a.score < b.score end
		return a.name < b.name
	end)
	return ranked
end

--[[
	The top few, for the three panes the tab draws. Asking for more than there are
	returns what there is rather than padding.
]]
function SuggestionService.GetTop(count)
	local ranked = SuggestionService.GetRanked()
	local top = { }
	for index = 1, math.min(count or 3, #ranked) do
		top[index] = ranked[index]
	end
	return top
end
