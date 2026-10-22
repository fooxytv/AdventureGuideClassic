--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

LevellingService = { }

--[[
	Where this character was last levelling, so the journal can answer the question
	someone has after a fortnight away: where was I?

	Nothing in the client records it. There is no "last zone" to read, and the quest
	log is the nearest thing -- it says what is unfinished, which is close but not
	the same question. So this watches XP arrive and remembers where it happened.

	XP rather than presence. Time spent in a zone would be the obvious measure and
	is the wrong one: it counts the half hour spent flying over Loch Modan and the
	afternoon parked in Ironforge. XP is the signal that a character was actually
	getting somewhere.

	In-memory is the source of truth and is mirrored into SavedVariables, as
	ProgressService does, because services load before Main.lua binds it.
]]
local remembered
local candidateZone, candidateGains = nil, 0
local loaded = false

--[[
	How many separate XP gains a zone needs before it displaces the remembered one.

	One gain is not evidence: handing a quest in at Ironforge pays out in Ironforge,
	and a single kill while riding through somewhere counts the same as an afternoon
	there. Three is enough that a hand-in or a wandering boar cannot overwrite a
	week in Stranglethorn, and small enough that genuinely moving on is recorded
	within a few minutes of arriving.
]]
local GAINS_TO_REMEMBER = 3

local SECONDS_PER_DAY = 86400

--[[
	Per character, like ProgressService: where you were levelling is a fact about a
	character, not an account. UnitName is nil until PLAYER_LOGIN, so this returns
	nil before then and the caller retries.
]]
local function GetCharacterKey()
	local name = UnitName("player")
	local realm = GetRealmName()
	if not name or not realm then return nil end
	return name .. "-" .. realm
end

local function Store()
	if not SavedVariables then return end
	local charKey = GetCharacterKey()
	if not charKey then return end
	SavedVariables.Levelling = SavedVariables.Levelling or { }
	SavedVariables.Levelling[charKey] = remembered
end

--[[
	Read once, then stay authoritative in memory. Guarded for the same reason
	ProgressService guards its own: Store writes memory over what is saved, so a
	write before the first read would throw the saved record away.
]]
local function Load()
	if loaded then return true end
	if not SavedVariables then return false end
	local charKey = GetCharacterKey()
	if not charKey then return false end
	local record = SavedVariables.Levelling and SavedVariables.Levelling[charKey]
	if type(record) == "table" and record.zone then
		remembered = record
	end
	loaded = true
	return true
end

local function CurrentZone()
	local zone = GetRealZoneText and GetRealZoneText()
	if zone == nil or zone == "" then
		zone = GetZoneText and GetZoneText()
	end
	if zone == "" then return nil end
	return zone
end

local function PlayerLevel()
	return (UnitLevel and UnitLevel("player")) or 1
end

--[[
	One XP gain, wherever the player is standing.

	Public so the test harness and the event frame drive the same path rather than
	the harness reaching inside.

	Instances are skipped outright. Clearing Deadmines pays a great deal of XP, and
	answering "where were you levelling" with a dungeon is both true and useless --
	what the player wants back is the zone they were questing in, which the dungeon
	run was a detour from. Suggested content already has panes for dungeons.
]]
function LevellingService.NoteXPGain()
	if IsInInstance and IsInInstance() then return end
	local zone = CurrentZone()
	if not zone then return end
	Load()

	if remembered and remembered.zone == zone then
		remembered.level = PlayerLevel()
		remembered.when = time()
		candidateZone, candidateGains = nil, 0
		Store()
		return
	end

	if candidateZone ~= zone then
		candidateZone, candidateGains = zone, 0
	end
	candidateGains = candidateGains + 1
	if candidateGains < GAINS_TO_REMEMBER then return end

	remembered = { zone = zone, level = PlayerLevel(), when = time() }
	candidateZone, candidateGains = nil, 0
	Store()
end

--[[
	Set the remembered zone outright, for the in-game helper and the tests. Takes
	effect immediately rather than after GAINS_TO_REMEMBER, which is the point of
	it.
]]
function LevellingService.Remember(zone, level, when)
	Load()
	if not zone then
		remembered = nil
	else
		remembered = {
			zone = zone,
			level = level or PlayerLevel(),
			when = when or time(),
		}
	end
	candidateZone, candidateGains = nil, 0
	Store()
end

--[[
	Quests in the log, counted by the zone they belong to.

	The log is grouped under zone headers, so the header rows are the zone names and
	everything between two headers belongs to the one above it. A quest ahead of any
	header -- which should not happen, but the order is the client's to choose -- is
	left uncounted rather than attributed to a guess.
]]
local function QuestsByZone()
	local counts, titles = { }, { }
	local zone
	for index = 1, Compat.GetNumQuestLogEntries() do
		local entry = Compat.GetQuestLogEntry(index)
		if entry then
			if entry.isHeader then
				zone = entry.title
			elseif zone then
				counts[zone] = (counts[zone] or 0) + 1
				titles[zone] = titles[zone] or { }
				table.insert(titles[zone], entry.title)
			end
		end
	end
	return counts, titles
end

--[[
	The zone carrying the most quests, as the answer for a character with nothing
	recorded yet -- one who was levelling before the addon learned to watch, or who
	has not killed anything since logging in. Name breaks a tie, so two zones
	holding three quests each do not swap places between refreshes.
]]
local function BusiestQuestZone(counts)
	local best, bestCount = nil, 0
	for zone, count in pairs(counts) do
		if count > bestCount or (count == bestCount and zone < best) then
			best, bestCount = zone, count
		end
	end
	return best, bestCount
end

--[[
	Where this character left off, or nil when there is honestly nothing to say.

	`days` is whole days since the last gain, so the view can say "yesterday"
	rather than a timestamp. `remembered` is false when the answer came from the
	quest log instead, because that one is a deduction and the view words it as one.
]]
function LevellingService.GetWhereYouLeftOff()
	Load()
	local counts, titles = QuestsByZone()

	if remembered and remembered.zone then
		local days
		if remembered.when then
			days = math.max(math.floor((time() - remembered.when) / SECONDS_PER_DAY), 0)
		end
		return {
			zone = remembered.zone,
			level = remembered.level,
			when = remembered.when,
			days = days,
			quests = counts[remembered.zone] or 0,
			-- The names as well as the count, because three lines of pane will not
			-- hold them and a tooltip will.
			questTitles = titles[remembered.zone],
			remembered = true,
		}
	end

	local zone, quests = BusiestQuestZone(counts)
	if not zone then return nil end
	return {
		zone = zone,
		quests = quests,
		questTitles = titles[zone],
		remembered = false,
	}
end

--[[
	Pretend a character was levelling somewhere, so the reminder can be read in game
	without playing an afternoon first. The third argument is in days.
]]
_G.AGC_SetLeftOff = function(zone, level, daysAgo)
	LevellingService.Remember(zone, level, time() - (daysAgo or 0) * SECONDS_PER_DAY)
	local state = LevellingService.GetWhereYouLeftOff()
	if not state then
		print("AGC: nothing remembered.")
		return
	end
	print(("AGC: left off in %s at level %s, %s days ago, %d quests in the log.")
			:format(tostring(state.zone), tostring(state.level),
					tostring(state.days), state.quests))
end

local xpFrame = CreateFrame("Frame")
xpFrame:SetScript("OnEvent", function()
	LevellingService.NoteXPGain()
end)
Compat.RegisterEvents(xpFrame, "PLAYER_XP_UPDATE")
