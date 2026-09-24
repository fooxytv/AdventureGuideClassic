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
	Walks the journal the way ForeverContentService does, but reports the shape of the
	answer rather than just the id set.
]]
local function ProbeJournal()
	if type(EJ_GetInstanceByIndex) ~= "function" then
		Line("EJ_GetInstanceByIndex", "absent")
		return
	end

	local numTiers = "n/a"
	if type(EJ_GetNumTiers) == "function" then
		local ok, tiers = pcall(EJ_GetNumTiers)
		numTiers = ok and tostring(tiers) or ("error: " .. tostring(tiers))
	end
	Line("EJ_GetNumTiers()", numTiers)

	for _, kind in ipairs({ { false, "dungeons" }, { true, "raids" } }) do
		local isRaid, label = kind[1], kind[2]
		local names, count = { }, 0
		for index = 1, 250 do
			local ok, instanceID, name = pcall(EJ_GetInstanceByIndex, index, isRaid)
			if not ok or not instanceID then break end
			count = count + 1
			if count <= 40 then
				table.insert(names, tostring(instanceID) .. ":" .. tostring(name))
			end
		end
		Line("journal " .. label, count)
		if count > 0 then
			print("    " .. table.concat(names, ", "))
		end
	end

	Line("C_EncounterJournal", C_EncounterJournal and "present" or "absent")
	if C_EncounterJournal and C_EncounterJournal.InstanceHasLoot then
		local firstID = EJ_GetInstanceByIndex(1, false)
		if firstID then
			local ok, hasLoot = pcall(C_EncounterJournal.InstanceHasLoot, firstID)
			Line("InstanceHasLoot(" .. tostring(firstID) .. ")",
				ok and tostring(hasLoot) or ("error: " .. tostring(hasLoot)))
		end
	end
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
