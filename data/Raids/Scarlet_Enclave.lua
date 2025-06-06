--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Scarlet Enclave",
	instanceID = 227,
	thumbnail = I.UIEJDungeonButtonScarletEnclave,
	icon = 527422,
	splash = 608253,
	mapID = 48,
	season = true,
	overview = "",
	{
		name = "Balnazzar",
		defeated = 0,
		encounterID = 4887,
		portrait = 607551,
		instance = "Scarlet Enclave",
		loot = {{ id = 239722, seasonFilter = "exclusive" }, { id = 239719, seasonFilter = "exclusive" }, { id = 239759, seasonFilter = "exclusive" }, { id = 240922, seasonFilter = "exclusive" }, { id = 241018, seasonFilter = "exclusive" }, { id = 241017, seasonFilter = "exclusive" }, { id = 241171, seasonFilter = "exclusive" }, { id = 241176, seasonFilter = "exclusive" }, { id = 241184, seasonFilter = "exclusive" }, { id = 241152, seasonFilter = "exclusive" }, { id = 241179, seasonFilter = "exclusive" }, { id = 241028, seasonFilter = "exclusive" }, { id = 242365, seasonFilter = "exclusive" }, { id = 240839, seasonFilter = "exclusive" }, { id = 241157, seasonFilter = "exclusive" }, { id = 241178, seasonFilter = "exclusive" }}
,		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "High Commander Beatrix",
		defeated = 0,
		encounterID = 4837,
		portrait = I.UIEJBossBeatrix,
		loot = {{ }},
		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "Solistrasza",
		defeated = 0,
		encounterID = 6243,
		portrait = I.UIEJBossSolistrasza,
		loot = {{ }}
,		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "Alexei the Beastlord",
		defeated = 0,
		encounterID = 12876,
		portrait = I.UIEJBossAlexeiTheBeastlord,
		loot = {{ }}
,		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "Mason the Echo",
		defeated = 0,
		encounterID = 4832,
		portrait = I.UIEJBossMasonTheEcho,
		loot = {{ }},
		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "Reborn Council",
		encounterID = 4830,
		portrait = I.UIEJBossRebornCouncil,
		loot = {{ }}
,		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "Lillian Voss",
		encounterID = 4830,
		portrait = I.UIEJBossLillanVoss,
		loot = {{ }}
,		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
		name = "Grand Crusader Caldoran",
		encounterID = 4830,
		portrait = I.UIEJBossGrandCrusaderCaldoran,
		loot = {{ }}
,		sharedLoot = {{ }},
		rareLoot = {{ }},
		veryRareLoot = {{ }},
		extremelyRareLoot = {{ }},
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
