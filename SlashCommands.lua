--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

_G.SLASH_ADVENTUREGUIDECLASSIC1 = "/agc"
SlashCmdList["ADVENTUREGUIDECLASSIC"] = function(message)
	message = string.lower(message or "")
	if (message == "") then
		UI.ToggleEncounterJournal()
	elseif (message == "button") then
		MinimapButton.Toggle()
	elseif (message == "modeltune") then
		-- Developer aid for dialling in the model viewer camera; see ui/ModelTuner.lua.
		local tuner = UI.GetComponent and UI.GetComponent("ModelTuner")
		if tuner and tuner.Toggle then
			tuner.Toggle()
		else
			print("|cffff5555[AGC]|r ModelTuner is not available on this client.")
		end
	elseif (message == "clienttune") then
		-- Developer aid for testing another client's content; see ui/ClientTuner.lua.
		local tuner = UI.GetComponent and UI.GetComponent("ClientTuner")
		if tuner and tuner.Toggle then
			tuner.Toggle()
		else
			print("|cffff5555[AGC]|r ClientTuner is not available on this client.")
		end
	elseif (message == "portraits") then
		-- Developer rig for photographing models; see ui/PortraitStudio.lua.
		local studio = UI.GetComponent and UI.GetComponent("PortraitStudio")
		if studio and studio.Toggle then
			studio.Toggle()
		else
			print("|cffff5555[AGC]|r PortraitStudio is not available on this client.")
		end
	elseif (message:match("^icontest")) then
		-- Developer aid for how a texture behaves under a mask; see ui/IconProbe.lua.
		local probe = UI.GetComponent and UI.GetComponent("IconProbe")
		if probe and probe.Toggle then
			probe.Toggle(message:match("^icontest%s+(%d+)"))
		else
			print("|cffff5555[AGC]|r IconProbe is not available on this client.")
		end
	else
		--todo: print usage instructions to the console
	end
end
