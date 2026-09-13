--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

-- lib/TomCats/GlobalFacade.lua leaves the per-character name unset; define it here
-- rather than editing the shared library.
SavedVariablesPerCharacterName = ("%s_Character"):format(addonName)

local frame = CreateFrame("Frame")

local function OnEvent(_, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == addonName) then
        _G[SavedVariablesName] = _G[SavedVariablesName] or { }
        SavedVariables = _G[SavedVariablesName]
        -- Per-character store, for anything that must not be shared between alts
        -- (currently levelling guide progress).
        _G[SavedVariablesPerCharacterName] = _G[SavedVariablesPerCharacterName] or { }
        SavedVariablesPerCharacter = _G[SavedVariablesPerCharacterName]
        MinimapButton.Init()
        frame:UnregisterEvent("ADDON_LOADED")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnEvent)
