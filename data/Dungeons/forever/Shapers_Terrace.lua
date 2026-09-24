--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

A Forever dungeon, added in World of Warcraft: Forever.

Names are from community datamining of the 1.60.1 beta and want confirming against
the client. Encounters and loot are deliberately absent rather than guessed at:
AtlasLoot has no Forever data yet, so there is nothing to draw them from. The
placeholder art (527422) stands in until this instance has its own.
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Shaper's Terrace",
	thumbnail = 527422,
	icon = 527422,
	splash = 527422,
	seasonFilter = "forever",
	overview = "Encounter and loot details for this instance are not yet available. They will be added as Forever's dungeons and raids are documented.",
})
