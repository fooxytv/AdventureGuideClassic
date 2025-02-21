select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Gnomeregan",
    location = "Dun Morogh",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "The Hall of Gears",
            mapID = "Gnomeregan1",
            texturePath = "Interface/WorldMap/Gnomeregan/Gnomeregan1_"
        },
        [2] = {
            title = "The Dormitory",
            mapID = "Gnomeregan2",
            texturePath = "Interface/WorldMap/Gnomeregan/Gnomeregan2_"
        },
        [3] = {
            title = "Launch Bay",
            mapID = "Gnomeregan3",
            texturePath = "Interface/WorldMap/Gnomeregan/Gnomeregan3_"
        },
        [4] = {
            title = "Tinkers' Court",
            mapID = "Gnomeregan4",
            texturePath = "Interface/WorldMap/Gnomeregan/Gnomeregan4_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})