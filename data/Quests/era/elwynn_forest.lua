--[==[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

AUTO-GENERATED -- DO NOT EDIT.
    lua tools/questie_import.lua 12

Derived from the Questie quest database (https://github.com/Questie/Questie),
licensed GPL-3.0, as is this addon. Only chain-shaping fields are carried across:
identity, level gating and the prerequisite graph.

Zone: Elwynn Forest (area 12, uiMapID 1429)
Quests: 49
]==]
select(2, ...).SetupGlobalFacade()

QuestChainService.AddQuests("era", 1429, {
	{ id = 783, name = "A Threat Within", level = 1, req = 1, races = 77, nextInChain = 7 },
	{ id = 16, name = "Give Gerard a Drink", level = 1, req = 1, races = 77 },
	{ id = 7678, name = "Palomino Exchange", level = 1, req = 60, races = 77 },
	{ id = 5805, name = "Welcome!", level = 1, req = 1, races = 1 },
	{ id = 7677, name = "White Stallion Exchange", level = 1, req = 60, races = 77 },
	{ id = 5261, name = "Eagan Peltskinner", level = 2, req = 1, races = 77, pre = { 783 }, nextInChain = 33 },
	{ id = 7, name = "Kobold Camp Cleanup", level = 2, req = 1, races = 77, pre = { 783 } },
	{ id = 33, name = "Wolves Across the Border", level = 2, req = 1, races = 77, pre = { 5261 } },
	{ id = 15, name = "Investigate Echo Ridge", level = 3, req = 1, races = 77, pre = { 7 }, nextInChain = 21 },
	{ id = 18, name = "Brotherhood of Thieves", level = 4, req = 2, races = 77, pre = { 783 } },
	{ id = 3905, name = "Grape Manifest", level = 4, req = 2, races = 77, pre = { 3904 } },
	{ id = 3903, name = "Milly Osworth", level = 4, req = 2, races = 77, pre = { 33 }, nextInChain = 3904 },
	{ id = 3904, name = "Milly's Harvest", level = 4, req = 2, races = 77, pre = { 3903 }, nextInChain = 3905 },
	{ id = 6, name = "Bounty on Garrick Padfoot", level = 5, req = 2, races = 77, pre = { 18 } },
	{ id = 54, name = "Report to Goldshire", level = 5, req = 1, races = 77, pre = { 21 } },
	{ id = 2158, name = "Rest and Relaxation", level = 5, req = 1, races = 77 },
	{ id = 21, name = "Skirmish at Echo Ridge", level = 5, req = 1, races = 77, pre = { 15 } },
	{ id = 84, name = "Back to Billy", level = 6, req = 5, races = 77, pre = { 86 }, nextInChain = 87 },
	{ id = 85, name = "Lost Necklace", level = 6, req = 5, races = 77, nextInChain = 86 },
	{ id = 107, name = "Note to William", level = 6, req = 5, races = 77, pre = { 111 }, nextInChain = 112 },
	{ id = 86, name = "Pie for Billy", level = 6, req = 5, races = 77, pre = { 85 }, nextInChain = 84 },
	{ id = 111, name = "Speak with Gramma", level = 6, req = 5, races = 77, pre = { 106 }, nextInChain = 107 },
	{ id = 106, name = "Young Lovers", level = 6, req = 5, races = 77, nextInChain = 111 },
	{ id = 112, name = "Collecting Kelp", level = 7, req = 5, races = 77, pre = { 107 } },
	{ id = 47, name = "Gold Dust Exchange", level = 7, req = 4, races = 77 },
	{ id = 60, name = "Kobold Candles", level = 7, req = 3, races = 77, nextInChain = 61 },
	{ id = 61, name = "Shipment to Stormwind", level = 7, req = 3, races = 77, pre = { 60 } },
	{ id = 114, name = "The Escape", level = 7, req = 5, races = 77, pre = { 112 } },
	{ id = 62, name = "The Fargodeep Mine", level = 7, req = 4, races = 77, nextInChain = 76 },
	{ id = 87, name = "Goldtooth", level = 8, req = 5, races = 77, pre = { 84 } },
	{ id = 5545, name = "A Bundle of Trouble", level = 9, req = 5, races = 77 },
	{ id = 88, name = "Princess Must Die!", level = 9, req = 6, races = 77 },
	{ id = 83, name = "Red Linen Goods", level = 9, req = 4, races = 77 },
	{ id = 40, name = "A Fishy Peril", level = 10, req = 7, races = 77, nextInChain = 35 },
	{ id = 46, name = "Bounty on Murlocs", level = 10, req = 7, races = 77 },
	{ id = 59, name = "Cloth and Leather Armor", level = 10, req = 7, races = 77, pre = { 39 } },
	{ id = 39, name = "Deliver Thomas' Report", level = 10, req = 7, races = 77, pre = { 71 }, nextInChain = 59 },
	{ id = 45, name = "Discover Rolf's Fate", level = 10, req = 7, races = 77, pre = { 37 }, nextInChain = 71 },
	{ id = 37, name = "Find the Lost Guards", level = 10, req = 7, races = 77, pre = { 35 }, nextInChain = 45 },
	{ id = 35, name = "Further Concerns", level = 10, req = 7, races = 77, pre = { 40 }, nextInChain = 37 },
	{ id = 147, name = "Manhunt", level = 10, req = 7, races = 77, pre = { 123 } },
	{ id = 52, name = "Protect the Frontier", level = 10, req = 7, races = 77 },
	{ id = 109, name = "Report to Gryan Stoutmantle", level = 10, req = 9, races = 77 },
	{ id = 71, name = "Report to Thomas", level = 10, req = 7, races = 77, pre = { 45 }, nextInChain = 39 },
	{ id = 11, name = "Riverpaw Gnoll Bounty", level = 10, req = 6, races = 77, pre = { 239 } },
	{ id = 123, name = "The Collector", level = 10, req = 7, races = 77, nextInChain = 147 },
	{ id = 76, name = "The Jasperlode Mine", level = 10, req = 4, races = 77, pre = { 62 } },
	{ id = 239, name = "Westbrook Garrison Needs Help!", level = 10, req = 6, races = 77, pre = { 76 }, nextInChain = 11 },
	{ id = 176, name = "Wanted:  \"Hogger\"", level = 11, req = 5, races = 77 },
})
