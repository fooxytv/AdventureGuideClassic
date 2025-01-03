--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Zul'Farrak",
	instanceID = 241,
	thumbnail = 608230,
	icon = 136368,
	splash = 608267,
	mapID = 209,
	season = false,
	overview = "Zul'Farrak was once the shining jewel of Tanaris, ferociously protected by the cunning Sandfury tribe. Despite the trolls' tenacity, this isolated group was forced to surrender much of its territory throughout history. Now, it appears that Zul'Farrak's inhabitants are creating a horrific army of undead trolls to conquer the surrounding region. Other disturbing rumors tell of an ancient creature sleeping within the city--one that, if awakened, will rain death and destruction across Tanaris.",
	{
		name = "Antu'sul",
		defeated = 0,
		encounterID = 8127,
		portrait = 607541,
		loot = { 9641, 9379, 9639, 9640 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Antu'sul is a powerful sand troll and a guardian of Zul'Farrak, a vast troll city in the Tanaris Desert. His role within the city is tied to the preservation of its ancient secrets and the protection of its inhabitants. Antu'sul's formidable presence and mastery over earth magic make him a significant figure in the troll hierarchy.",
			{ heading = "Overview" },
			"Antu'sul casts healing spells which need to be interrupted, totems and adds need to be focused.",
			{
				role = DAMAGE,
				"Utilise AOE abilities to damage the adds that are summoned at the beginning of the fight and also near the end of the fight.",
				"Focus damage on the adds when they spawn, and then return to damaging Antu'sul.",
				"Interrupt {spell:11895} and {spell:11899}.",
				"Priorize killing totems whenever they spawn - {spell:11899} and {spell:8376}."
			},
			{
				role = HEALER,
				"Healing can be intense, be prepared to use cooldowns.",
				"Look out for damage from totems - {spell:11899} and {spell:8376}, lightning or the Basilisk adds."
			},
			{
				role = TANK,
				"Tank Antu'sul out of the cave using a ranged ability and bring back to the group outside the cave.",
				"Maintain threat on the Basilisk adds that spawn during the fight.",
				"Interrupt {spell:11895} and {spell:11899}."
			}
		},
		abilities = {
		}
	},
	{
		name = "Theka the Martyr",
		defeated = 0,
		encounterID = 7272,
		portrait = 607793,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Theka the Martyr is a revered figure among the sand trolls of Zul'Farrak. His devotion to the ancient rituals and traditions of his people has earned him a special place within the city. Theka's resilience and his mastery of protective magic make him a central figure in the troll hierarchy.",
			{ heading = "Overview" },
			"Theka the Martyr will cast {spell:8600} which needs to be dispelled. He will also cast {spell:11089} at 30% health, which will make him immune to shadow or physical damage for 30 seconds.",
			{
				role = DAMAGE,
				"Focus damage on Theka the Martyr, and dispel {spell:8600} if possible.",
				"Theka the Martyr will cast {spell:11089} at 30% health, which will make him immune to shadow or physical damage for 30 seconds.",
			},
			{
				role = HEALER,
				"Focus healing on the tank, this will be a quick fight.",
				"Dispel {spell:8600} if possible",
			},
			{
				role = TANK,
				"Maintain threat on Theka the Martyr so the damage dealers can focus on him.",
				"Stunning Theka the Martyr at 30% health will prevent him from casting {spell:11089}."
			}
		},
		abilities = {
		}
	},
	{
		name = "Witch Doctor Zum'rah",
		defeated = 0,
		encounterID = 7271,
		portrait = 607819,
		loot = { 18083, 18082 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Witch Doctor Zum'rah is a cunning practitioner of dark voodoo magic within Zul'Farrak. His role within the city is to invoke the power of the loa and provide spiritual guidance to the sand troll community. Zum'rah's mystical abilities and connection to the spirit world make him a prominent figure in the troll hierarchy.",
			{ heading = "Overview" },
			"Witch Doctor Zum'rah will cast {spell:12739} which needs to be interrupted. He will also summon Zombie adds which need to be focused down.",
			{
				role = DAMAGE,
				"Coordinate interrupts to make sure Zum'rah does not cast {spell:12739} so many times.",
				"Focus damage on totem whenever they spawn.",
				"Priorize Zombie adds when they spawn."
			},
			{
				role = HEALER,
				"Position yourself to avoid exposure to the adds, when they spawn.",
				"This can be a long fight, be prepared to conserve mana."
			},
			{
				role = TANK,
				"Maintain threat on Witch Doctor Zum'rah and face him away from the group.",
				"Interrupt {spell:12739} whenever possible."
			}
		},
		abilities = {
		}
	},
	-- {
	-- 	name = "Nekrum Gutchewer",
	-- 	defeated = 0,
	-- 	encounterID = 7796,
	-- 	portrait = 607723,
	-- 	loot = { },
	-- 	npcs = { 2135, 12456, 12314 },
	-- 	overview = {
	-- 		"Nekrum Gutchewer is a ruthless troll warrior who serves as a protector of Zul'Farrak. His role within the city involves defending it from intruders and maintaining its security. Nekrum's combat prowess and unyielding dedication make him a formidable enforcer in the troll hierarchy.",
	-- 		{ heading = "Overview" },
	-- 		"information goes here..",
	-- 		{
	-- 			role = DAMAGE,
	-- 			"",
	-- 		},
	-- 		{
	-- 			role = HEALER,
	-- 			"",
	-- 		},
	-- 		{
	-- 			role = TANK,
	-- 			"",
	-- 		}
	-- 	},
	-- 	abilities = {
	-- 	}
	-- },
	{
		name = "Shadowpriest Sezz'ziz",
		defeated = 0,
		encounterID = 7275,
		portrait = 607770,
		loot = { 9470, 9475, 9474, 9473 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Shadowpriest Sezz'ziz is a malevolent troll who has delved into the darker aspects of voodoo magic within Zul'Farrak. His role within the city involves wielding shadowy powers and maintaining control over sinister forces. Sezz'ziz's mastery of dark magic and his malevolent nature make him a feared figure in the troll hierarchy.",
			{ heading = "Overview" },
			"Shadowpriest Sezz'ziz will cast {spell:13704} which needs to be interrupted. He will also cast {spell:12039} which needs to be interrupted by melee.",
			{
				role = DAMAGE,
				"Damage dealers should focus on Nekrum Gutchewer first, then Shadowpriest Sezz'ziz.",
				"Assign melee to interrupt {spell:12039} which Shadowpriest Sezz'ziz will cast on Nekrum Gutchewer.",
			},
			{
				role = HEALER,
				"Position yourself to be maximum range from Shadowpriest Sezz'ziz to avoid {spell:13704}.",
			},
			{
				role = TANK,
				"Engage both Nekrum Gutchewer and Shadowpriest Sezz'ziz at the top of the stairs",
				"Establish threat on Nekrum Gutchewer first, then damage dealers can focus on him, then switch to Shadowpriest Sezz'ziz."
			}
		},
		abilities = {
		}
	},
	{
		name = "Sergeant Bly",
		defeated = 0,
		encounterID = 7604,
		portrait = I.UIEJBossSergeantBly,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Sergeant Bly is a battle-hardened troll warrior who has risen through the ranks within Zul'Farrak. His role involves training and leading the troll forces in defense of the city. Bly's combat expertise and unwavering loyalty to his people make him a crucial figure in the troll hierarchy.",
			{ heading = "Overview" },
			"Focus Murta Grimgut first, then Oro Eyegouge, Raven and finally Sergeant Bly.",
			{
				role = DAMAGE,
				"Focus on Murta Grimgut first, as she's the healer.",
				"After Murta Grimgut is down, focus on Oro Eyegouge the caster, then Raven and finally Sergeant Bly.",
			},
			{
				role = HEALER,
				"Keep heals on all of the party members.",
				"There will be more partywide damage initially, so be prepared to use cooldowns.",
			},
			{
				role = TANK,
				"Maintain threat on all of the adds if possible, let the damage dealers focus on Murta Grimgut.",
				"Save Sergeant Bly for last"
			}
		},
		abilities = {
		}
	},
	{
		name = "Hydromancer Velratha",
		defeated = 0,
		encounterID = 7795,
		portrait = 607652,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Hydromancer Velratha is a master of water and frost magic among the sand trolls of Zul'Farrak. Her role within the city involves harnessing the power of water and maintaining control over its elemental forces. Velratha's mastery of elemental magic and her connection to the waters make her a significant figure in the troll hierarchy.",
			{ heading = "Overview" },
			"Hydromancer Velratha will summon totems which need to be focused down. She will also cast {spell:12739}, {spell:15245} and {spell:12491} which need to be interrupted.",
			{
				role = DAMAGE,
				"Be careful of pulling Hydromancer Velratha with adds at the same time.",
				"Focus down totems - {spell:11086} that Hydromancer Velratha summons and interrupt {spell:12739}, {spell:15245} and {spell:12491} whenever possible.",
			},
			{
				role = HEALER,
				"Focus healing on the tank, if adds are pulled, be prepared to use cooldowns.",
			},
			{
				role = TANK,
				"Make sure to clear the area around Hydromancer Velratha before engaging her. This will make the encounter easier.",
				"Interrupt {spell:12739}, {spell:15245} and {spell:12491} whenever possible."
			}
		},
		abilities = {
		}
	},
	{
		name = "Chief Ukorz Sandscalp",
		defeated = 0,
		encounterID = 7267,
		portrait = 607564,
		loot = { 9476, 9479, 11086, 9478, 9477 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Chief Ukorz Sandscalp is the formidable leader of the sand trolls within Zul'Farrak. His role involves overseeing the city's operations and ensuring the welfare of his people. Ukorz's strength, wisdom, and unwavering dedication make him the highest authority in the troll hierarchy.",
			{ heading = "Overview" },
			"Face Chief Ukorz Sandscalp and Ruuzlu away from the group to avoid {spell:15496}. Focus down Ruuzlu first, then Chief Ukorz Sandscalp.",
			{
				role = DAMAGE,
				"Focus down Ruuzlu first, then Chief Ukorz Sandscalp.",
				"Avoid being in front of both Ruuzlu and Chief Ukorz Sandscalp to avoid {spell:15496}.",
				"Range damage dealers should stand away from Chief Ukorz Sandscalp and focus Ruuzlu then Chief Ukorz Sandscalp."
			},
			{
				role = HEALER,
				"Stay out of melee range to avoid {spell:15496} and focus your healing on the tank.",
			},
			{
				role = TANK,
				"Tank Cheif Ukorz Sandscalp and Ruuzlu together, facing them away from the group to prevent the group being hit by {spell:15496}.",
				"Establish threat on Ruuzlu first so the damage dealers can focus on him, then switch to Chief Ukorz Sandscalp."
			}
		},
		abilities = {
		}
	},
	-- {
	-- 	name = "Ruuzlu",
	-- 	defeated = 0,
	-- 	encounterID = 7797,
	-- 	portrait = 607762,
	-- 	loot = { },
	-- 	npcs = { 2135, 12456, 12314 },
	-- 	overview = {
	-- 		"Ruuzlu is a menacing basilisk that dwells within the depths of Zul'Farrak. His presence in the city represents the diverse array of creatures that have found refuge in its labyrinthine passages. Ruuzlu's petrifying gaze and stone-shattering attacks make him a formidable inhabitant of this underground realm.",
	-- 		{ heading = "Overview" },
	-- 		"information goes here..",
	-- 		{
	-- 			role = DAMAGE,
	-- 			"",
	-- 		},
	-- 		{
	-- 			role = HEALER,
	-- 			"",
	-- 		},
	-- 		{
	-- 			role = TANK,
	-- 			"",
	-- 		}
	-- 	},
	-- 	abilities = {
	-- 	}
	-- },
})
