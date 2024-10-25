--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local LockoutService = {}

local function HandleEncounterEnd(encounterID, encounterName, difficultyID, groupSize, success)
    local prefix = "|cffff0000[ Adventure Guide Classic ]|r "
    local messageColor = "|cffffff00"
    -- print("ENCOUNTER_END detected for: " .. encounterName .. ", Success: " .. tostring(success))
    local instanceName = GetInstanceInfo()
    if success == 1 then
        if LockoutService.MarkEncounterDefeated(instanceName, encounterName) then
            PlaySound(6199) -- "Work Complete" sound
            print(prefix .. messageColor .. encounterName .. " has been defeated.|r")
            -- print(prefix .. messageColor .. "Failed to mark encounter as defeated: " .. encounterName .. "|r")
        end
    else
        print(prefix .. messageColor .. "Encounter not completed successfully: " .. encounterName .. "|r")
    end
end

function LockoutService.MarkEncounterDefeated(dungeonName, encounterName)
    local dungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(dungeons) do
        if dungeon.name == dungeonName then
            for _, encounter in ipairs(dungeon) do
                if encounter.name == encounterName then
                    encounter.defeated = 1
                    -- print("Marked encounter '" .. encounterName .. "' as defeated in dungeon '" .. dungeonName .. "'")
                    _G.AdventureGuideClassic_UI_Encounters_Refresh = true
                    return true
                end
            end
        end
    end

    print("Encounter not found: " .. encounterName)
    return false
end

local function HandleInstanceReset()
    local dungeons = InstanceService.GetDungeons()

    -- Loop through the dungeons to find and reset all encounters
    for _, dungeon in ipairs(dungeons) do
        for _, encounter in ipairs(dungeon) do
            if encounter.name then
                encounter.defeated = 0
                -- print("Reset encounter '" .. encounter.name .. "' in dungeon '" .. dungeon.name .. "' to default (defeated = 0)")
                _G.AdventureGuideClassic_UI_Encounters_Refresh = true
            end
        end
    end
end

local function HandleCombatLogEvent(...)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool = CombatLogGetCurrentEventInfo()
    if eventType == "UNIT_DIED" then
        local instanceName = GetInstanceInfo()
        print(destName .. " has been defeated (Combat log detection).")
        LockoutService.MarkEncounterDefeated(instanceName, destName)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_SYSTEM" then
        local message = ...
        if message:find("has been reset.") then
            HandleInstanceReset()
        end
    elseif event == "ENCOUNTER_END" then
        HandleEncounterEnd(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandleCombatLogEvent(...)
    end
end)

return LockoutService
