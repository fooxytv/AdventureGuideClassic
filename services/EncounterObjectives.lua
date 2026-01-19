select(2, ...).SetupGlobalFacade()

local EncounterObjective = {}
AdventureObjectives = AdventureObjectives or {}

-- Debug output toggle (orange messages)
-- Enable with: /run AGC_ToggleDebug() or /run AdventureGuideClassic_DebugEvents = true
AdventureGuideClassic_DebugEvents = AdventureGuideClassic_DebugEvents or false

local function DebugPrint(...)
    if AdventureGuideClassic_DebugEvents then
        print("|cffff9900[AGC]|r", ...)
    end
end

-- Debounce tracking to prevent duplicate triggers
local recentlyDefeated = {}
local DEBOUNCE_TIME = 5 -- seconds

-- Extract NPC ID from GUID
-- GUID format: "Creature-0-XXXX-XXXX-XXXX-NPCID-SPAWNID"
local function GetNpcIdFromGuid(guid)
    if not guid then return nil end
    local npcId = select(6, strsplit("-", guid))
    return npcId and tonumber(npcId)
end

-- Check if this is a creature GUID (not player, pet, etc.)
local function IsCreatureGuid(guid)
    if not guid then return false end
    return guid:match("^Creature%-") ~= nil
end

-- Build a lookup table of NPC IDs for the current dungeon
-- Uses InstanceService (encounterID field contains the NPC ID)
local function BuildNpcLookup(dungeonName)
    local lookup = {}

    -- Check dungeons (encounterID field is the NPC ID)
    local instanceDungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(instanceDungeons) do
        if dungeon.name == dungeonName then
            for i, encounter in ipairs(dungeon) do
                if type(encounter) == "table" and encounter.name then
                    -- encounterID in dungeon data is the NPC ID
                    if encounter.encounterID then
                        lookup[encounter.encounterID] = encounter
                    end
                    -- Name-based lookup as fallback
                    lookup[encounter.name] = encounter
                end
            end
            break
        end
    end

    -- Also check raids
    local instanceRaids = InstanceService.GetRaids()
    for _, raid in ipairs(instanceRaids) do
        if raid.name == dungeonName then
            for i, encounter in ipairs(raid) do
                if type(encounter) == "table" and encounter.name then
                    if encounter.encounterID then
                        lookup[encounter.encounterID] = encounter
                    end
                    lookup[encounter.name] = encounter
                end
            end
            break
        end
    end

    return lookup
end

function EncounterObjective.GetDungeonEncounters(dungeonName)
    local dungeons = InstanceService.GetDungeons()
    local filteredEncounters = {}
    for _, dungeon in ipairs(dungeons) do
        if dungeon.name == dungeonName then
            for _, encounter in ipairs(dungeon) do
                if type(encounter) == "table" and encounter.name then
                    table.insert(filteredEncounters, {
                        name = encounter.name,
                        defeated = encounter.defeated
                    })
                end
            end
            break
        end
    end
    return filteredEncounters
end

function EncounterObjective.CheckEncounterDefeated(bossName)
    if not bossName then return end
    local dungeonName = GetInstanceInfo()

    -- Check dungeons
    local dungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(dungeons) do
        if dungeon.name == dungeonName then
            for i, encounter in ipairs(dungeon) do
                if type(encounter) == "table" and encounter.name == bossName then
                    EncounterObjective.MarkEncounterAsDefeated(dungeonName, bossName)
                    if AdventureObjectives and AdventureObjectives.UpdateVisibility then
                        AdventureObjectives:UpdateVisibility()
                    end
                    return
                end
            end
        end
    end

    -- Check raids
    local raids = InstanceService.GetRaids()
    for _, raid in ipairs(raids) do
        if raid.name == dungeonName then
            for i, encounter in ipairs(raid) do
                if type(encounter) == "table" and encounter.name == bossName then
                    EncounterObjective.MarkEncounterAsDefeated(dungeonName, bossName)
                    if AdventureObjectives and AdventureObjectives.UpdateVisibility then
                        AdventureObjectives:UpdateVisibility()
                    end
                    return
                end
            end
        end
    end
end

function EncounterObjective.MarkEncounterAsDefeated(dungeonName, bossName)
    if not dungeonName or not bossName then
        return
    end

    -- Update in InstanceService dungeons
    local instanceDungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(instanceDungeons) do
        if dungeon.name == dungeonName then
            for i, encounter in ipairs(dungeon) do
                if type(encounter) == "table" and encounter.name == bossName then
                    encounter.defeated = 1
                end
            end
            break
        end
    end

    -- Update in InstanceService raids
    local instanceRaids = InstanceService.GetRaids()
    for _, raid in ipairs(instanceRaids) do
        if raid.name == dungeonName then
            for i, encounter in ipairs(raid) do
                if type(encounter) == "table" and encounter.name == bossName then
                    encounter.defeated = 1
                end
            end
            break
        end
    end

    if AdventureObjectives and AdventureObjectives.LoadEncounters then
        AdventureObjectives:LoadEncounters(dungeonName)
        _G.AdventureGuideClassic_UI_Encounters_Refresh = true
    end
