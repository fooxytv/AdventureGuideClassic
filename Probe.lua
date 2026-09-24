--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
	Client diagnostic, /agcprobe.

	Written for the Forever port: a handful of things about that client cannot be
	settled from outside the game -- which .toc it loads, whether the Encounter
	Journal functions answer, and which instances it actually has. This prints all of
	it in one go so a single login settles them.
]]

local function Line(label, value)
	print("  |cffffd100" .. label .. ":|r", tostring(value))
end

local function Header(text)
	print("|cffff9900[AGC]|r |cffffffff" .. text .. "|r")
end

local function DescribeToc()
	if not (C_AddOns and C_AddOns.GetAddOnMetadata) then return "unknown" end
	return C_AddOns.GetAddOnMetadata(addonName, "X-TocFlavor") or "untagged"
end

--[[
	Reads the journal, then wakes it up and reads it again.

	Blizzard's UI calls C_EncounterJournal.OnOpen() when the frame is shown. That UI
	does not load on Forever, so on a first read the journal is cold and reports
	nothing. This shows both states so it is clear which one we are looking at, and
	rechecks a few seconds later because the data may come from the server.
]]
local function CountInstances()
	local dungeons, raids, sample = 0, 0, { }
	for _, kind in ipairs({ { false, "dungeon" }, { true, "raid" } }) do
		local isRaid = kind[1]
		for index = 1, 250 do
			local ok, instanceID, name = pcall(EJ_GetInstanceByIndex, index, isRaid)
			if not ok or not instanceID then break end
			if isRaid then raids = raids + 1 else dungeons = dungeons + 1 end
			if #sample < 40 then
				table.insert(sample, tostring(instanceID) .. ":" .. tostring(name))
			end
		end
	end
	return dungeons, raids, sample
end

local function ReportJournal(label)
	local numTiers = "n/a"
	if type(EJ_GetNumTiers) == "function" then
		local ok, tiers = pcall(EJ_GetNumTiers)
		numTiers = ok and tostring(tiers) or ("error: " .. tostring(tiers))
	end
	local dungeons, raids, sample = CountInstances()
	Line(label .. "EJ_GetNumTiers()", numTiers)
	Line(label .. "dungeons / raids", dungeons .. " / " .. raids)
	if #sample > 0 then
		print("    " .. table.concat(sample, ", "))
	end
	return dungeons + raids
end

local function ProbeJournal()
	Line("C_EncounterJournal", C_EncounterJournal and "present" or "absent")
	if type(EJ_GetInstanceByIndex) ~= "function" then
		Line("EJ_GetInstanceByIndex", "absent")
		return
	end

	ReportJournal("")

	if C_EncounterJournal and C_EncounterJournal.InstanceHasLoot then
		local firstID = EJ_GetInstanceByIndex(1, false)
		if firstID then
			local ok, hasLoot = pcall(C_EncounterJournal.InstanceHasLoot, firstID)
			Line("InstanceHasLoot(" .. tostring(firstID) .. ")",
				ok and tostring(hasLoot) or ("error: " .. tostring(hasLoot)))
		end
	end

	-- Journal data can arrive from the server, so look again shortly.
	C_Timer.After(3, function()
		Header("Encounter Journal API, 3s later")
		local later = ReportJournal("delayed: ")
		if later > 0 then
			print("  |cff00ff00The journal has data; content gating can use it.|r")
		else
			print("  |cffff5555The journal is empty on this client; the fallback list is carrying it.|r")
		end
	end)
end

local function Probe()
	Header("Client")
	Line("flavor", Compat.flavor)
	Line("interface version", Compat.tocVersion)
	Line("loaded .toc", DescribeToc())
	Line("WOW_PROJECT_ID", WOW_PROJECT_ID)
	Line("WOW_PROJECT_MAINLINE", WOW_PROJECT_MAINLINE)
	Line("WOW_PROJECT_CLASSIC", WOW_PROJECT_CLASSIC)
	Line("build", (GetBuildInfo()))
	Line("tab template", Compat.TabButtonTemplate)

	Header("Compat")
	Line("isForever", Compat.isForever)
	Line("isTBC", Compat.isTBC)
	Line("isClassicLine", Compat.isClassicLine)
	Line("isEraClient", Compat.isEraClient)
	Line("isVanillaLoot", Compat.isVanillaLoot)
	Line("C_Seasons", C_Seasons and "present" or "absent")
	Line("active season", Compat.GetActiveSeason())
	Line("IsSoD()", Compat.IsSoD())
	Line("IsEra()", Compat.IsEra())

	Header("Encounter Journal API")
	ProbeJournal()

	Header("Events")
	local events = {
		"ENCOUNTER_END", "BOSS_KILL", "COMBAT_LOG_EVENT_UNFILTERED",
		"UPDATE_MOUSEOVER_UNIT", "CHAT_MSG_SYSTEM", "PLAYER_LEVEL_UP",
		"LOOT_OPENED", "PLAYER_EQUIPMENT_CHANGED",
	}
	local restricted = { }
	for _, event in ipairs(events) do
		if not Compat.IsEventAvailable(event) then table.insert(restricted, event) end
	end
	Line("restricted on this client", #restricted > 0 and table.concat(restricted, ", ") or "none")

	Header("Content")
	Line("expansion filter", InstanceService.GetExpansionFilter())
	Line("registered instances", #InstanceService.GetAllInstances())
	Line("dungeons shown", #InstanceService.GetDungeons())
	Line("raids shown", #InstanceService.GetRaids())

	if Compat.isForever then
		Line("journal trusted", ForeverContentService.IsJournalUsable())
		local unknown = ForeverContentService.GetUnknownInstanceIDs()
		Line("journal instances we have no data for", #unknown)
		if #unknown > 0 then
			print("    " .. table.concat(unknown, ", "))
		end
	end
end

_G.AGC_Probe = Probe

_G.SLASH_AGCPROBE1 = "/agcprobe"
SlashCmdList["AGCPROBE"] = Probe

-- Kept for muscle memory; /agctest was the original name.
_G.SLASH_AGCTEST1 = "/agctest"
SlashCmdList["AGCTEST"] = Probe
