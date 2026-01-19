select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Stratholme",
    location = "Eastern Plaguelands",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Crusader's Square",
            mapID = "Stratholme1",
            texturePath = "Interface/WorldMap/Stratholme/Stratholme1_"
        },
        [2] = {
            title = "The Gauntlet",
            mapID = "Stratholme2",
            texturePath = "Interface/WorldMap/Stratholme/Stratholme2_"
        },
    },
    defaultX = 0.500,
    defaultY = 0.685,
})