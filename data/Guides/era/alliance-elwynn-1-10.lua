--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
PILOT GUIDE -- hand-authored to exercise the guide window.

Quests are referenced by NAME, not id. Hand-written quest ids would be wrong silently,
the same way hand-written uiMapIDs were. The Questie import (Phase 6) attaches ids,
objective counts and coordinates from a real database; until then this is a readable
route, not a tracked one.

Step format: a flat list of tasks, each `{ "<type>", ... }`. See
ui/guide/GuideTaskTypes.lua for the types and the fields each one uses.
]]

GuideService.AddGuide({
	id = "era-alliance-elwynn-1-10",
	expansion = "era",
	faction = "Alliance",
	races = { "Human" },
	levels = { min = 1, max = 10 },
	zone = "Elwynn Forest",
	title = "Elwynn Forest (1-10)",
	steps = {
		-- Northshire Abbey
		{ "accept", quest = "A Threat Within", npc = "Marshal McBride",
			note = "Inside Northshire Abbey." },
		{ "turnin", quest = "A Threat Within", npc = "Marshal McBride" },
		{ "accept", quest = "Kobold Camp Cleanup", npc = "Marshal McBride" },
		{ "kill", target = "Kobold Vermin", count = 10,
			note = "In the mine area east of the abbey." },
		{ "turnin", quest = "Kobold Camp Cleanup", npc = "Marshal McBride" },
		{ "accept", quest = "Investigate Echo Ridge", npc = "Marshal McBride" },
		{ "kill", target = "Kobold Worker", count = 8, note = "Echo Ridge Mine." },
		{ "turnin", quest = "Investigate Echo Ridge", npc = "Marshal McBride" },
		{ "train", place = "Northshire Abbey", note = "Pick up your level 4 spells." },

		{ "accept", quest = "Skirmish at Echo Ridge", npc = "Marshal McBride" },
		{ "kill", target = "Kobold Laborer", count = 10 },
		{ "turnin", quest = "Skirmish at Echo Ridge", npc = "Marshal McBride" },
		{ "accept", quest = "Brotherhood of Thieves", npc = "Deputy Willem" },
		{ "kill", target = "Defias Thug", count = 6,
			note = "Along the road south-east of the abbey." },
		{ "collect", item = "Blackrock Medallion", count = 1 },
		{ "turnin", quest = "Brotherhood of Thieves", npc = "Deputy Willem" },
		{ "level", level = 6 },

		-- South to Goldshire
		{ "goto", place = "Goldshire", note = "Follow the road south-west out of Northshire." },
		{ "sethearth", place = "Goldshire", note = "Innkeeper Farley, in the Lion's Pride Inn." },
		{ "train", place = "Goldshire" },
		{ "vendor", place = "Goldshire", note = "Sell greys and top up on food and water." },

		{ "accept", quest = "Kobold Candles", npc = "Innkeeper Farley" },
		{ "accept", quest = "Gold Dust Exchange", npc = "William Pestle" },
		{ "collect", item = "Large Candle", count = 8,
			note = "From kobolds in the Fargodeep Mine, south of Goldshire." },
		{ "collect", item = "Gold Dust", count = 6, note = "Same kobolds." },
		{ "turnin", quest = "Kobold Candles", npc = "Innkeeper Farley" },
		{ "turnin", quest = "Gold Dust Exchange", npc = "William Pestle" },
		{ "level", level = 8 },

		-- Westbrook Garrison
		{ "goto", place = "Westbrook Garrison",
			note = "West along the road towards the Westfall border." },
		{ "accept", quest = "Westbrook Garrison Needs You!", npc = "Deputy Rainer" },
		{ "kill", target = "Riverpaw Gnoll", count = 12,
			note = "North of the garrison, around Jasperlode Mine." },
		{ "turnin", quest = "Westbrook Garrison Needs You!", npc = "Deputy Rainer" },
		{ "vendor", place = "Goldshire" },
		{ "train", place = "Goldshire", note = "Level 10 spells are worth the trip." },
		{ "level", level = 10 },
		{ "note", text = "Elwynn is done. Head west to Westfall, or south to Duskwood " ..
			"if you want a change of scenery." },
	},
})
