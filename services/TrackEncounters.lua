select(2, ...).SetupGlobalFacade()

-- another name for TrackObjectiveInstance is DetectEncounter or TrackEncounter or TrackEncounters or EncounterTracker
local ObjectiveInstance = {}
local encounterName
local dungeonName
local defeatedTriggered = false

local function CheckTargetHealth()
    if not defeatedTriggered and UnitName("target") == encounterName then
        local targetHealth = UnitHealth("target")
        if targetHealth <= 0 then
            print("Target health at zero, marking as defeated.")
            DetectEncounter.Defeated()
        end
    end
end

function DetectEncounter.Start()
    encounterName = UnitName("target")
    dungeonName = GetInstanceInfo()
    local orangeColor = "|cFFFFA500"
    local yellowColor = "|cFFFFFF00"
    local blueColor = "|cFFADD8E6"
    local resetColor = "|r"
    print(orangeColor .. "<" .. resetColor .. yellowColor .. "AGC" .. resetColor .. orangeColor .. ">" .. resetColor .. blueColor .. " " .. encounterName .. " encounter started. Good luck!" .. resetColor)
    defeatedTriggered = false
    C_Timer.NewTicker(0.5, CheckTargetHealth)
end

function DetectEncounter.Defeated()
    if not defeatedTriggered then
        defeatedTriggered = true
        local orangeColor = "|cFFFFA500"
        local yellowColor = "|cFFFFFF00"
        local blueColor = "|cFFADD8E6"
        local resetColor = "|r"
        print(orangeColor .. "<" .. resetColor .. yellowColor .. "AGC" .. resetColor .. orangeColor .. ">" .. resetColor .. blueColor .. " " .. encounterName .. " defeated. Good job!" .. resetColor)
        local dungeons = InstanceService.GetDungeons()
        for _, dungeon in ipairs(dungeons) do
            if dungeon.name == dungeonName then
                for _, encounter in ipairs(dungeon) do
                    if encounter.name == encounterName then
                        encounter.defeated = 1
                        _G.AdventureGuideClassic_UI_Encounters_Refresh = true
                        return true
                    end
                end
            end
        end
    end
    return false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        DetectEncounter.Start()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local eventType, _, _, _, _, _, _, destName = select(2, CombatLogGetCurrentEventInfo())
        if (eventType == "UNIT_DIED") and destName == encounterName then
            PlaySound(6199) -- "Work Complete" sound
            DetectEncounter.Defeated()
        end
    end
end)

return DetectEncounter