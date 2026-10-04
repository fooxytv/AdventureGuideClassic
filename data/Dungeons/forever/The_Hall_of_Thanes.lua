--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Hall of Thanes",
	instanceID = 1234,
	thumbnail = I.UIEJDungeonButtonTheHallOfThanes,
	mapID = 1234,
	seasonFilter = "forever",
	overview = "Encounter and loot details for this instance are not yet available. They will be added as Forever's dungeons and raids are documented.",
})
