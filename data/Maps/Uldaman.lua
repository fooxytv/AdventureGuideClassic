select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Uldaman",
    location = "Badlands",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Hall of the Keepers",
            mapID = "Uldaman1",
            texturePath = "Interface/WorldMap/Uldaman/Uldaman1_"
        },
        [2] = {
            title = "Khaz'Goroth's Seat",
            mapID = "Uldaman2",
            texturePath = "Interface/WorldMap/Uldaman/Uldaman2_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})