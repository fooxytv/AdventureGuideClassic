--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

DiscoveryService = { }

--[[
	Hides a boss until this character has beaten it, so the journal fills in as you
	play rather than spoiling the place before you walk in.

	Per character, like the progress it reads: switching it on is a choice about one
	character's adventure, and a character who has already cleared everything would
	otherwise turn it on and see an empty book.

	Off by default. Everything here is a no-op until someone asks for it.
]]
local enabled = false
local loaded = false

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
	SavedVariables.Discovery = SavedVariables.Discovery or { }
	SavedVariables.Discovery[charKey] = enabled or nil
end

local function Load()
	if loaded then return true end
	if not SavedVariables then return false end
	local charKey = GetCharacterKey()
	if not charKey then return false end
	enabled = (SavedVariables.Discovery and SavedVariables.Discovery[charKey]) == true
	loaded = true
	return true
end

function DiscoveryService.IsEnabled()
	Load()
	return enabled
end

function DiscoveryService.SetEnabled(value)
	Load()
	enabled = value and true or false
	Store()
	_G.AdventureGuideClassic_UI_Encounters_Refresh = true
	return enabled
end

--[[
	Whether a boss may be shown in full. Always true while the mode is off, so every
	caller can ask without first checking whether it is on.
]]
function DiscoveryService.IsDiscovered(instanceName, encounter)
	if not DiscoveryService.IsEnabled() then return true end
	if not (instanceName and encounter) then return true end
	-- Ever met, not currently dead. Resetting a dungeon makes its bosses alive
	-- again; it does not make the player forget them.
	return ProgressService.HasSeen(instanceName, encounter)
end

--[[
	How much of an instance this character has met, for the "2/4 discovered" note.
	Returns the total twice while the mode is off, so the caller can show nothing.
]]
function DiscoveryService.GetProgress(instance)
	if not instance then return 0, 0 end
	local total = #instance
	if not DiscoveryService.IsEnabled() then return total, total end
	local found = 0
	for _, encounter in ipairs(instance) do
		if ProgressService.HasSeen(instance.name, encounter) then
			found = found + 1
		end
	end
	return found, total
end

-- The name to show for a boss that has not been met.
DiscoveryService.UNKNOWN_NAME = "???"
