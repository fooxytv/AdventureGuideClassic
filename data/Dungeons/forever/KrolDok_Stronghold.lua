--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

A Forever dungeon, added in World of Warcraft: Forever.

Names are from community datamining of the 1.60.1 beta and want confirming against
the client. Encounters and loot are deliberately absent rather than guessed at:
AtlasLoot has no Forever data yet, so there is nothing to draw them from. It carries no
art either: the guide draws a plain dark tile for an instance without any, which
reads as not yet illustrated rather than as a picture that failed to load.
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Krol'Dok Stronghold",
	seasonFilter = "forever",
	overview = "Encounter and loot details for this instance are not yet available. They will be added as Forever's dungeons and raids are documented.",
})
