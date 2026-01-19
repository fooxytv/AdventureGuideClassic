select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Shadowfang Keep",
    location = "Silverpine Forest",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "The Courtyard",
            mapID = "ShadowfangKeep1",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep1_"
        },
        [2] = {
            title = "Dining Hall",
            mapID = "ShadowfangKeep2",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep2_"
        },
        [3] = {
            title = "The Vacant Den",
            mapID = "ShadowfangKeep3",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep3_"
        },
        [4] = {
            title = "Lower Observatory",
            mapID = "ShadowfangKeep4",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep4_"
        },
        [5] = {
            title = "Upper Observatory",
            mapID = "ShadowfangKeep5",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep5_"
        },
        [6] = {
            title = "Lord Godfrey's Chamber",
            mapID = "ShadowfangKeep6",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep6_"
        },
        [7] = {
            title = "The Wall Walk",
            mapID = "ShadowfangKeep7",
            texturePath = "Interface/WorldMap/ShadowfangKeep/ShadowfangKeep7_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})