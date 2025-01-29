select(2, ...).SetupGlobalFacade()

local dungeons = { }
ObjectiveTrackerService = { }

function ObjectiveTrackerService.AddDungeons(dungeon)
    table.insert(dungeons, dungeon)
    print("Service called: AddDungeons - Dungeon added: " .. dungeon.name)
end

function ObjectiveTrackerService.GetDungeons()
    print("Service called: GetDungeons")
    for _, dungeon in ipairs(dungeons) do
        print(dungeon.name)
        for _, encounter in ipairs(dungeon.encounters) do
            print(" " .. encounter.name, encounter.defeated)
        end
    end
    return dungeons
end
