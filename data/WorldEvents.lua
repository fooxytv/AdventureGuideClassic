--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
World events (holidays and the Darkmoon Faire) for Suggested Content.

There is deliberately NO calendar API here. C_Calendar shipped with 3.0 and is absent
on Era and BCC, so this table is the single source of truth and behaves identically on
both clients. WorldEventService only answers "what is live on this date?" against it.

The cost is that dates are maintained by hand. Two kinds of entry:

	rule = "fixedDate"           starts/ends as { month, day }, repeating annually.
	                             Ranges may wrap the year end (Winter Veil).
	rule = "firstMondayOfMonth"  starts on the first Monday, runs `duration` days,
	                             rotating through `locations` month by month.

Fields:
	expansion   "tbc" restricts the event to a BCC client; nil means both
	locations   where to go; a location may itself be "tbc"-only
	note        shown in the card tooltip; say so when the real dates shift

ANNUAL MAINTENANCE: the entries flagged `shifts = true` move every year (they track
the lunar new year or Easter, or Blizzard simply reschedules them). Check them against
the in-game calendar each year and correct the dates here.
]]

local function Event(event)
	WorldEventService.AddEvent(event)
end

-- Monthly ---------------------------------------------------------------------

Event({
	id = "darkmoon",
	name = "Darkmoon Faire",
	rule = "firstMondayOfMonth",
	duration = 7,
	-- The Faire alternates between Elwynn Forest and Mulgore, and adds Terokkar
	-- Forest on Burning Crusade. rotationOffset shifts which location comes up in a
	-- given month -- if the addon names the wrong one, adjust it by 1 and re-check.
	rotationOffset = 0,
	locations = {
		{ name = "Elwynn Forest" },
		{ name = "Mulgore" },
		{ name = "Terokkar Forest", expansion = "tbc" },
	},
	summary = "Turn in Darkmoon cards and quest tokens for reputation and trinkets, " ..
		"and play the carnival games.",
	note = "Starts the first Monday of each month.",
})

-- Annual ----------------------------------------------------------------------

Event({
	id = "lunarfestival",
	name = "Lunar Festival",
	rule = "fixedDate",
	starts = { month = 1, day = 28 },
	ends = { month = 2, day = 11 },
	shifts = true,
	locations = {
		{ name = "Moonglade" },
	},
	summary = "Collect Coins of Ancestry from elders across the world and trade them " ..
		"for festival gear in Moonglade.",
	note = "Dates track the lunar new year and move each year.",
})

Event({
	id = "loveisintheair",
	name = "Love is in the Air",
	rule = "fixedDate",
	starts = { month = 2, day = 11 },
	ends = { month = 2, day = 15 },
	locations = {
		{ name = "Capital cities" },
	},
	summary = "Hand out perfume and cologne in the capitals for tokens and the " ..
		"chance at a Truesilver Shafted Arrow.",
})

Event({
	id = "noblegarden",
	name = "Noblegarden",
	rule = "fixedDate",
	starts = { month = 4, day = 5 },
	ends = { month = 4, day = 11 },
	shifts = true,
	locations = {
		{ name = "Starting zone villages" },
	},
	summary = "Hunt Brightly Coloured Eggs around the starting villages for chocolate, " ..
		"clothing and pets.",
	note = "Dates track Easter and move each year.",
})

Event({
	id = "childrensweek",
	name = "Children's Week",
	rule = "fixedDate",
	starts = { month = 5, day = 1 },
	ends = { month = 5, day = 7 },
	locations = {
		{ name = "Stormwind, Orgrimmar" },
	},
	summary = "Escort an orphan around the world for a week to earn a non-combat pet.",
})

Event({
	id = "midsummer",
	name = "Midsummer Fire Festival",
	rule = "fixedDate",
	starts = { month = 6, day = 21 },
	ends = { month = 7, day = 5 },
	locations = {
		{ name = "Bonfires worldwide" },
	},
	summary = "Honour your faction's bonfires and desecrate the enemy's for Burning " ..
		"Blossoms and festival gear.",
})

Event({
	id = "harvestfestival",
	name = "Harvest Festival",
	rule = "fixedDate",
	starts = { month = 9, day = 19 },
	ends = { month = 9, day = 25 },
	shifts = true,
	locations = {
		{ name = "Capital cities" },
	},
	summary = "Honour the fallen heroes of Azeroth and collect the Bounty of the Harvest.",
})

Event({
	id = "brewfest",
	name = "Brewfest",
	rule = "fixedDate",
	starts = { month = 9, day = 20 },
	ends = { month = 10, day = 6 },
	-- Brewfest arrived in patch 2.3, so it does not exist on a Classic Era client.
	expansion = "tbc",
	locations = {
		{ name = "Durotar" },
		{ name = "Dun Morogh" },
	},
	summary = "Drink, ram-race and fight Coren Direbrew for brewery gear and steins.",
})

Event({
	id = "hallowsend",
	name = "Hallow's End",
	rule = "fixedDate",
	starts = { month = 10, day = 18 },
	ends = { month = 11, day = 1 },
	locations = {
		{ name = "Capital cities" },
	},
	summary = "Trick-or-treat the innkeepers, douse Wickerman fires and chase the " ..
		"Headless Horseman.",
})

Event({
	id = "winterveil",
	name = "Feast of Winter Veil",
	rule = "fixedDate",
	starts = { month = 12, day = 15 },
	ends = { month = 1, day = 2 },
	locations = {
		{ name = "Ironforge, Orgrimmar" },
	},
	summary = "Open presents under the tree, brew Winter Veil cheer and hunt the " ..
		"Abominable Greench.",
	note = "Runs across the new year.",
})
