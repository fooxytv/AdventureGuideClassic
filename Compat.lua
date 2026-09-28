--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

-- Forever reports WOW_PROJECT_MAINLINE with interface 16001, so only the pair identifies
-- it. Nothing else in the addon should read GetBuildInfo or WOW_PROJECT_ID.

Compat = { }

local tocVersion = select(4, GetBuildInfo())

local isMainlineProject = WOW_PROJECT_ID ~= nil
	and WOW_PROJECT_MAINLINE ~= nil
	and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- Retail's interface versions run to six digits (110000 and up). Forever's are five.
local RETAIL_MIN_TOC = 100000

local flavor
if isMainlineProject then
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

Compat.tocVersion = tocVersion
Compat.flavor = flavor

Compat.isForever = (flavor == "forever")
Compat.isRetail = (flavor == "retail")
Compat.isTBC = (flavor == "tbc")

-- Forever excluded on purpose: vanilla-shaped interface version, separate content line.
Compat.isClassicLine = not isMainlineProject

Compat.isEraClient = Compat.isClassicLine and tocVersion < 20000

-- C_Seasons is absent on Forever, where reaching it unguarded is a hard error.
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

-- Where Forever shares an instance with Era it shares the item ids.
Compat.isVanillaLoot = Compat.isEraClient or Compat.isForever

-- The GetSpellInfo global is gone on mainline clients, and C_Spell.GetSpellInfo returns a
-- table rather than a list, so this is a real shim and not an alias.
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

-- CharacterFrameTabButtonTemplate is absent on Forever. PanelTabButtonTemplate carries no
-- *Disabled textures and names its pieces by parentKey, not globally.
Compat.TabButtonTemplate = Compat.isForever
	and "PanelTabButtonTemplate"
	or "CharacterFrameTabButtonTemplate"

-- COMBAT_LOG_EVENT_UNFILTERED is restricted on Forever: registering it raises
-- ADDON_ACTION_FORBIDDEN and stops that frame's remaining registrations.
local RESTRICTED_EVENTS = { }
if Compat.isForever then
	RESTRICTED_EVENTS.COMBAT_LOG_EVENT_UNFILTERED = true
end

function Compat.IsEventAvailable(event)
	return not RESTRICTED_EVENTS[event]
end

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
