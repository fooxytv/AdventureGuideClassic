--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
	Which client the addon is running on.

	Forever (1.60.x) is the reason this file exists. It reports
	WOW_PROJECT_ID == WOW_PROJECT_MAINLINE exactly as retail does, yet carries a
	vanilla-shaped interface version of 16001, so neither value identifies it alone --
	the pair does. Blizzard's own name for the client is "camelot", which is the token
	its TOC files gate on, but nothing in Lua exposes that, so the pair is what we get.

	Resolved once here so no call site has to reason about it. Nothing else in the
	addon should read GetBuildInfo or WOW_PROJECT_ID directly.
]]

Compat = { }

local tocVersion = select(4, GetBuildInfo())

local isMainlineProject = WOW_PROJECT_ID ~= nil
	and WOW_PROJECT_MAINLINE ~= nil
	and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- Retail's interface versions run to six digits (110000 and up). Forever's are five.
local RETAIL_MIN_TOC = 100000

--[[
	Which .toc the client chose to load, which is the client's own answer about what it is.

	Forever used to report WOW_PROJECT_MAINLINE, so that plus a five-digit interface
	version identified it. Build 1.60.1.70205 reports WOW_PROJECT_ID 18 instead -- neither
	mainline nor classic -- so the test failed and Forever was detected as Era, hiding its
	own instances and offering Era's.

	An unfamiliar project id will keep happening on a beta. The loaded .toc does not have
	that problem: the client matches our file suffixes itself, so only a camelot client
	loads AdventureGuideClassic_Camelot.toc. The project-id rule is kept underneath for
	older Forever builds and for any client where the metadata cannot be read.
]]
local function LoadedTocFlavor()
	if not (C_AddOns and C_AddOns.GetAddOnMetadata) then return nil end
	local ok, value = pcall(C_AddOns.GetAddOnMetadata, addonName, "X-TocFlavor")
	if ok then return value end
	return nil
end

local tocFlavor = LoadedTocFlavor()
local isForeverToc = (tocFlavor == "camelot")
	or (tocFlavor == "mainline" and tocVersion < RETAIL_MIN_TOC)

--[[
	A third signal, because the first two can both fail at once.

	The .toc test needs metadata that may not be readable while the addon is still
	loading, and the project-id test needs an id we have seen before. The interface
	version is readable from the first line of the file and belongs to nobody else:
	Forever's 1.60.x reports 16001, while Era is 115xx, TBC 205xx, Wrath 3xxxx, Cata
	4xxxx and retail 11xxxx. Nothing on the Classic line is anywhere near 16xxx.

	Excluded for a client reporting WOW_PROJECT_CLASSIC, so that if Era ever does reach
	1.60 it is not mistaken for Forever.
]]
local isClassicProject = WOW_PROJECT_ID ~= nil
	and WOW_PROJECT_CLASSIC ~= nil
	and WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local isForeverVersion = tocVersion >= 16000
	and tocVersion <= 16999
	and not isClassicProject

local flavor
if isForeverToc or isForeverVersion then
	flavor = "forever"
elseif isMainlineProject then
	flavor = (tocVersion < RETAIL_MIN_TOC) and "forever" or "retail"
elseif tocVersion >= 40000 then
	flavor = "cata"
elseif tocVersion >= 30000 then
	flavor = "wrath"
elseif tocVersion >= 20000 then
	flavor = "tbc"
else
	flavor = "era"
end

-- What LoadedTocFlavor() saw during load, kept so /agcprobe can show it. Metadata read
-- later may differ from metadata read while the addon is still loading, and that
-- difference is the first thing to check when detection looks wrong.
Compat.tocFlavorAtLoad = tocFlavor

Compat.tocVersion = tocVersion
Compat.flavor = flavor

Compat.isForever = (flavor == "forever")
Compat.isRetail = (flavor == "retail")
Compat.isTBC = (flavor == "tbc")

--[[
	The Classic progression line: Era, Season of Discovery, TBC, Wrath, Cata.

	Forever is excluded on purpose. Its interface version would pass for vanilla, but
	it is a separate content line with its own instance list, and treating it as Era
	offers the player raids that do not exist there.
]]
-- Era, SoD, TBC, Wrath, Cata. Derived from the resolved flavour rather than from the
-- project id, which said "not mainline" for Forever's new id and so counted it as Classic.
Compat.isClassicLine = (flavor == "era" or flavor == "tbc"
	or flavor == "wrath" or flavor == "cata")

--[[
	The 1.x Classic client specifically -- Era or SoD, but not TBC and not Forever.
	This is the distinction the loot and spell filters care about, since their data is
	authored against vanilla.
]]
Compat.isEraClient = Compat.isClassicLine and tocVersion < 20000