end

-- Trigger the defeat notification with debouncing
local function TriggerDefeatNotification(encounterName)
    DebugPrint("TriggerDefeatNotification called for:", encounterName)

    -- Check debounce
    local now = GetTime()
    if recentlyDefeated[encounterName] and (now - recentlyDefeated[encounterName]) < DEBOUNCE_TIME then
        DebugPrint("Debounced, skipping")
        return false -- Already triggered recently
    end
    recentlyDefeated[encounterName] = now

    PlaySoundFile("Interface\\AddOns\\AdventureGuideClassic\\sounds\\UIEJBossDefeated.ogg", "Dialog")
    EncounterObjective.CheckEncounterDefeated(encounterName)
    if AdventureGuideClassicEventToastManager then
        AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast(encounterName, "Has been defeated!")
    end
    return true
end

-- Helper to find and update encounter in InstanceService data directly
local function MarkEncounterDefeatedInInstanceData(dungeonName, encounterName)
    -- Check dungeons
    local instanceDungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(instanceDungeons) do
        if dungeon.name == dungeonName then
            for i = 1, #dungeon do
                local enc = dungeon[i]
                if type(enc) == "table" and enc.name == encounterName then
                    enc.defeated = 1
                    DebugPrint("Marked defeated in dungeon data:", encounterName)
                    return true
                end
            end
        end
    end

    -- Check raids
    local instanceRaids = InstanceService.GetRaids()
    for _, raid in ipairs(instanceRaids) do
        if raid.name == dungeonName then
            for i = 1, #raid do
                local enc = raid[i]
                if type(enc) == "table" and enc.name == encounterName then
                    enc.defeated = 1
                    DebugPrint("Marked defeated in raid data:", encounterName)
                    return true
                end
            end
        end
    end

    return false
end

-- Handle ENCOUNTER_END (most reliable for supported encounters)
local function OnEncounterEnd(encounterID, encounterName, difficultyID, groupSize, success)
    if not success or success == 0 then
        return -- Only trigger on successful boss kills
    end

    local dungeonName = GetInstanceInfo()

    DebugPrint("ENCOUNTER_END:", encounterName, "ID:", encounterID, "Instance:", dungeonName)

    local npcLookup = BuildNpcLookup(dungeonName)
    local encounter = nil

    -- Try to find by encounterID first, then by name
    if encounterID and npcLookup[encounterID] then
        encounter = npcLookup[encounterID]
    elseif encounterName and npcLookup[encounterName] then
        encounter = npcLookup[encounterName]
    end

    if encounter then
        MarkEncounterDefeatedInInstanceData(dungeonName, encounter.name)
        _G.AdventureGuideClassic_UI_Encounters_Refresh = true
        TriggerDefeatNotification(encounter.name)
    end
end

-- Handle BOSS_KILL event (fires in some Classic content)
local function OnBossKill(encounterID, encounterName)
    local dungeonName = GetInstanceInfo()

    DebugPrint("BOSS_KILL:", encounterName, "ID:", encounterID, "Instance:", dungeonName)

    local npcLookup = BuildNpcLookup(dungeonName)
    local encounter = nil

    if encounterID and npcLookup[encounterID] then
        encounter = npcLookup[encounterID]
    elseif encounterName and npcLookup[encounterName] then
        encounter = npcLookup[encounterName]
    end

    if encounter then
        MarkEncounterDefeatedInInstanceData(dungeonName, encounter.name)
        _G.AdventureGuideClassic_UI_Encounters_Refresh = true
        TriggerDefeatNotification(encounter.name)
    end
end

-- Handle UNIT_DIED from combat log (fallback for older content)
local function OnUnitDied(destGUID, destName)
    -- Only process creature deaths
    if not IsCreatureGuid(destGUID) then
        return
    end

    local dungeonName = GetInstanceInfo()
    if not dungeonName or dungeonName == "" then
        return
    end

    local npcId = GetNpcIdFromGuid(destGUID)

    DebugPrint("UNIT_DIED:", destName, "NPC ID:", npcId or "nil", "Instance:", dungeonName)

    local npcLookup = BuildNpcLookup(dungeonName)
    local encounter = nil

    -- Try NPC ID match first (most reliable)
    if npcId and npcLookup[npcId] then
        encounter = npcLookup[npcId]
        DebugPrint("Found by NPC ID:", encounter.name)
    -- Fall back to name matching
    elseif destName and npcLookup[destName] then
        encounter = npcLookup[destName]
        DebugPrint("Found by name:", encounter.name)
    end

    if encounter then
        -- Update the defeated flag directly in InstanceService data
        MarkEncounterDefeatedInInstanceData(dungeonName, encounter.name)

        -- Trigger the refresh flag for the UI
        _G.AdventureGuideClassic_UI_Encounters_Refresh = true

        -- Show notification
        TriggerDefeatNotification(encounter.name)
    else
        DebugPrint("No encounter match found for:", destName)
    end
