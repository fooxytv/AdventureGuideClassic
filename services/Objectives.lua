select(2, ...).SetupGlobalFacade()

local dungeons = { }
ObjectiveService = { }

function ObjectiveService.AddDungeons(dungeon)
    table.insert(dungeons, dungeon)
end

function ObjectiveService.GetDungeons()
    local dungeonData = {}
    for _, dungeon in ipairs(dungeons) do
        local dungeonEntry = {
            name = dungeon.name,
            encounters = {}
        }
        for _, encounter in ipairs(dungeon.encounters) do
            table.insert(dungeonEntry.encounters, {
                name = encounter.name,
                defeated = encounter.defeated
            })
        end
        table.insert(dungeonData, dungeonEntry)
    end
    return dungeonData
end

-- function ObjectiveTrackerService.GetDungeons()
--     print("Service called: GetDungeons")
--     for _, dungeon in ipairs(dungeons) do
--         print(dungeon.name)
--         for _, encounter in ipairs(dungeon.encounters) do
--             print(" " .. encounter.name, encounter.defeated)
--         end
--     end
--     return dungeons
-- end