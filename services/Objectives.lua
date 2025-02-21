select(2, ...).SetupGlobalFacade()

local dungeons = { }
ObjectiveService = { }

function ObjectiveService.AddDungeons(dungeon)
    table.insert(dungeons, dungeon)
end

function ObjectiveService.GetDungeons()
    return dungeons
end