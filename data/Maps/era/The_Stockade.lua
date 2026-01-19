select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Stormwind Stockade",
    location = "Stormwind City",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Stormwind Stockade",
            mapID = "TheStockade1",
            texturePath = "Interface/WorldMap/TheStockade/TheStockade1_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})