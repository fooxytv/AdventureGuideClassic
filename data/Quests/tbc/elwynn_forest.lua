--[==[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

AUTO-GENERATED -- DO NOT EDIT.
    lua tools/questie_import.lua 12

Derived from the Questie quest database (https://github.com/Questie/Questie),
licensed GPL-3.0, as is this addon. Only what the guide needs is carried across:
identity, level gating, the prerequisite graph, and the one-line objectives text.

Creature display ids come from the CMaNGOS Classic 1.12.1 world database (GPL-2.0),
via tools/extract_npc_models.py.

Zone: Elwynn Forest (area 12, uiMapID 1429)
Quests: 48
]==]
select(2, ...).SetupGlobalFacade()

QuestChainService.AddNpcs("tbc", 1429, {
	[6] = { "Kobold Vermin", 10913 },
	[80] = { "Kobold Laborer", 365 },
	[118] = { "Prowler", 11415 },
	[196] = { "Eagan Peltskinner", 3251 },
	[197] = { "Marshal McBride", 1859 },
	[233] = { "Farmer Saldean", 1943 },
	[234] = { "Gryan Stoutmantle", 1690 },
	[237] = { "Farmer Furlbrow", 1944 },
	[240] = { "Marshal Dughan", 1985 },
	[241] = { "Remy \"Two Times\"", 3254 },
	[244] = { "Ma Stonefield", 3330 },
	[246] = { "\"Auntie\" Bernice Stonefield", 3329 },
	[247] = { "Billy Maclure", 221 },
	[248] = { "Gramma Stonefield", 2959 },
	[251] = { "Maybell Maclure", 3323 },
	[252] = { "Tommy Joe Stonefield", 3331 },
	[253] = { "William Pestle", 5038 },
	[255] = { "Gerard Tiller", 3324 },
	[257] = { "Kobold Worker", 10912 },
	[261] = { "Guard Thomas", 1984 },
	[278] = { "Sara Timberlain", 3268 },
	[279] = { "Morgan Pestle", 5082 },
	[295] = { "Innkeeper Farley", 1291 },
	[822] = { "Young Forest Bear", 1006 },
	[823] = { "Deputy Willem", 2072 },
	[952] = { "Brother Neals", 3317 },
	[963] = { "Deputy Rainer", 3279 },
	[6774] = { "Falkhaan Isenstrider", 5526 },
	[9296] = { "Milly Osworth", 8489 },
	[10616] = { "Supervisor Raelen", 10995 },
	[11940] = { "Merissa Stilwell", 11898 },
})

QuestChainService.AddQuests("tbc", 1429, {
	{ id = 783, name = "A Threat Within", level = 1, req = 1, races = 1101, nextInChain = 7, text = "Speak with Marshal McBride.", npcs = { 197, 823 } },
	{ id = 16, name = "Give Gerard a Drink", level = 1, req = 1, races = 1101, npcs = { 255 } },
	{ id = 7961, name = "Waskily Wabbits!", level = 1, req = 1, races = 0, text = "Kill 5 rabbits and return to Jon LeCraft by the forge on Designer Island." },
	{ id = 5805, name = "Welcome!", level = 1, req = 1, races = 1, text = "Bring the Northshire Gift Voucher to Merissa Stilwell.", npcs = { 11940 } },
	{ id = 5261, name = "Eagan Peltskinner", level = 2, req = 1, races = 1101, pre = { 783 }, nextInChain = 33, text = "Speak with Eagan Peltskinner.", npcs = { 196, 823 } },
	{ id = 7, name = "Kobold Camp Cleanup", level = 2, req = 1, races = 1101, pre = { 783 }, text = "Kill 10 Kobold Vermin, then return to Marshal McBride.", npcs = { 197, 6 } },
	{ id = 33, name = "Wolves Across the Border", level = 2, req = 1, races = 1101, pre = { 5261 }, text = "Bring 8 pieces of Tough Wolf Meat to Eagan Peltskinner outside Northshire Abbey.", npcs = { 196 } },
	{ id = 15, name = "Investigate Echo Ridge", level = 3, req = 2, races = 1101, pre = { 7 }, nextInChain = 21, text = "Kill 10 Kobold Workers, then report back to Marshal McBride.", npcs = { 197, 257 } },
	{ id = 18, name = "Brotherhood of Thieves", level = 4, req = 2, races = 1101, pre = { 783 }, text = "Bring 12 Red Burlap Bandanas to Deputy Willem outside the Northshire Abbey.", npcs = { 823 } },
	{ id = 3905, name = "Grape Manifest", level = 4, req = 2, races = 1101, pre = { 3904 }, text = "Bring the Grape Manifest to Brother Neals in Northshire Abbey.", npcs = { 952, 9296 } },
	{ id = 3903, name = "Milly Osworth", level = 4, req = 3, races = 1101, pre = { 33 }, nextInChain = 3904, text = "Speak with Milly Osworth.", npcs = { 823, 9296 } },
	{ id = 3904, name = "Milly's Harvest", level = 4, req = 2, races = 1101, pre = { 3903 }, nextInChain = 3905, text = "Bring 8 crates of Milly's Harvest to Milly Osworth at Northshire Abbey.", npcs = { 9296 } },
	{ id = 6, name = "Bounty on Garrick Padfoot", level = 5, req = 2, races = 1101, pre = { 18 }, text = "Kill Garrick Padfoot and bring his head to Deputy Willem at Northshire Abbey.", npcs = { 823 } },
	{ id = 54, name = "Report to Goldshire", level = 5, req = 3, races = 1101, pre = { 21 }, text = "Take Marshal McBride's Documents to Marshal Dughan in Goldshire.", npcs = { 197, 240 } },
	{ id = 2158, name = "Rest and Relaxation", level = 5, req = 1, races = 1101, text = "Speak with Innkeeper Farley at the Lion's Pride Inn.", npcs = { 6774, 295 } },
	{ id = 21, name = "Skirmish at Echo Ridge", level = 5, req = 1, races = 1101, pre = { 15 }, text = "Kill 12 Kobold Laborers, then return to Marshal McBride at Northshire Abbey.", npcs = { 197, 80 } },
	{ id = 84, name = "Back to Billy", level = 6, req = 5, races = 1101, pre = { 86 }, nextInChain = 87, text = "Bring the Pork Belly Pie to Billy Maclure at the Maclure Vineyards.", npcs = { 246, 247 } },
	{ id = 85, name = "Lost Necklace", level = 6, req = 5, races = 1101, nextInChain = 86, text = "Speak with Billy Maclure.", npcs = { 246, 247 } },
	{ id = 107, name = "Note to William", level = 6, req = 5, races = 1101, pre = { 111 }, nextInChain = 112, text = "Take Gramma Stonefield's Note to William Pestle.", npcs = { 248, 253 } },
	{ id = 86, name = "Pie for Billy", level = 6, req = 5, races = 1101, pre = { 85 }, nextInChain = 84, text = "Bring 4 Chunks of Boar Meat to Auntie Bernice Stonefield at the Stonefield's Farm.", npcs = { 246, 247 } },
	{ id = 111, name = "Speak with Gramma", level = 6, req = 5, races = 1101, pre = { 106 }, nextInChain = 107, text = "Speak with Gramma Stonefield.", npcs = { 252, 248 } },
	{ id = 106, name = "Young Lovers", level = 6, req = 5, races = 1101, nextInChain = 111, text = "Give Maybell's Love Letter to Tommy Joe Stonefield.", npcs = { 252, 251 } },
	{ id = 112, name = "Collecting Kelp", level = 7, req = 5, races = 1101, pre = { 107 }, text = "Bring 4 Crystal Kelp Fronds to William Pestle in Goldshire.", npcs = { 253 } },
	{ id = 47, name = "Gold Dust Exchange", level = 7, req = 4, races = 1101, text = "Bring 10 Gold Dust to Remy \"Two Times\" in Goldshire. Gold Dust is gathered from Kobolds in Elwynn Forest.", npcs = { 241 } },
	{ id = 60, name = "Kobold Candles", level = 7, req = 3, races = 1101, nextInChain = 61, text = "Bring 8 Large Candles to William Pestle in Goldshire.", npcs = { 253 } },
	{ id = 61, name = "Shipment to Stormwind", level = 7, req = 3, races = 1101, pre = { 60 }, text = "Bring William's Shipment to Morgan Pestle in the Stormwind Trade District.", npcs = { 253, 279 } },
	{ id = 114, name = "The Escape", level = 7, req = 5, races = 1101, pre = { 112 }, text = "Take the Invisibility Liquor to Maybell Maclure.", npcs = { 251, 253 } },
	{ id = 62, name = "The Fargodeep Mine", level = 7, req = 4, races = 1101, nextInChain = 76, text = "Explore the Fargodeep Mine, then return to Marshal Dughan in Goldshire.", npcs = { 240 } },
	{ id = 87, name = "Goldtooth", level = 8, req = 5, races = 1101, pre = { 84 }, text = "Bring Bernice's Necklace to \"Auntie\" Bernice Stonefield at the Stonefield Farm.", npcs = { 246, 247 } },
	{ id = 5545, name = "A Bundle of Trouble", level = 9, req = 5, races = 1101, text = "Bring 8 Bundles of Wood to Raelen at the Eastvale Logging Camp.", npcs = { 10616 } },
	{ id = 88, name = "Princess Must Die!", level = 9, req = 6, races = 1101, text = "Kill Princess, grab her collar, then bring it back to Ma Stonefield at the Stonefield Farm.", npcs = { 244 } },
	{ id = 83, name = "Red Linen Goods", level = 9, req = 4, races = 1101, text = "Bring 6 Red Linen Bandanas to Sara Timberlain at the Eastvale Logging Camp.", npcs = { 278 } },
	{ id = 40, name = "A Fishy Peril", level = 10, req = 7, races = 1101, nextInChain = 35, text = "Remy \"Two Times\" wants you to speak with Marshal Dughan in Goldshire.", npcs = { 241, 240 } },
	{ id = 46, name = "Bounty on Murlocs", level = 10, req = 7, races = 1101, text = "Bring 8 Torn Murloc Fins to Guard Thomas at the east Elwynn bridge.", npcs = { 261 } },
	{ id = 59, name = "Cloth and Leather Armor", level = 10, req = 7, races = 1101, pre = { 39 }, text = "Give Sara Timberlain the Stormwind Armor Marker.", npcs = { 278, 240 } },
	{ id = 39, name = "Deliver Thomas' Report", level = 10, req = 7, races = 1101, pre = { 71 }, nextInChain = 59, text = "Report to Marshal Dughan in Goldshire.", npcs = { 240, 261 } },
	{ id = 45, name = "Discover Rolf's Fate", level = 10, req = 7, races = 1101, pre = { 37 }, nextInChain = 71, text = "Search the murloc village for Rolf, or signs of his death." },
	{ id = 37, name = "Find the Lost Guards", level = 10, req = 7, races = 1101, pre = { 35 }, nextInChain = 45, text = "Guard Thomas wants you to travel north up the river and search for the two lost guards, Rolf and Malakai.", npcs = { 261 } },
	{ id = 35, name = "Further Concerns", level = 10, req = 7, races = 1101, pre = { 40 }, nextInChain = 37, text = "Marshal Dughan wants you to speak with Guard Thomas.", npcs = { 240, 261 } },
	{ id = 147, name = "Manhunt", level = 10, req = 7, races = 1101, pre = { 123 }, text = "Find and kill \"the Collector\" then return to Marshal Dughan with The Collector's Ring.", npcs = { 240 } },
	{ id = 52, name = "Protect the Frontier", level = 10, req = 7, races = 1101, text = "Kill 8 Prowlers and 5 Young Forest Bears, and then return to Guard Thomas at the east Elwynn bridge.", npcs = { 822, 261, 118 } },
	{ id = 109, name = "Report to Gryan Stoutmantle", level = 10, req = 9, races = 1101, text = "Talk to Gryan Stoutmantle. He usually can be found in the stone tower on Sentinel Hill, just off the road, in the middle of Westfall.", npcs = { 234, 237, 233, 240, 963, 261 } },
	{ id = 71, name = "Report to Thomas", level = 10, req = 7, races = 1101, pre = { 45 }, nextInChain = 39, text = "Deliver Rolf and Malakai's Medallions to Guard Thomas at the eastern Elwynn bridge.", npcs = { 261 } },
	{ id = 11, name = "Riverpaw Gnoll Bounty", level = 10, req = 6, races = 1101, pre = { 239 }, text = "Bring 8 Painted Gnoll Armbands to Deputy Rainer at the Barracks.", npcs = { 963 } },
	{ id = 123, name = "The Collector", level = 10, req = 7, races = 1101, text = "Go to Marshal Dughan in Goldshire and give him The Collector's Schedule.", npcs = { 240 } },
	{ id = 76, name = "The Jasperlode Mine", level = 10, req = 5, races = 1101, pre = { 62 }, text = "Explore the Jasperlode Mine, then report back to Marshal Dughan in Goldshire.", npcs = { 240 } },
	{ id = 239, name = "Westbrook Garrison Needs Help!", level = 10, req = 6, races = 1101, pre = { 76 }, nextInChain = 11, text = "Go to the Westbrook Garrison and speak with Deputy Rainer.", npcs = { 240, 963 } },
	{ id = 176, name = "Wanted:  \"Hogger\"", level = 11, req = 6, races = 1101, text = "Slay the gnoll Hogger and bring his Huge Gnoll Claw to Marshal Dughan.", npcs = { 240 } },
})
