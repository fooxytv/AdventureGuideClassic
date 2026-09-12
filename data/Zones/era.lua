--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
Levelling zones for Classic Era, used by Suggested Content to answer "where should I
be levelling right now?".

	uiMapID    the zone's map id -- verify with /run AGC_VerifyZoneMapIDs()
	levelRange the band the zone's quests actually serve
	rec        the level at which this is the best pick, used for ranking
	faction    nil when both factions quest here

Capital cities, Moonglade and Deadwind Pass are deliberately absent: nobody levels
there, so suggesting them would be wrong.
]]

local function Zone(zone)
	zone.expansion = "era"
	ZoneService.AddZone(zone)
end

-- Starting zones --------------------------------------------------------------

Zone({
	name = "Elwynn Forest", uiMapID = 37, levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Alliance", continent = "Eastern Kingdoms", races = { "Human" },
	overview = "The wooded home of Stormwind's farmsteads, and the starting ground for humans.",
})
Zone({
	name = "Dun Morogh", uiMapID = 27, levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Alliance", continent = "Eastern Kingdoms", races = { "Dwarf", "Gnome" },
	overview = "Snowbound peaks around Ironforge, where dwarves and gnomes begin.",
})
Zone({
	name = "Teldrassil", uiMapID = 57, levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Alliance", continent = "Kalimdor", races = { "NightElf" },
	overview = "The great world tree above Darnassus, home of the night elves.",
})
Zone({
	name = "Durotar", uiMapID = 1, levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Horde", continent = "Kalimdor", races = { "Orc", "Troll" },
	overview = "The red canyons surrounding Orgrimmar, where orcs and trolls begin.",
})
Zone({
	name = "Mulgore", uiMapID = 7, levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Horde", continent = "Kalimdor", races = { "Tauren" },
	overview = "Open plains beneath Thunder Bluff, the tauren homeland.",
})
Zone({
	name = "Tirisfal Glades", uiMapID = 20, levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Horde", continent = "Eastern Kingdoms", races = { "Scourge" },
	overview = "The blighted farmland above the Undercity, where the Forsaken rise.",
})

-- Low level -------------------------------------------------------------------

Zone({
	name = "Westfall", uiMapID = 52, levelRange = { min = 10, max = 20 }, rec = 15,
	faction = "Alliance", continent = "Eastern Kingdoms",
	overview = "Failing farmland overrun by the Defias, and the road to the Deadmines.",
})
Zone({
	name = "Loch Modan", uiMapID = 48, levelRange = { min = 10, max = 20 }, rec = 15,
	faction = "Alliance", continent = "Eastern Kingdoms",
	overview = "A dwarven lake country beset by troggs and Dark Iron raiders.",
})
Zone({
	name = "Darkshore", uiMapID = 62, levelRange = { min = 10, max = 20 }, rec = 15,
	faction = "Alliance", continent = "Kalimdor",
	overview = "Storm-wrecked coastline north of Teldrassil, thick with ancient ruins.",
})
Zone({
	name = "Silverpine Forest", uiMapID = 21, levelRange = { min = 10, max = 20 }, rec = 15,
	faction = "Horde", continent = "Eastern Kingdoms",
	overview = "Worgen-haunted woods between Tirisfal and Hillsbrad.",
})
Zone({
	name = "The Barrens", uiMapID = 10, levelRange = { min = 10, max = 25 }, rec = 17,
	faction = "Horde", continent = "Kalimdor",
	overview = "The vast savannah at the heart of Kalimdor, and the Horde's main levelling road.",
})
Zone({
	name = "Redridge Mountains", uiMapID = 49, levelRange = { min = 15, max = 25 }, rec = 20,
	faction = "Alliance", continent = "Eastern Kingdoms",
	overview = "A besieged lakeside town holding back gnolls and orcs.",
})
Zone({
	name = "Stonetalon Mountains", uiMapID = 65, levelRange = { min = 15, max = 27 }, rec = 20,
	faction = nil, continent = "Kalimdor",
	overview = "Logging camps and harpy-held peaks contested by both factions.",
})
Zone({
	name = "Duskwood", uiMapID = 47, levelRange = { min = 18, max = 30 }, rec = 24,
	faction = "Alliance", continent = "Eastern Kingdoms",
	overview = "Permanently darkened woods plagued by undead and worgen.",
})
Zone({
	name = "Ashenvale", uiMapID = 63, levelRange = { min = 18, max = 30 }, rec = 24,
	faction = nil, continent = "Kalimdor",
	overview = "Old-growth forest where night elves and the Horde fight over the timber.",
})
Zone({
	name = "Wetlands", uiMapID = 56, levelRange = { min = 20, max = 30 }, rec = 25,
	faction = "Alliance", continent = "Eastern Kingdoms",
	overview = "Rain-soaked marsh of raptors and murlocs, with dragonkin to the north.",
})
Zone({
	name = "Hillsbrad Foothills", uiMapID = 25, levelRange = { min = 20, max = 30 }, rec = 25,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Rolling farmland contested between Southshore and Tarren Mill.",
})

