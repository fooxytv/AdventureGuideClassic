select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Razorfen Downs",
    location = "Barrens",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Razorfen Downs",
            mapID = "RazorfenDowns1",
            texturePath = "Interface/WorldMap/RazorfenDowns/RazorfenDowns1_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})