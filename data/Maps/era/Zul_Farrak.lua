select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "Zul'Farrak",
    location = "Tanaris",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "Zul'Farrak",
            mapID = "ZulFarrak1",
            texturePath = "Interface/AddOns/AdventureGuideClassic/images/ZulFarrak1_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})