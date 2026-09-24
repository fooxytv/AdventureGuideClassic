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

--[[
	The Classic progression line: Era, Season of Discovery, TBC, Wrath, Cata.

	Forever is excluded on purpose. Its interface version would pass for vanilla, but
	it is a separate content line with its own instance list, and treating it as Era
	offers the player raids that do not exist there.
]]
Compat.isClassicLine = not isMainlineProject

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
local RESTRICTED_EVENTS = { }
if Compat.isForever then
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
