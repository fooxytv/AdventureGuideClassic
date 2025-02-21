select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Dire Maul",
    location = "Feralas",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Gordok Commons",
            mapID = "DireMaul1",
            texturePath = "Interface/WorldMap/DireMaul/DireMaul1_"
        },
        [2] = {
            title = "Capital Gardens",
            mapID = "DireMaul2",
            texturePath = "Interface/WorldMap/DireMaul/DireMaul2_"
        },
        [3] = {
            title = "Court of the Highborne",
            mapID = "DireMaul3",
            texturePath = "Interface/WorldMap/DireMaul/DireMaul3_"
        },
        [4] = {
            title = "Prison of Immol'thar",
            mapID = "DireMaul4",
            texturePath = "Interface/WorldMap/DireMaul/DireMaul4_"
        },
        [5] = {
            title = "Warpwood Quarter",
            mapID = "DireMaul5",
            texturePath = "Interface/WorldMap/DireMaul/DireMaul5_"
        },
        [6] = {
            title = "The Shrine of Eldretharr",
            mapID = "DireMaul6",
            texturePath = "Interface/WorldMap/DireMaul/DireMaul6_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})