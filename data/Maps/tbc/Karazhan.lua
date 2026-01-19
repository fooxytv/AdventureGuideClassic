select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Karazhan",
    location = "Deadwind Pass",
    rows = 4,
    cols = 5,
    layers = {
        [1] = {
            title = "Karazhan - Lower",
            mapID = "Karazhan1",
            texturePath = "Interface/WorldMap/Karazhan/Karazhan1_"
        },
        [2] = {
            title = "Karazhan - Upper",
            mapID = "Karazhan2",
            texturePath = "Interface/WorldMap/Karazhan/Karazhan2_"
        },
    },
    defaultX = 0.500,
    defaultY = 0.500,
})
