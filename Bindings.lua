--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
_G["BINDING_NAME_TOGGLE_ADVENTUREGUIDECLASSIC"] = "Toggle Main Window"

local frame = CreateFrame("FRAME")

local updateCount = 0

frame:SetScript("OnUpdate", function()
    if (not InCombatLockdown()) then
        updateCount = updateCount + 1
        if (updateCount == 2) then
            local bindingKey = GetBindingKey("TOGGLE_ADVENTUREGUIDECLASSIC")
            if (not bindingKey) then
                local getBindingByKey = (C_KeyBindings and C_KeyBindings.GetBindingByKey) or GetBindingByKey
                local command = getBindingByKey("SHIFT-J")
                if (not command or command == "") then
                    SetBinding("SHIFT-J", "TOGGLE_ADVENTUREGUIDECLASSIC")
                end
            end
            frame:Hide()
            frame:SetScript("OnUpdate", nop)
            frame = nil
        end
    end
end)