--[[
	C_Seasons is a Classic-line namespace and is absent on Forever, where reaching it
	unguarded is a hard error rather than a nil result. Every season read goes through
	here so a missing namespace can never reach a call site.
]]
function Compat.GetActiveSeason()
	if C_Seasons and C_Seasons.GetActiveSeason then
		return C_Seasons.GetActiveSeason() or 0
	end
	return 0
end

function Compat.HasActiveSeason()
	if C_Seasons and C_Seasons.HasActiveSeason then
		return C_Seasons.HasActiveSeason() == true
	end
	return false
end

--[[
	Clients whose loot tables are vanilla's: Era, SoD and Forever.

	Forever's instance list differs from Era's, but where it shares an instance it
	shares the item ids, so loot tagged "era" or "classic" is right there and loot
	tagged "tbc" is not. This is deliberately a wider set than isEraClient.
]]
Compat.isVanillaLoot = Compat.isEraClient or Compat.isForever

--[[
	A spell's name and icon.

	The GetSpellInfo global is gone on the mainline-family clients, Forever included,
	where calling it is a nil-value error. C_Spell.GetSpellInfo replaces it and returns
	a table rather than a list of values, so this is a real shim rather than an alias
	like the GetItemInfo ones dotted around the addon -- C_Item kept the old signature,
	C_Spell did not.

	Returns nil for an unknown spell on every client, so callers have one case to
	handle instead of two.
]]
function Compat.GetSpellInfo(spellID)
	if not spellID then return nil end

	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(spellID)
		if not info then return nil end
		return info.name, info.iconID
	end

	if _G.GetSpellInfo then
		local name, _, icon = _G.GetSpellInfo(spellID)
		return name, icon
	end

	return nil
end

--[[
	The spell's own description text, which is what the Abilities tab falls back to
	when an ability carries no written body.

	C_Spell on the mainline family, the global elsewhere. Returns nil rather than the
	empty string the client gives before spell data has loaded, so callers have one
	case to handle.
]]
function Compat.GetSpellDescription(spellID)
	if not spellID then return nil end

	local text
	if C_Spell and C_Spell.GetSpellDescription then
		text = C_Spell.GetSpellDescription(spellID)
	elseif _G.GetSpellDescription then
		text = _G.GetSpellDescription(spellID)
	end

	if text and text ~= "" then return text end
	return nil
end

--[[
	Ask the client to load a spell it has not cached yet.

	Core spells are there from the start, but a Forever-only id comes back with an
	empty description until this has been called and SPELL_DATA_LOAD_RESULT has
	fired. Absent on the Classic clients, where the description is already there.
]]
function Compat.RequestSpellData(spellID)
	if not spellID then return false end
	if C_Spell and C_Spell.RequestLoadSpellData then
		C_Spell.RequestLoadSpellData(spellID)
		return true
	end
	return false
end

--[[
	The quest log, read the same way on every client.

	The log is the one place that records where a character has been questing, which
	is what the suggested-content reminder needs: its header rows are zone names and
	the quests beneath each one are in that zone.

	C_QuestLog.GetInfo returns a table on the mainline family, where the
	GetQuestLogTitle global was removed outright; the classic clients still have the
	global and hand the same facts back as a list, in a different order. Both
	namespace functions are tested together rather than separately, so a client that
	has only one of them is not read through half of each API.

	Returns a table with the four fields the addon cares about, or nil past the end
	of the log, so callers have one shape to handle.
]]
local function HasModernQuestLog()
	return not not (C_QuestLog and C_QuestLog.GetInfo
			and C_QuestLog.GetNumQuestLogEntries)
end

function Compat.GetNumQuestLogEntries()
	if HasModernQuestLog() then
		return C_QuestLog.GetNumQuestLogEntries() or 0
	end
	if GetNumQuestLogEntries then
		-- Two returns on the classic clients: entries, then quests. Entries counts
		-- the zone headers, and walking them is the point of this.
		return (GetNumQuestLogEntries()) or 0
	end
	return 0
end

function Compat.GetQuestLogEntry(index)
	if not index then return nil end

	if HasModernQuestLog() then
		local info = C_QuestLog.GetInfo(index)
		if not info then return nil end
		return {
			title = info.title,
			isHeader = info.isHeader,
			level = info.level,
			questID = info.questID,
		}
	end

	if GetQuestLogTitle then
		local title, level, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
		if not title then return nil end
		return { title = title, isHeader = isHeader, level = level, questID = questID }
	end

	return nil
end

--[[
	The tab button template differs by client.

	Era and TBC have CharacterFrameTabButtonTemplate. On Forever the file defining it
	is gated to the cata and mists game types, so it is absent, and the mainline
	family's PanelTabButtonTemplate is what exists instead. That one carries no
	*Disabled textures and names its pieces by parentKey rather than globally, so
	callers must not assume the old global texture names exist.

	This is the only Blizzard template the addon uses that is not on every client --
	the other nineteen were each checked against Forever's own TOC gating.
]]
Compat.TabButtonTemplate = Compat.isForever
	and "PanelTabButtonTemplate"
	or "CharacterFrameTabButtonTemplate"

