select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Wailing Caverns",
    location = "The Barrens",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Wailing Caverns",
            mapID = "WailingCaverns1",
            texturePath = "Interface/WorldMap/WailingCaverns/WailingCaverns1_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})