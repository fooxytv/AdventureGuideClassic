select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Scholomance",
    location = "Western Plaguelands",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "The Reliquary",
            mapID = "Scholomance1",
            texturePath = "Interface/WorldMap/Scholomance/Scholomance1_"
        },
        [2] = {
            title = "Chamber of Summoning",
            mapID = "Scholomance2",
            texturePath = "Interface/WorldMap/Scholomance/Scholomance2_"
        },
        [3] = {
            title = "The Upper Study",
            mapID = "Scholomance3",
            texturePath = "Interface/WorldMap/Scholomance/Scholomance3_"
        },
        [4] = {
            title = "Headmaster's Study",
            mapID = "Scholomance4",
            texturePath = "Interface/WorldMap/Scholomance/Scholomance4_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})