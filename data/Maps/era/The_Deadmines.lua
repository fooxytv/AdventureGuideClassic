select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "The Deadmines",
    location = "Westfall",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "The Deadmines",
            mapID = "TheDeadmines1",
            texturePath = "Interface/WorldMap/TheDeadmines/TheDeadmines1_"
        },
        [2] = {
            title = "Ironclad Cove",
            mapID = "TheDeadmines2",
            texturePath = "Interface/WorldMap/TheDeadmines/TheDeadmines2_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})