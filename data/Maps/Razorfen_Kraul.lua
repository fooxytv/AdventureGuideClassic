select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Razorfen Kraul",
    location = "Barrens",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Razorfen Kraul",
            mapID = "RazorfenKraul1",
            texturePath = "Interface/WorldMap/RazorfenKraul/RazorfenKraul1_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})