select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Ragefire Chasm",
    location = "Orgrimmar",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Ragefire Chasm",
            mapID = "Ragefire1",
            texturePath = "Interface/WorldMap/Ragefire/Ragefire1_"
        },
    },
    defaultX = 0.500,
    defaultY = 0.685,
})