--[[
	Events this client will not let an addon register.

	Forever's own API documentation marks COMBAT_LOG_EVENT_UNFILTERED with
	HasRestrictions = true, and registering it raises ADDON_ACTION_FORBIDDEN, which
	both spams the error log and stops the rest of that frame's registrations. It is
	the only event the addon uses that this applies to -- every other one was checked
	against the same documentation and is clear.
]]
--[[
	The combat log is wanted only on the Classic line, as the fallback for ENCOUNTER_END
	and BOSS_KILL not firing there. Asked as a positive test rather than "not Forever", so
	a client this file does not recognise is treated as not needing it rather than being
	handed an event it may refuse. Registering a restricted event raises
	ADDON_ACTION_FORBIDDEN, which pcall does not stop.
]]
local RESTRICTED_EVENTS = { }
if not Compat.isClassicLine then
	RESTRICTED_EVENTS.COMBAT_LOG_EVENT_UNFILTERED = true
end

function Compat.IsEventAvailable(event)
	return not RESTRICTED_EVENTS[event]
end

--[[
	Registers events one at a time, skipping any this client restricts and guarding
	the rest, so one refused event cannot take its neighbours down with it. Returns
	the list that was skipped, or nil.
]]
function Compat.RegisterEvents(frame, ...)
	local skipped
	for index = 1, select("#", ...) do
		local event = select(index, ...)
		if Compat.IsEventAvailable(event) then
			pcall(frame.RegisterEvent, frame, event)
		else
			skipped = skipped or { }
			table.insert(skipped, event)
		end
	end
	return skipped
end

local SEASON_OF_DISCOVERY = 2

function Compat.IsSoD()
	return Compat.isEraClient and Compat.GetActiveSeason() == SEASON_OF_DISCOVERY
end

function Compat.IsEra()
	return Compat.isEraClient and Compat.GetActiveSeason() ~= SEASON_OF_DISCOVERY
end

--[[
	Pretending to be a different client, for testing content this one cannot show.

	This works because of two things that are true elsewhere. Every flag above is
	read live -- some forty reads across the addon, not one of them cached into a
	local at file scope -- and ShouldIncludeInstance filters per query rather than
	at registration, with all five clients' data registered regardless. So the
	content is already in memory and merely filtered out, and changing these flags
	changes what the journal shows without a reload.

	Session only, and deliberately not in SavedVariables: a journal that quietly
	kept lying about the client after a reload is a bug report waiting to happen.
]]
local real = {
	flavor = Compat.flavor,
	tocVersion = Compat.tocVersion,
	isForever = Compat.isForever,
	isRetail = Compat.isRetail,
	isTBC = Compat.isTBC,
	isClassicLine = Compat.isClassicLine,
	isEraClient = Compat.isEraClient,
	isVanillaLoot = Compat.isVanillaLoot,
	GetActiveSeason = Compat.GetActiveSeason,
	HasActiveSeason = Compat.HasActiveSeason,
}

-- SoD is not a flavour of its own; it is Era with a season, which is exactly how
-- the real detection sees it.
local PRETEND = {
	era     = { flavor = "era",     tocVersion = 11509, season = 0 },
	sod     = { flavor = "era",     tocVersion = 11509, season = SEASON_OF_DISCOVERY },
	tbc     = { flavor = "tbc",     tocVersion = 20506, season = 0 },
	forever = { flavor = "forever", tocVersion = 16001, season = 0 },
}

function Compat.SetPretend(name)
	if not name then
		Compat.ClearPretend()
		return true
	end
	local want = PRETEND[name]
	if not want then return false end

	Compat.pretending = name
	Compat.flavor = want.flavor
	Compat.tocVersion = want.tocVersion
	Compat.isForever = (want.flavor == "forever")
	Compat.isRetail = false
	Compat.isTBC = (want.flavor == "tbc")
	Compat.isClassicLine = (want.flavor == "era" or want.flavor == "tbc")
	Compat.isEraClient = Compat.isClassicLine and want.tocVersion < 20000
	Compat.isVanillaLoot = Compat.isEraClient or Compat.isForever
	Compat.GetActiveSeason = function() return want.season end
	Compat.HasActiveSeason = function() return want.season ~= 0 end
	return true
end

function Compat.ClearPretend()
	Compat.pretending = nil
	for key, value in pairs(real) do
		Compat[key] = value
	end
end

--[[
	The player's level, so one override reaches every reader.

	Suggestions rank instances against it, so a pretend level is the only way to see
	what the Suggested Content tab offers someone else.
]]
local pretendLevel

function Compat.SetPretendLevel(level)
	pretendLevel = level
end

function Compat.GetPretendLevel()
	return pretendLevel
end

function Compat.GetPlayerLevel()
	if pretendLevel then return pretendLevel end
	return (UnitLevel and UnitLevel("player")) or 1
end
