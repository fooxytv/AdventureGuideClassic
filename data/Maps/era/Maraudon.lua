select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Maraudon",
    location = "Desolace",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Caverns of Maraudon",
            mapID = "Maraudon1",
            texturePath = "Interface/WorldMap/Maraudon/Maraudon1_"
        },
        [2] = {
            title = "Zaetar's Grave",
            mapID = "Maraudon2",
            texturePath = "Interface/WorldMap/Maraudon/Maraudon2_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})