select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Blackrock Depths",
    location = "Blackrock Mountain",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Detention Block",
            mapID = "BlackrockDepths1",
            texturePath = "Interface/WorldMap/BlackrockDepths/BlackrockDepths1_"
        },
        [2] = {
            title = "Shadowforge City",
            mapID = "BlackrockDepths2",
            texturePath = "Interface/WorldMap/BlackrockDepths/BlackrockDepths2_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})