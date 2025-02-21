select(2, ...).SetupGlobalFacade()

DungeonMapService.AddTiles({
    instanceName = "The Temple of Atal'hakkar",
    location = "Swamp of Sorrows",
    rows = 3,
    cols = 4,
    layers = {
        [1] = {
            title = "The Temple of Atal'hakkar",
            mapID = "TheTempleofAtalhakkar1",
            texturePath = "Interface/WorldMap/TheTempleofAtalhakkar/TheTempleofAtalhakkar1_"
        }
    },
    defaultX = 0.500,
    defaultY = 0.685,
})