end

-- Handle UPDATE_MOUSEOVER_UNIT to help identify boss NPC IDs (debug helper)
local function DebugPrintMouseoverNpcId()
    if not AdventureGuideClassic_DebugEvents then return end
    local guid = UnitGUID("mouseover")
    if guid and IsCreatureGuid(guid) then
        local npcId = GetNpcIdFromGuid(guid)
        local name = UnitName("mouseover")
        if npcId then
            DebugPrint(string.format("%s - NPC ID: %d", name or "Unknown", npcId))
        end
    end
end

-- Reset all encounters for a dungeon/raid
local function ResetEncountersForInstance(instanceName)
    local found = false

    -- Reset in InstanceService dungeons
    local instanceDungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(instanceDungeons) do
        if dungeon.name == instanceName then
            for i = 1, #dungeon do
                local enc = dungeon[i]
                if type(enc) == "table" and enc.defeated ~= nil then
                    enc.defeated = 0
                    found = true
                end
            end
            break
        end
    end

    -- Reset in InstanceService raids
    local instanceRaids = InstanceService.GetRaids()
    for _, raid in ipairs(instanceRaids) do
        if raid.name == instanceName then
            for i = 1, #raid do
                local enc = raid[i]
                if type(enc) == "table" and enc.defeated ~= nil then
                    enc.defeated = 0
                    found = true
                end
            end
            break
        end
    end

    if found then
        _G.AdventureGuideClassic_UI_Encounters_Refresh = true
        DebugPrint("Reset encounters for:", instanceName)
    end

    return found
end

-- Reset ALL dungeon/raid encounters (for "Reset all instances")
local function ResetAllEncounters()
    -- Reset all dungeons
    local instanceDungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(instanceDungeons) do
        for i = 1, #dungeon do
            local enc = dungeon[i]
            if type(enc) == "table" and enc.defeated ~= nil then
                enc.defeated = 0
            end
        end
    end

    -- Reset all raids
    local instanceRaids = InstanceService.GetRaids()
    for _, raid in ipairs(instanceRaids) do
        for i = 1, #raid do
            local enc = raid[i]
            if type(enc) == "table" and enc.defeated ~= nil then
                enc.defeated = 0
            end
        end
    end

    _G.AdventureGuideClassic_UI_Encounters_Refresh = true
    DebugPrint("All instance encounters have been reset")
end

-- Handle instance reset system messages
local function OnSystemMessage(message)
    -- Check for instance reset messages
    -- English: "has been reset" or "All instances have been reset"
    if message and (message:find("has been reset") or message:find("have been reset")) then
        DebugPrint("Detected instance reset")
        ResetAllEncounters()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("BOSS_KILL")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_END" then
        DebugPrint("ENCOUNTER_END event received")
        OnEncounterEnd(...)
    elseif event == "BOSS_KILL" then
        DebugPrint("BOSS_KILL event received")
        OnBossKill(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        if subEvent == "UNIT_DIED" then
            DebugPrint("UNIT_DIED:", destName)
            OnUnitDied(destGUID, destName)
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local message = ...
        OnSystemMessage(message)
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        DebugPrintMouseoverNpcId()
    end
end)

-- Global function to toggle debug output
-- Usage: /run AGC_ToggleDebug()
_G.AGC_ToggleDebug = function()
    AdventureGuideClassic_DebugEvents = not AdventureGuideClassic_DebugEvents
    if AdventureGuideClassic_DebugEvents then
        print("|cffff9900[AGC]|r Debug output ENABLED")
    else
        print("|cffff9900[AGC]|r Debug output DISABLED")
    end
end

-- Global function to manually reset all encounters
-- Usage: /run AGC_ResetAllEncounters()
_G.AGC_ResetAllEncounters = function()
    ResetAllEncounters()
end

-- Global function to reset a specific instance's encounters
-- Usage: /run AGC_ResetInstance("Ragefire Chasm")
_G.AGC_ResetInstance = function(instanceName)
    if instanceName then
        ResetEncountersForInstance(instanceName)
    else
        print("|cffff9900[AGC]|r Usage: AGC_ResetInstance(\"Instance Name\")")
    end
end

-- Clean up old debounce entries periodically
C_Timer.NewTicker(30, function()
    local now = GetTime()
    for name, time in pairs(recentlyDefeated) do
        if (now - time) > DEBOUNCE_TIME * 2 then
            recentlyDefeated[name] = nil
        end
    end
end)

return EncounterObjective
