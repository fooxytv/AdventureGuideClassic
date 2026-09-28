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
		local tuner = UI.GetComponent and UI.GetComponent("ModelTuner")
		if tuner and tuner.Toggle then
			tuner.Toggle()
		else
			print("|cffff5555[AGC]|r ModelTuner is not available on this client.")
		end
	else
		--todo: print usage instructions to the console
	end
end
