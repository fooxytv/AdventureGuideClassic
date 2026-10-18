--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

ProgressService = { }

--[[
	Which bosses this character has beaten, kept across sessions.

	EncounterObjectives writes defeated = 1 onto the instance table, which is rebuilt
	from the data files on every login, so without this the defeat ticks reset on
	every reload and were shared by every character in a session.

	In-memory is the source of truth and is mirrored into SavedVariables, because
	services load before Main.lua binds it.
]]
local defeated = { }
local loaded = false
local hydrated = false

--[[
	Per character, like WishlistService: progress belongs to a character's adventure,
	not the account. Note that UnitName("player") is nil at ADDON_LOADED, so this is
	only safe to call from PLAYER_LOGIN onwards.
]]
local function GetCharacterKey()
	local name = UnitName("player")
	local realm = GetRealmName()
	if not name or not realm then return nil end
	return name .. "-" .. realm
end

--[[
	Instance and encounter name, which is what MarkEncounterDefeatedInInstanceData
	already matches an encounter on, so progress agrees with detection by
	construction.

	Deliberately not encounterID, tempting as it is for surviving a rename: the ids
	are not unique. Blackrock Spire gives both Pyroguard Emberseer and Solakar
	Flamewreath 9816, and the three instances that exist as both a dungeon and an SoD
	raid reuse their ids across the pair. Keying on an id would mark the wrong boss
	beaten. The name pair is the only scheme that is collision-free on every client.

	The same three pairs do share a name key, so Hydrate marks the hidden twin too.
	No filter shows both at once, so it never surfaces -- and they are the same boss
	in the same place in any case.
]]
local function EncounterKey(instanceName, encounter)
	if not (instanceName and encounter.name) then return nil end
	return instanceName .. "|" .. encounter.name
end

local function Store()
	if not SavedVariables then return end
	local charKey = GetCharacterKey()
	if not charKey then return end
	SavedVariables.Progress = SavedVariables.Progress or { }
	SavedVariables.Progress[charKey] = SavedVariables.Progress[charKey] or { }
	SavedVariables.Progress[charKey].defeated = defeated
end

--[[
	Read once, then stay authoritative in memory. The guard matters because Store
	writes the in-memory table over whatever is saved: a write that happened before
	the first read would replace this character's whole history with the single kill
	that triggered it. Returns false while SavedVariables or the character name are
	still unavailable, so the next caller retries.
]]
local function Load()
	if loaded then return true end
	if not SavedVariables then return false end
	local charKey = GetCharacterKey()
	if not charKey then return false end
	local stored = SavedVariables.Progress
		and SavedVariables.Progress[charKey]
		and SavedVariables.Progress[charKey].defeated
	if type(stored) == "table" then
		defeated = stored
	end
	loaded = true
	Store()
	return true
end

function ProgressService.IsDefeated(instanceName, encounter)
	Load()
	local key = EncounterKey(instanceName, encounter)
	return key ~= nil and defeated[key] == true
end

function ProgressService.MarkDefeated(instanceName, encounter)
	Load()
	local key = EncounterKey(instanceName, encounter)
	if not key then return false end
	defeated[key] = true
	Store()
	return true
end

function ProgressService.ClearInstance(instanceName)
	Load()
	local instance = InstanceService.GetInstanceByName(instanceName)
	if not instance then return false end
	for _, encounter in ipairs(instance) do
		local key = EncounterKey(instanceName, encounter)
		if key then defeated[key] = nil end
	end
	Store()
	return true
end

function ProgressService.ClearAll()
	defeated = { }
	loaded = true
	Store()
end

--[[
	Apply what is stored onto the instance tables, which is what the encounter list
	reads. Called once the character is known; the data tables are rebuilt on every
	login, so there is nothing stale to clear first.
]]
function ProgressService.Hydrate()
	if not Load() then return false end
	local count = 0
	for _, instance in ipairs(InstanceService.GetAllInstances()) do
		for _, encounter in ipairs(instance) do
			if ProgressService.IsDefeated(instance.name, encounter) then
				encounter.defeated = 1
				count = count + 1
			end
		end
	end
	hydrated = true
	_G.AdventureGuideClassic_UI_Encounters_Refresh = true
	return true, count
end

function ProgressService.IsHydrated()
	return hydrated
end

local loginFrame = CreateFrame("Frame")
loginFrame:SetScript("OnEvent", function()
	ProgressService.Hydrate()
end)
Compat.RegisterEvents(loginFrame, "PLAYER_LOGIN")
