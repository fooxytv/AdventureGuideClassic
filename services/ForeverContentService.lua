--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

ForeverContentService = { }

-- Blizzard_EncounterJournal does not load on Forever -- gated to "standard" and "classic",
-- and Forever's game type is "camelot" -- but the EJ_ functions are engine-side and answer.
-- EJ_GetNumTiers() returns 0 here. Our instanceID is already the journal's instance id.

-- A client that never returns nil would otherwise spin here.
local MAX_INSTANCES = 250

-- Overlap required before the enumeration is trusted; a wrong id set would hide the guide.
local MIN_TRUSTED_MATCHES = 5

-- Vanilla raids Forever does not have, for when the journal does not answer. Onyxia's
-- Lair (249) is absent on purpose: it is the one that carries over.
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

-- Do not try to wake the journal first. C_EncounterJournal.OnOpen() and
-- InitalizeSelectedTier() are protected: they raise ADDON_ACTION_FORBIDDEN, and pcall does
-- not help because the call is refused rather than erroring.
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

function ForeverContentService.GetJournalInstanceIDs()
	Resolve()
	if not trusted then return nil end
	return journalInstanceIDs
end

function ForeverContentService.IsJournalUsable()
	Resolve()
	return trusted == true
end

function ForeverContentService.HasInstance(instance)
	if not instance or not instance.instanceID then return true end

	local ids = ForeverContentService.GetJournalInstanceIDs()
	if ids then
		return ids[instance.instanceID] == true
	end

	return not ABSENT_ON_FOREVER[instance.instanceID]
end

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

if Compat.isForever then
	local refreshFrame = CreateFrame("Frame")
	refreshFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	refreshFrame:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		ForeverContentService.Refresh()
	end)
end
