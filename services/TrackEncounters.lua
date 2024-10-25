select(2, ...).SetupGlobalFacade()

local DetectEncounter = {}

-- local function HandleEncounterDetector(...)
--     -- This function will be called when an enounter has been detected..
--     -- if statement.. check if <DBM Core>Main Core and <DBM Mod>Dungeons (Vanilla) are loaded then look for DBM calling the encounter start and ending.
--     -- if DBM is not loaded then look for the combat log event..
    
-- end

function DetectEncounter.Start()
    if isDBMLoaded then
        -- do not print any information
    else
        -- print("DBM is not loaded, using combat log event to detect encounters.")
        -- HandleEncounterDetector()
        local encounterName = UnitName("target")
        local orangeColor = "|cFFFFA500"
        local yellowColor = "|cFFFFFF00"
        local blueColor = "|cFFADD8E6"
        local resetColor = "|r"
        print(orangeColor .. "<" .. resetColor .. yellowColor .. "AGC" .. resetColor .. orangeColor .. ">" .. resetColor .. blueColor .. " " .. encounterName .. " engaged. Good luck and have fun!" .. resetColor)
    end
end

function DetectEncounter.Defeated(dungeonName, encounterName)
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
    return false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        DetectEncounter.Start()
    end
end)

return DetectEncounter