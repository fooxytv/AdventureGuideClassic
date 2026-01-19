select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Hellfire Ramparts",
    location = "Hellfire Peninsula",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Hellfire Ramparts",
            mapID = "HellfireRamparts1",
            texturePath = "Interface/WorldMap/HellfireRamparts/HellfireRamparts1_"
        },
    },
    defaultX = 0.500,
    defaultY = 0.500,
})
