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
	An open quest pulls an instance up too, a little less hard than a wanted item.

	Deliberately less: a wishlist entry is loot the player went and chose, where a
	dungeon quest is one the game handed out. Capped for the same reason as the
	loot -- Blackrock Depths has a dozen, and twelve is not twelve times the reason
	to go.
]]
local QUEST_WEIGHT = 2
local QUEST_CAP = 4

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

--[[
	Quests here that are still worth walking in with, and one of them to name.

	Still worth it means: not already handed in, and not above the player's level,
	since a quest that cannot be picked up yet is not a reason to go now. The
	faction filter is QuestService's own, so a Horde player is never pulled toward
	an Alliance quest.

	Quest data ships for Era's nineteen dungeons, so most instances answer zero and
	the term simply drops out of their score. That includes every raid and every TBC
	dungeon, which is a gap in the data rather than a judgement about them.
]]
local function OutstandingQuests(instance, playerLevel)
	if not QuestService then return 0, nil end
	local count, sample = 0, nil
	for _, quest in ipairs(QuestService.GetQuests(instance.name)) do
		local reachable = not quest.minLevel or playerLevel >= quest.minLevel
		if reachable and QuestService.GetState(quest.id) ~= "completed" then
			count = count + 1
			sample = sample or quest
		end
	end
	return count, sample
end

local function PlayerLevel()
	-- Through Compat so the tuner's pretend level reaches the ranking.
	return Compat.GetPlayerLevel()
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
	Every instance this client shows, dungeons then raids. Both lists are already
	filtered for the client and the season by InstanceService, so this is only
	putting them end to end.
]]
local function AllInstances()
	local instances = { }
	for _, dungeon in ipairs(InstanceService.GetDungeons()) do
		table.insert(instances, dungeon)
	end
	for _, raid in ipairs(InstanceService.GetRaids()) do
		table.insert(instances, raid)
	end
	return instances
end

-- Raids by name, because an entry carries the instance table and not which list
-- it came out of. ui/Suggest.lua works the same question out the same way.
local function RaidNames()
	local names = { }
	for _, raid in ipairs(InstanceService.GetRaids()) do
		names[raid.name] = true
	end
	return names
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

	for _, instance in ipairs(AllInstances()) do
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
			local quests, questSample = OutstandingQuests(instance, playerLevel)
			score = score - math.min(quests, QUEST_CAP) * QUEST_WEIGHT
			table.insert(ranked, {
				instance = instance,
				name = instance.name,
				kind = KindFor(wanted, defeated, total),
				score = score,
				wanted = wanted,
				wantedItem = samples[instance.name],
				quests = quests,
				questName = questSample and questSample.name,
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
--[[
	The next instance that opens up, for the "coming up" pane.

	GetRanked deliberately leaves out anything the player is too low to enter, so
	the three panes can only ever show today. That makes the door the one thing the
	tab never mentions, and the door is the most useful thing to know at level 22:
	Scarlet Monastery is four levels away.

	The lowest minLevel above the player, name breaking a tie so the pane does not
	swap between two dungeons that unlock together. An instance with no minLevel --
	Forever's have none -- has no door to be waiting at, so it is not a candidate.
]]
function SuggestionService.GetNextUnlock()
	local playerLevel = PlayerLevel()
	local best
	for _, instance in ipairs(AllInstances()) do
		local minLevel = instance.minLevel
		if #instance > 0 and minLevel and minLevel > playerLevel
				and (not best or minLevel < best.minLevel
					or (minLevel == best.minLevel and instance.name < best.instance.name)) then
			best = { instance = instance, minLevel = minLevel }
		end
	end
	if not best then return nil end
	return {
		instance = best.instance,
		name = best.instance.name,
		kind = "locked",
		unlockLevel = best.minLevel,
		total = #best.instance,
		defeated = 0,
		levelRange = best.instance.levelRange,
	}
end

--[[
	What the pane beside the big one holds: content the ranking cannot offer.

	Deliberately not the second-ranked suggestion. That pane is read next to the
	big one rather than after it, so repeating the same list there wastes the only
	other place on the page -- and the arrows now move the big pane alone, which
	left this one showing the runner-up for ever.

	What is next to unlock, then. A character with nothing left to unlock is at the
	level cap, where the raids are the content they have not run, so the best-ranked
	one stands in. Takes the ranked list rather than asking for it again, because
	the caller has just built one.
]]
function SuggestionService.GetCompanion(ranked)
	ranked = ranked or SuggestionService.GetRanked()

	local unlock = SuggestionService.GetNextUnlock()
	if unlock then return unlock end

	local raids = RaidNames()
	for _, entry in ipairs(ranked) do
		if raids[entry.name] then return entry end
	end

	return ranked[2]
end
