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

local function Load()
	if not SavedVariables then return end
	local charKey = GetCharacterKey()
	if not charKey then return end
	local stored = SavedVariables.Progress
		and SavedVariables.Progress[charKey]
		and SavedVariables.Progress[charKey].defeated
	if type(stored) == "table" then
		defeated = stored
	end
	Store()
end

function ProgressService.IsDefeated(instanceName, encounter)
	local key = EncounterKey(instanceName, encounter)
	return key ~= nil and defeated[key] == true
end

function ProgressService.MarkDefeated(instanceName, encounter)
	local key = EncounterKey(instanceName, encounter)
	if not key then return false end
	defeated[key] = true
	Store()
	return true
end

function ProgressService.ClearInstance(instanceName)
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
	Store()
end

--[[
	Apply what is stored onto the instance tables, which is what the encounter list
	reads. Called once the character is known; the data tables are rebuilt on every
	login, so there is nothing stale to clear first.
]]
function ProgressService.Hydrate()
	if not GetCharacterKey() then return false end
	Load()
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
