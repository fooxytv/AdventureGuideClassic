--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

ForeverContentService = { }

--[[
	Which instances the Forever client actually has.

	Forever keeps most of the vanilla dungeons, adds several of its own, and of the
	vanilla raids carries over only Onyxia's Lair. The list is still moving, so ask the
	client rather than hand-tag every data file against it.

	Blizzard_EncounterJournal does not load here -- it is gated to the "standard" and
	"classic" game types, and Forever's is "camelot" -- but the EJ_ functions are
	engine-side and answer anyway. Our own instanceID is the journal's instance id, so
	the two line up without name matching, which keeps this locale-proof.

	EJ_GetNumTiers() returns 0 here, so the tier walk Blizzard's UI uses is unavailable.
	Indexing instances directly is not.
]]

-- A client that never returns nil would otherwise spin here.
local MAX_INSTANCES = 250

-- How much overlap with our own data before the enumeration is trusted. If Forever
-- renumbers its journal, a confident but wrong id set would hide the entire guide, and
-- showing too much beats showing nothing.
local MIN_TRUSTED_MATCHES = 5

-- Vanilla raids Forever does not have, for when the journal does not answer. Onyxia's
-- Lair (249) is absent from the list on purpose: it is the one that carries over.
local ABSENT_ON_FOREVER = {
	[741] = true,   -- Molten Core
	[742] = true,   -- Blackwing Lair
	[743] = true,   -- Ruins of Ahn'Qiraj
	[744] = true,   -- Temple of Ahn'Qiraj
	[745] = true,   -- Zul'Gurub
	[746] = true,   -- Naxxramas
}

local journalInstanceIDs        -- journalInstanceID -> true
local trusted
local resolved

--[[
	A plain enumeration, with no attempt to wake the journal first.

	Blizzard's UI calls C_EncounterJournal.OnOpen() and InitalizeSelectedTier() when it
	opens, which looks like the way to get data out of a journal nothing else
	initialises here. It is not. Both are protected, so they raise
	ADDON_ACTION_FORBIDDEN and taint the addon, and pcall prevents neither -- the call is
	refused rather than erroring, so it returns ok while the event fires anyway. Tested
	on Forever: the journal reads empty before and after, so the taint bought nothing.

	EJ_GetInstanceByIndex is unprotected and answers honestly. One pass per session, and
	it starts working on its own if this client ever ships journal data.
]]
local function EnumerateJournal()
	if type(EJ_GetInstanceByIndex) ~= "function" then return nil end

	local ids = { }
	local count = 0
	for _, isRaid in ipairs({ false, true }) do
		for index = 1, MAX_INSTANCES do
			local ok, instanceID = pcall(EJ_GetInstanceByIndex, index, isRaid)
			if not ok or not instanceID then break end
			if not ids[instanceID] then
				ids[instanceID] = true
				count = count + 1
			end
		end
	end

	if count == 0 then return nil end
	return ids
end

local function CountMatches(ids)
	if not InstanceService or not InstanceService.GetAllInstances then return 0 end
	local matches = 0
	for _, instance in ipairs(InstanceService.GetAllInstances()) do
		if instance.instanceID and ids[instance.instanceID] then
			matches = matches + 1
		end
	end
	return matches
end

local function Resolve()
	if resolved then return end
	resolved = true

	journalInstanceIDs = EnumerateJournal()
	if not journalInstanceIDs then
		trusted = false
		return
	end

	trusted = CountMatches(journalInstanceIDs) >= MIN_TRUSTED_MATCHES
end

function ForeverContentService.Refresh()
	resolved = false
	journalInstanceIDs = nil
	trusted = nil
end

-- nil when the journal could not be read or its answer was not trustworthy.
function ForeverContentService.GetJournalInstanceIDs()
	Resolve()
	if not trusted then return nil end
	return journalInstanceIDs
end

function ForeverContentService.IsJournalUsable()
	Resolve()
	return trusted == true
end

-- The journal decides whenever it answers. Unknown beats hidden, so an instance it has
-- never heard of stays visible rather than vanishing on a guess.
function ForeverContentService.HasInstance(instance)
	if not instance or not instance.instanceID then return true end

	local ids = ForeverContentService.GetJournalInstanceIDs()
	if ids then
		return ids[instance.instanceID] == true
	end

	return not ABSENT_ON_FOREVER[instance.instanceID]
end

-- Journal instances this client has that our data does not cover yet, so the gap can be
-- listed rather than guessed at. Used by /agcprobe.
function ForeverContentService.GetUnknownInstanceIDs()
	Resolve()
	if not journalInstanceIDs then return { } end

	local known = { }
	if InstanceService and InstanceService.GetAllInstances then
		for _, instance in ipairs(InstanceService.GetAllInstances()) do
			if instance.instanceID then known[instance.instanceID] = true end
		end
	end

	local unknown = { }
	for instanceID in pairs(journalInstanceIDs) do
		if not known[instanceID] then table.insert(unknown, instanceID) end
	end
	table.sort(unknown)
	return unknown
end

-- The journal is not always ready at load, so rebuild once the world is in. Only on
-- Forever: nothing else consults this service, and a frame registered on a client that
-- will never call it is just something to go wrong later.
if Compat.isForever then
	local refreshFrame = CreateFrame("Frame")
	refreshFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	refreshFrame:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		ForeverContentService.Refresh()
	end)
end
