--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
Single source of truth for "what is this character's situation right now?".

Consumers (SuggestedContentService, ZoneService, GuideService) should read from here
rather than calling UnitLevel/UnitFactionGroup/C_Map directly, so that level and zone
changes propagate from one place.
]]

PlayerContextService = { }

local listeners = { }
local context = { }
local frame

-- Era caps at 60, BCC at 70. GetMaxPlayerLevel is not reliably present on every
-- client we ship for, so feature-detect it and fall back to the interface version.
local function ComputeMaxLevel()
	if (type(GetMaxPlayerLevel) == "function") then
		local ok, maxLevel = pcall(GetMaxPlayerLevel)
		if (ok and type(maxLevel) == "number" and maxLevel > 0) then
			return maxLevel
		end
	end
	local tocversion = select(4, GetBuildInfo())
	if (tocversion >= 30000) then
		return 80
	elseif (tocversion >= 20000) then
		return 70
	end
	return 60
end

local function ComputeZone()
	if (C_Map and C_Map.GetBestMapForUnit) then
		return C_Map.GetBestMapForUnit("player")
	end
	return nil
end

local function NotifyListeners(changed)
	for _, listener in ipairs(listeners) do
		local ok, err = pcall(listener, context, changed)
		if (not ok and AdventureGuideClassic_Debug) then
			print("|cffff0000AGC|r PlayerContextService listener error: " .. tostring(err))
		end
	end
end

-- Rebuilds the cached context and fires listeners only for values that actually moved,
-- so a burst of ZONE_CHANGED events doesn't cause repeated work downstream.
local function Refresh(force, levelOverride)
	local changed = { }
	local any = false

	local function set(key, value)
		if (context[key] ~= value) then
			context[key] = value
			changed[key] = true
			any = true
		end
	end

	-- PLAYER_LEVEL_UP fires before UnitLevel updates, so the event payload wins.
	set("level", levelOverride or UnitLevel("player") or 1)
	set("maxLevel", ComputeMaxLevel())
	set("class", select(2, UnitClass("player")))
	set("className", UnitClass("player"))
	set("faction", UnitFactionGroup("player"))
	set("race", select(2, UnitRace("player")))
	set("zone", ComputeZone())
	set("zoneName", GetZoneText())
	set("inInstance", (IsInInstance()))

	if (any or force) then
		NotifyListeners(changed)
	end
end

function PlayerContextService.GetContext()
	return context
end

function PlayerContextService.GetLevel()
	return context.level or UnitLevel("player") or 1
end

function PlayerContextService.GetMaxLevel()
	return context.maxLevel or ComputeMaxLevel()
end

function PlayerContextService.IsMaxLevel()
	return PlayerContextService.GetLevel() >= PlayerContextService.GetMaxLevel()
end

function PlayerContextService.GetClass()
	return context.class or select(2, UnitClass("player"))
end

function PlayerContextService.GetClassName()
	return context.className or UnitClass("player")
end

function PlayerContextService.GetFaction()
	return context.faction or UnitFactionGroup("player")
end

function PlayerContextService.GetRace()
	return context.race or select(2, UnitRace("player"))
end

function PlayerContextService.GetZone()
	if (context.zone) then return context.zone end
	return ComputeZone()
end

function PlayerContextService.GetZoneName()
	return context.zoneName or GetZoneText()
end

function PlayerContextService.IsInInstance()
	return context.inInstance or false
end

function PlayerContextService.IsBurningCrusade()
	return select(4, GetBuildInfo()) >= 20000
end

--[[
Registers a callback fired whenever the player context changes.

	callback(context, changed)

`changed` is a set of the keys that moved, e.g. { level = true }, so listeners can
skip work they don't need to redo. Fires immediately on registration if the context
has already been populated.
]]
function PlayerContextService.RegisterListener(callback)
	table.insert(listeners, callback)
	if (context.level) then
		pcall(callback, context, { })
	end
end

function PlayerContextService.Refresh()
	Refresh(true)
end

frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function(_, event, ...)
	local levelOverride
	if (event == "PLAYER_LEVEL_UP") then
		local newLevel = ...
		if (type(newLevel) == "number") then
			levelOverride = newLevel
		end
	end
	Refresh(false, levelOverride)
end)

Refresh(true)

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_DumpPlayerContext = function()
	print("|cff33ff99[AGC]|r player context:")
	for _, key in ipairs({ "level", "maxLevel", "class", "faction", "race",
	                       "zone", "zoneName", "inInstance" }) do
		print(("  %s = %s"):format(key, tostring(context[key])))
	end
	print(("  isMaxLevel = %s"):format(tostring(PlayerContextService.IsMaxLevel())))
end

-- Preview which instances a character would be offered at an arbitrary level,
-- without having to level one there.
_G.AGC_InstancesForLevel = function(level, faction)
	level = level or PlayerContextService.GetLevel()
	faction = faction or PlayerContextService.GetFaction()
	print(("|cff33ff99[AGC]|r instances in range at level %d (%s):"):format(level, tostring(faction)))
	for _, entry in ipairs({
		{ label = "Dungeons", list = InstanceService.GetAllDungeons() },
		{ label = "Raids", list = InstanceService.GetAllRaids() },
	}) do
		local matches = InstanceService.GetInstancesForLevelRange(entry.list, level, level, faction)
		print(("  %s (%d):"):format(entry.label, #matches))
		for _, instance in ipairs(matches) do
			print(("    %s (%d-%d, rec %s)"):format(
				instance.name,
				instance.levelRange.min,
				instance.levelRange.max,
				tostring(instance.recommendedLevel)))
		end
	end
end
