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
--[[
	Every boss this character has ever beaten, which is a different question from
	which are dead right now.

	`defeated` is lockout state: an instance reset clears it, because the bosses are
	alive again. Discovery asks whether a boss has ever been met, and that cannot be
	undone by walking out and resetting the dungeon -- sharing one set meant a reset
	put `???` back over bosses the player had already seen.
]]
local seen = { }
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
	SavedVariables.Progress[charKey].seen = seen
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
	local record = SavedVariables.Progress and SavedVariables.Progress[charKey]
	if type(record) == "table" then
		if type(record.defeated) == "table" then
			defeated = record.defeated
		end
		if type(record.seen) == "table" then
			seen = record.seen
		--[[
			Upgrading a character saved before the split: everything already beaten
			has self-evidently been met, so seed `seen` from it rather than hiding
			bosses the player has killed.
		]]
		elseif type(record.defeated) == "table" then
			for key in pairs(record.defeated) do seen[key] = true end
		end
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
	seen[key] = true
	Store()
	return true
end

-- Whether this character has ever beaten the boss, whatever has happened since.
function ProgressService.HasSeen(instanceName, encounter)
	Load()
	local key = EncounterKey(instanceName, encounter)
	return key ~= nil and seen[key] == true
end

--[[
	Clear by key rather than by walking the instance, so what is stored can always
	be removed.

	Rebuilding the keys from InstanceService.GetInstanceByName could only clear what
	that lookup could still see: it returns the first match and nil for an instance
	the active client or season filters out, and then nothing was cleared at all.
	Hydrate, meanwhile, walks GetAllInstances, so it could restore a defeat that this
	could not remove -- the boss came back on the next login however often it was
	reset.

	Removing a key during traversal is fine in Lua; adding one is not.
]]
function ProgressService.ClearInstance(instanceName)
	Load()
	if not instanceName then return false end
	local prefix = instanceName .. "|"
	local cleared = false
	for key in pairs(defeated) do
		if key:sub(1, #prefix) == prefix then
			defeated[key] = nil
			cleared = true
		end
	end
	-- `seen` is deliberately untouched: the bosses are alive again, but they have
	-- still been met, and discovery must not be undone by a reset.
	Store()
	return cleared
end

--[[
	The whole record, discovery included. This is the explicit "forget everything"
	that AGC_ResetAllEncounters offers, not something a dungeon reset reaches.
]]
function ProgressService.ClearAll()
	defeated = { }
	seen = { }
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

--[[
	Every defeat stored for this character, which is the only way to tell a boss that
	is still stored apart from one that is merely still drawn. A reset that looks like
	it did nothing is one or the other, and they have different causes.
]]
_G.AGC_ProgressDump = function()
	Load()
	local keys = { }
	for key in pairs(defeated) do table.insert(keys, key) end
	table.sort(keys)
	local seenCount = 0
	for _ in pairs(seen) do seenCount = seenCount + 1 end
	print(("|cff00ff00[AGC]|r %d defeated, %d ever seen, for %s, hydrated: %s")
		:format(#keys, seenCount, tostring(GetCharacterKey()), tostring(hydrated)))
	for _, key in ipairs(keys) do
		print("   " .. key .. (seen[key] and "" or "   (not in seen)"))
	end
end

function ProgressService.IsHydrated()
	return hydrated
end

local loginFrame = CreateFrame("Frame")
loginFrame:SetScript("OnEvent", function()
	ProgressService.Hydrate()
end)
Compat.RegisterEvents(loginFrame, "PLAYER_LOGIN")
