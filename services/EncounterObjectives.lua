select(2, ...).SetupGlobalFacade()

local EncounterObjective = {}
AdventureObjectives = AdventureObjectives or {}

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
        end
        break
    end
end

function EncounterObjective.CheckEncounterDefeated(bossName)
    if not bossName then return end
    local dungeonName = GetInstanceInfo()
    local dungeons = ObjectiveService.GetDungeons()
    for _, dungeon in ipairs(dungeons) do
        if dungeon.name == dungeonName then
            for _, encounter in ipairs(dungeon.encounters) do
                if encounter.name == bossName then
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
    local objectiveDungeons = ObjectiveService.GetDungeons()
    local updatedEncounters = nil
    for _, dungeon in ipairs(objectiveDungeons) do
        if dungeon.name == dungeonName then
            updatedEncounters = dungeon.encounters
            for _, encounter in ipairs(dungeon.encounters or {}) do
                if encounter.name == bossName then
                    encounter.defeated = 1
                end
            end
            break
        end
    end
    local instanceDungeons = InstanceService.GetDungeons()
    for _, dungeon in ipairs(instanceDungeons) do
        if dungeon.name == dungeonName then
            for i, encounter in ipairs(dungeon) do
                if type(encounter) == "table" and encounter.name and encounter.defeated ~= nil then
                    if encounter.name == bossName then
                        encounter.defeated = 1
                    end
                end
            end
            break
        end
    end
    if AdventureObjectives and AdventureObjectives.LoadEncounters then
        AdventureObjectives:LoadEncounters(dungeonName, updatedEncounters)
        _G.AdventureGuideClassic_UI_Encounters_Refresh = true
    end
end

local function OnCombatEvent(_, event, ...)
    local _, subEvent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
    if subEvent == "UNIT_DIED" then
        local dungeonName = GetInstanceInfo()
        local dungeons = ObjectiveService.GetDungeons()
        for _, dungeon in ipairs(dungeons) do
            if dungeon.name == dungeonName then
                for _, encounter in ipairs(dungeon.encounters) do
                    if encounter.name == destName then
                        PlaySoundFile("Interface\\AddOns\\AdventureGuideClassic\\sounds\\UIEJBossDefeated.ogg", "Dialog")
                        EncounterObjective.CheckEncounterDefeated(destName)
                        return
                    end
                end
            end
        end
    end
end

-- Create new function which listens for <dungeonName> has been reset to re-create the tables again for ObjectiveService.GetDungeons() and InstanceService.GetDungeons()


local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ENCOUNTER_START")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        OnCombatEvent(self, event, ...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
        if subEvent == "UNIT_DIED" then
            OnCombatEvent(self, subEvent, nil, destName)
        end
    end
end)

return EncounterObjective