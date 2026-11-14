--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

LeatrixMapsService = {}

--[[
	Forever ships no dungeon maps, and Leatrix Maps draws them. It has no public
	API, so this asks through its slash command: "/ltm dun <word>" previews the
	first dungeon whose name contains the word, and falls through to the next
	dungeon in its list when none does. So every word here has to be one that
	matches, which is why the list is spelled out rather than derived.
]]
local ADDON = "Leatrix_Maps"

-- Its English dungeon names, which it matches against in every locale.
local SEARCH_WORDS = {
	["City of Dalaran"] = "dalaran",
	["Excavation Site: Wetlands"] = "wetlands",
	["Ruins of Lordaeron"] = "lordaeron",
	["The Hall of Thanes"] = "thanes",
	["The Drowned City"] = "drowned",
	["Krol'Dok Stronghold"] = "krol'dok",
	["Alcaz Prison"] = "alcaz",
	["Shaper's Terrace"] = "shaper",
}

-- The version dungeon maps arrived in; before it "dun" is an invalid command.
local MIN_VERSION = { 1, 60, 27 }

local MESSAGES = {
	missing = "Install Leatrix Maps to see this dungeon's map.",
	outdated = "Update Leatrix Maps to see this dungeon's map.",
	disabled = "Turn on \"Show dungeon maps\" in Leatrix Maps to see this dungeon's map.",
	nomap = "There is no map for this dungeon yet.",
}

local function IsLoaded()
	return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(ADDON)
		and type(SlashCmdList[ADDON]) == "function"
end

-- An unreadable version is let through: better a try than a refusal on a guess.
local function IsOutdated()
	local version = C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version")
	local parts = { string.match(tostring(version), "^(%d+)%.(%d+)%.(%d+)") }
	for i, minimum in ipairs(MIN_VERSION) do
		local part = tonumber(parts[i])
		if not part then return false end
		if part ~= minimum then return part < minimum end
	end
	return false
end

-- "ok" and the search word, or why not: unsupported, nomap, missing, outdated, disabled.
function LeatrixMapsService.GetStatus(instanceName)
	if not Compat.isForever then return "unsupported" end
	local word = SEARCH_WORDS[instanceName]
	if not word then return "nomap" end
	if not IsLoaded() then return "missing" end
	if IsOutdated() then return "outdated" end
	-- Unset until its first logout, and on by default, so only "Off" means off.
	if type(LeaMapsDB) == "table" and LeaMapsDB["ShowDungeonMaps"] == "Off" then
		return "disabled"
	end
	return "ok", word
end

function LeatrixMapsService.GetMessage(status)
	return MESSAGES[status] or MESSAGES.nomap
end

-- Its preview needs the world map open first, and says so rather than opening it.
local function ShowWorldMap()
	local frame = WorldMapFrame
	if not frame then return false end
	if not frame:IsShown() then
		if type(ShowUIPanel) == "function" then
			ShowUIPanel(frame)
		else
			frame:Show()
		end
	end
	return frame:IsShown() and true or false
end

-- True when the map was asked for, else false and the status that stopped it.
function LeatrixMapsService.Open(instanceName)
	local status, word = LeatrixMapsService.GetStatus(instanceName)
	if status ~= "ok" then return false, status end
	if not ShowWorldMap() then return false, "nomap" end
	SlashCmdList[ADDON]("dun " .. word)
	return true
end
