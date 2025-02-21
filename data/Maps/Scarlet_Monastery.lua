select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Scarlet Monastery",
    location = "Tirisfal Glades",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Graveyard",
            mapID = "ScarletMonastery1",
            texturePath = "Interface/WorldMap/ScarletMonastery/ScarletMonastery1_"
        },
        [2] = {
            title = "Library",
            mapID = "ScarletMonastery2",
            texturePath = "Interface/WorldMap/ScarletMonastery/ScarletMonastery2_"
        },
        [3] = {
            title = "Armory",
            mapID = "ScarletMonastery3",
            texturePath = "Interface/WorldMap/ScarletMonastery/ScarletMonastery3_"
        },
        [4] = {
            title = "Cathedral",
            mapID = "ScarletMonastery4",
            texturePath = "Interface/WorldMap/ScarletMonastery/ScarletMonastery4_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})