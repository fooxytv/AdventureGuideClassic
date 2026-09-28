select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Blackrock Spire",
    location = "Blackrock Mountain",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Tazz'Alor",
            mapID = "BlackrockSpire1",
            texturePath = "Interface/Worldmap/BlackrockSpire/BlackrockSpire1_"
        },
        [2] = {
            title = "Skitterweb Tunnels",
            mapID = "BlackrockSpire2",
            texturePath = "Interface/Worldmap/BlackrockSpire/BlackrockSpire2_"
        },
        [3] = {
            title = "Hordemar City",
            mapID = "BlackrockSpire3",
            texturePath = "Interface/Worldmap/BlackrockSpire/BlackrockSpire3_"
        },
        [4] = {
            title = "Hall of Blackhand",
            mapID = "BlackrockSpire4",
            texturePath = "Interface/Worldmap/BlackrockSpire/BlackrockSpire4_"
        },
        [5] = {
            title = "Halycon's Lair",
            mapID = "BlackrockSpire5",
            texturePath = "Interface/Worldmap/BlackrockSpire/BlackrockSpire5_"
        },
        [6] = {
            title = "Chamber of Battle",
            mapID = "BlackrockSpire6",
            texturePath = "Interface/Worldmap/BlackrockSpire/BlackrockSpire6_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})