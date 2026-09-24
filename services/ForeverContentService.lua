--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

ForeverContentService = { }

--[[
	Which instances the Forever client actually has.

	Forever ships a different instance list to Classic Era. It keeps most of the
	vanilla dungeons and adds several of its own, but of the vanilla raids only
	Onyxia's Lair carries over -- Molten Core, Blackwing Lair, both Ahn'Qiraj raids,
	Zul'Gurub and Naxxramas are not in it. Offering those would be worse than useless.

	Rather than hand-tag every data file against a content list that is still moving,
	ask the client. Blizzard's own journal UI does not load here (Blizzard_EncounterJournal
	is gated to the "standard" and "classic" game types, and Forever's is "camelot"),
	but the underlying EJ_ functions are engine-side and answer regardless. The
	instanceID on our own data is already the journal's instance id, so the two line up
	without any name matching -- which also keeps this locale-proof.

	EJ_GetNumTiers() returns 0 on this client, so the tier walk Blizzard's UI uses is
	not available. Indexing instances directly is.
]]

-- A client that never returns nil would otherwise spin here.
local MAX_INSTANCES = 250

--[[
	How many of our own instances the enumeration has to account for before we trust
	it. If Forever ever renumbers its journal, a confident-looking but wrong id set
	would hide the entire guide; a near-empty intersection is the signal for that, and
	showing too much beats showing nothing.
]]
local MIN_TRUSTED_MATCHES = 5

--[[
	Vanilla raids Forever does not have, by journal instance id.

	The journal is the authority whenever it answers; this is the fallback for when it
	does not, so the guide never offers Molten Core on a client that has no Molten
	Core. Onyxia's Lair (249) is deliberately absent from the list -- it is the one
	vanilla raid that carries over.
]]
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

--[[
	Drop the cached enumeration so the next read rebuilds it. The journal is not
	necessarily populated the instant the addon loads, so this is called once the
	world is in.
]]
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

--[[
	Whether an instance from our own data exists on this client.

	When the journal answers it decides, and unknown beats hidden -- an instance the
	journal has never heard of stays visible rather than vanishing on a guess. When the
	journal does not answer at all, the hand-maintained list above carries it, so the
	worst case is a guide that looks like Era's minus the raids that certainly are not
	there.
]]
function ForeverContentService.HasInstance(instance)
	if not instance or not instance.instanceID then return true end

	local ids = ForeverContentService.GetJournalInstanceIDs()
	if ids then
		return ids[instance.instanceID] == true
	end

	return not ABSENT_ON_FOREVER[instance.instanceID]
end

--[[
	Journal instances this client has that our data does not cover yet, so the gap can
	be listed rather than guessed at. Used by the /agcprobe diagnostic.
]]
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

-- The journal is not always ready at load; rebuild once the world is in.
local refreshFrame = CreateFrame("Frame")
refreshFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
refreshFrame:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	ForeverContentService.Refresh()
end)