-- Mid level -------------------------------------------------------------------

Zone({
	name = "Thousand Needles", uiMapID = 64, levelRange = { min = 25, max = 35 }, rec = 30,
	faction = nil, continent = "Kalimdor",
	overview = "Towering mesas above a dry basin, home to the Shimmering Flats races.",
})
Zone({
	name = "Alterac Mountains", uiMapID = 36, levelRange = { min = 30, max = 40 }, rec = 35,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Snowbound ruins held by ogres, syndicate bandits and yetis.",
})
Zone({
	name = "Arathi Highlands", uiMapID = 14, levelRange = { min = 30, max = 40 }, rec = 35,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Windswept highland of Stromgarde's ruin and Boulderfist ogres.",
})
Zone({
	name = "Desolace", uiMapID = 66, levelRange = { min = 30, max = 40 }, rec = 35,
	faction = nil, continent = "Kalimdor",
	overview = "A blasted waste of centaur warbands and the approach to Maraudon.",
})
Zone({
	name = "Stranglethorn Vale", uiMapID = 50, levelRange = { min = 30, max = 45 }, rec = 37,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Dense jungle of trolls, raptors and pirates -- and Booty Bay at its tip.",
})
Zone({
	name = "Badlands", uiMapID = 15, levelRange = { min = 35, max = 45 }, rec = 40,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Cracked red desert above Uldaman, crawling with Dark Iron and dragonkin.",
})
Zone({
	name = "Swamp of Sorrows", uiMapID = 51, levelRange = { min = 35, max = 45 }, rec = 40,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Fetid marsh around the Dark Portal and the Sunken Temple.",
})
Zone({
	name = "Dustwallow Marsh", uiMapID = 70, levelRange = { min = 35, max = 45 }, rec = 40,
	faction = nil, continent = "Kalimdor",
	overview = "Humid mire holding Theramore, Onyxia's lair and a dragonkin coast.",
})

-- High level ------------------------------------------------------------------

Zone({
	name = "The Hinterlands", uiMapID = 26, levelRange = { min = 40, max = 50 }, rec = 45,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Forested highland of Wildhammer dwarves and Vilebranch trolls.",
})
Zone({
	name = "Tanaris", uiMapID = 71, levelRange = { min = 40, max = 50 }, rec = 45,
	faction = nil, continent = "Kalimdor",
	overview = "Desert coast of Gadgetzan, the Caverns of Time and Zul'Farrak.",
})
Zone({
	name = "Feralas", uiMapID = 69, levelRange = { min = 40, max = 50 }, rec = 45,
	faction = nil, continent = "Kalimdor",
	overview = "Humid jungle of yetis and ogres, and the way into Dire Maul.",
})
Zone({
	name = "Searing Gorge", uiMapID = 32, levelRange = { min = 43, max = 50 }, rec = 47,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Smouldering Dark Iron strip-mine on the flank of Blackrock Mountain.",
})
Zone({
	name = "Blasted Lands", uiMapID = 17, levelRange = { min = 45, max = 55 }, rec = 50,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Scorched no-man's-land around the Dark Portal.",
})
Zone({
	name = "Azshara", uiMapID = 76, levelRange = { min = 45, max = 55 }, rec = 50,
	faction = nil, continent = "Kalimdor",
	overview = "Ruined highborne coastline patrolled by naga and blue dragonkin.",
})
Zone({
	name = "Un'Goro Crater", uiMapID = 78, levelRange = { min = 48, max = 55 }, rec = 52,
	faction = nil, continent = "Kalimdor",
	overview = "A primordial crater of dinosaurs, elementals and crystal hunting.",
})
Zone({
	name = "Felwood", uiMapID = 77, levelRange = { min = 48, max = 55 }, rec = 52,
	faction = nil, continent = "Kalimdor",
	overview = "Corrupted forest of satyrs and felbeasts between Ashenvale and Winterspring.",
})
Zone({
	name = "Burning Steppes", uiMapID = 46, levelRange = { min = 50, max = 58 }, rec = 54,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "Volcanic approach to Blackrock Mountain, held by the Blackrock orcs.",
})
Zone({
	name = "Western Plaguelands", uiMapID = 22, levelRange = { min = 51, max = 58 }, rec = 55,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "The Scourge's first conquest, and the road to Scholomance.",
})
Zone({
	name = "Eastern Plaguelands", uiMapID = 23, levelRange = { min = 53, max = 60 }, rec = 57,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "The Scourge heartland, with Stratholme and Naxxramas looming above.",
})
Zone({
	name = "Winterspring", uiMapID = 83, levelRange = { min = 55, max = 60 }, rec = 58,
	faction = nil, continent = "Kalimdor",
	overview = "Frozen pine forest of frostsabers, yetis and the neutral hub Everlook.",
})
Zone({
	name = "Silithus", uiMapID = 81, levelRange = { min = 55, max = 60 }, rec = 58,
	faction = nil, continent = "Kalimdor",
	overview = "Silithid-infested desert guarding the gates of Ahn'Qiraj.",
})
