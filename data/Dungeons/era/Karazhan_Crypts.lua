--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Karazhan Crypts",
	instanceID = 227,
	thumbnail = I.UIEJDungeonButtonKarazhanCrypts,
	icon = 527422,
	splash = 527422,
	mapID = 48,
	seasonFilter = "exclusive",
	overview = "",
	{
		name = "The Failed Apprentices",
		defeated = 0,
		encounterID = 4887,
		portrait = 521744, -- default portrait
		instance = "Karazhan Crypts",
		loot = {
			{ id = 236707, seasonFilter = "exclusive" },
			{ id = 236727, seasonFilter = "exclusive" },
			{ id = 236730, seasonFilter = "exclusive" },
			{ id = 237011, seasonFilter = "exclusive" },
			{ id = 235886, seasonFilter = "exclusive" },
			{ id = 235880, seasonFilter = "exclusive" },
			{ id = 235894, seasonFilter = "exclusive" },
			{ id = 235873, seasonFilter = "exclusive" },
			{ id = 235879, seasonFilter = "exclusive" },
			{ id = 236782, seasonFilter = "exclusive" },
			{ id = 235887, seasonFilter = "exclusive" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { },
		overview = {
			"Overview of the boss encounter.",
			{ heading = "Overview" },
			"General overview of tactics.",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			},
		},
		abilities = {
		},
	},
	{
		name = "Opera Boss",
		defeated = 0,
		encounterID = 4837,
		portrait = 521744,
		loot = {
			{ id = 235883, seasonFilter = "exclusive" },
			{ id = 235878, seasonFilter = "exclusive" },
			{ id = 235893, seasonFilter = "exclusive" },
		},
		sharedLoot = {
			{ id = 235889, seasonFilter = "exclusive" },
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { },
		overview = {
			"Overview of the boss encounter.",
			{ heading = "Overview" },
			"General overview of tactics.",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			},
		},
		abilities = {
		},
	},
	{
		name = "Creeping Malison",
		defeated = 0,
		encounterID = 6243,
		portrait = 521744,
		loot = {
			{ id = 235893, seasonFilter = "exclusive" },
			{ id = 235888, seasonFilter = "exclusive" },
			{ id = 235885, seasonFilter = "exclusive" },
			{ id = 235884, seasonFilter = "exclusive" },
			{ id = 235881, seasonFilter = "exclusive" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { },
		overview = {
			"Overview of the boss encounter.",
			{ heading = "Overview" },
			"General overview of tactics.",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			},
		},
		abilities = {
		}
	},
	{
		name = "Harbinger of Sin",
		defeated = 0,
		encounterID = 12876,
		portrait = 521744,
		loot = {
			{ id = 235881, seasonFilter = "exclusive" },
			{ id = 235891, seasonFilter = "exclusive" },
			{ id = 235890, seasonFilter = "exclusive" },
			{ id = 235869, seasonFilter = "exclusive" },
			{ id = 235882, seasonFilter = "exclusive" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { },
		overview = {
			"Overview of the boss encounter.",
			{ heading = "Overview" },
			"General overview of tactics.",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			},
		},
		abilities = {
		}
	},
	{
		name = "Kharon",
		defeated = 0,
		encounterID = 4832,
		portrait = 521744,
		loot = {
			{ id = 235875, seasonFilter = "exclusive" },
			{ id = 235874, seasonFilter = "exclusive" },
			{ id = 235877, seasonFilter = "exclusive" },
			{ id = 236645, seasonFilter = "exclusive" },
			{ id = 235876, seasonFilter = "exclusive" },
			{ id = 236642, seasonFilter = "exclusive"},
			{ id = 236643, seasonFilter = "exclusive" },
			{ id = 236644, seasonFilter = "exclusive" },
			{ id = 235878, seasonFilter = "exclusive" },
			{ id = 235870, seasonFilter = "exclusive" },
			{ id = 235893, seasonFilter = "exclusive" },
			{ id = 235883, seasonFilter = "exclusive" },
			{ id = 235889, seasonFilter = "exclusive" },
		},
		sharedLoot = {
			{ id = 235881, seasonFilter = "exclusive" },
			{ id = 235880, seasonFilter = "exclusive" },
			{ id = 235879, seasonFilter = "exclusive" },
			{ id = 235872, seasonFilter = "exclusive" },
			{ id = 235869, seasonFilter = "exclusive" },
			{ id = 235871, seasonFilter = "exclusive" },
			{ id = 235887, seasonFilter = "exclusive" },
			{ id = 235882, seasonFilter = "exclusive" },
			{ id = 235885, seasonFilter = "exclusive" },
			{ id = 235868, seasonFilter = "exclusive" },
			{ id = 235892, seasonFilter = "exclusive" },
			{ id = 235886, seasonFilter = "exclusive" },
			{ id = 235891, seasonFilter = "exclusive" },
			{ id = 235888, seasonFilter = "exclusive" },
			{ id = 235894, seasonFilter = "exclusive" },
			{ id = 235890, seasonFilter = "exclusive" },
			{ id = 235884, seasonFilter = "exclusive" },
			{ id = 236782, seasonFilter = "exclusive" },
			{ id = 235873, seasonFilter = "exclusive" },
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { },
		overview = {
			"Overview of the boss encounter.",
			{ heading = "Overview" },
			"General overview of tactics.",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			},
		},
		abilities = {
		}
	},
	{
		name = "Dark Rider",
		encounterID = 4830,
		portrait = 521744,
		loot = {
			{ id = 235892, seasonFilter = "exclusive" },
			{ id = 235868, seasonFilter = "exclusive" },
			{ id = 235871, seasonFilter = "exclusive" },
			{ id = 235872, seasonFilter = "exclusive" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { },
		overview = {
			"Overview of the boss encounter.",
			{ heading = "Overview" },
			"General overview of tactics.",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			},
		},
		abilities = {
		}
	}
})
