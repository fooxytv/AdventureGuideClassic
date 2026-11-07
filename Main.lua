--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
Licensed under the GNU General Public License v3.0. See LICENSE.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local frame = CreateFrame("Frame")

local function OnEvent(_, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == addonName) then
        _G[SavedVariablesName] = _G[SavedVariablesName] or { }
        SavedVariables = _G[SavedVariablesName]
        MinimapButton.Init()
        frame:UnregisterEvent("ADDON_LOADED")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnEvent)
