select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Blackfathom Deeps",
    location = "Ashenvale",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "The Pool of Ask'Ar",
            mapID = "BlackfathomDeeps1",
            texturePath = "Interface/Worldmap/BlackfathomDeeps/BlackFathomDeeps1_",
        },
        [2] = {
            title = "Moonshine Sanctum",
            mapID = "BlackfathomDeeps2",
            texturePath = "Interface/Worldmap/BlackfathomDeeps/BlackFathomDeeps2_",
        },
        [3] = {
            title = "The Forgotten Pool",
            mapID = "BlackfathomDeeps3",
            texturePath = "Interface/Worldmap/BlackfathomDeeps/BlackFathomDeeps3_",
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})