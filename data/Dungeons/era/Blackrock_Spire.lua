--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Blackrock Spire",
	instanceID = 229,
	thumbnail = 608197,
	icon = 136327,
	splash = 608236,
	mapID = 229,
	seasonFilter = "all",
	overview = "This imposing fortress, carved into the fiery core of Blackrock Mountain, represented the might of the Dark Iron clan for centuries. More recently, the black dragon Nefarian and his spawn seized the keep's upper spire and ignited a brutal war against the dwarves. The draconic armies have since allied with Warchief Rend Blackhand and his false Horde. This combined force lords over the spire, conducting horrific experiments to bolster its ranks while plotting the meddlesome Dark Irons' downfall.",
		{
			name = "Highlord Omokk",
			defeated = 0,
			encounterID = 9196,
			portrait = 607645,
			loot = {
				{ id = 16670, seasonFilter = "all" },
				{ id = 13167, seasonFilter = "all" },
				{ id = 13170, seasonFilter = "all" },
				{ id = 13166, seasonFilter = "all" },
				{ id = 13169, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 9196 },
			overview = {
				"Highlord Omokk, a formidable ogre leader in Lower Blackrock Spire, is known for his brutal rule.",
				{ heading = "Overview" },
				"Omokk is joined by two adds. Control the adds with crowd control, then focus on Omokk. Damage dealers should let the tank establish threat. Healers keep a close eye on the tank, especially during Omokk's {spell:18945}. Tanks position Omokk away from the group to minimize damage from his abilities.",
				{
					role = DAMAGE,
					"Control adds with crowd control, then focus on Omokk. Avoid pulling aggro."
				},
				{
					role = HEALER,
					"Pay attention to the tank's health during Omokk's heavy hits. Be ready for burst healing."
				},
				{
					role = TANK,
					"Position Omokk away from the group, control adds, and manage {spell:18945} effects."
				}
			},
			abilities = {
			}
		},
		{
			name = "Shadow Hunter Vosh'gajin",
			defeated = 0,
			encounterID = 9236,
			portrait = 607769,
			loot = {
				{ id = 12651, seasonFilter = "all" },
				{ id = 13257, seasonFilter = "all" },
				{ id = 12626, seasonFilter = "all" },
				{ id = 12653, seasonFilter = "all" },
				{ id = 16712, seasonFilter = "all" },
				{ id = 13255, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 9236 },
			overview = {
				"Shadow Hunter Vosh'gajin, a troll shadow hunter in Lower Blackrock Spire, is a master of dark magic.",
				{ heading = "Overview" },
				"Accompanied by two adds, control them and focus on Vosh'gajin. Damage dealers use crowd control and prioritize decursing. Healers manage healing and decurse. Tanks pull Vosh'gajin away and handle adds after crowd control breaks.",
				{
					role = DAMAGE,
					"Control adds with crowd control. Decurse {spell:8282} and manage {spell:22566}."
				},
				{
					role = HEALER,
					"Heal through the fight, especially when crowd control breaks. Decurse {spell:8282}."
				},
				{
					role = TANK,
					"Pull Vosh'gajin away, manage adds after crowd control, and focus on the boss."
				}
			},
			abilities = {
			}
		},
		{
			name = "War Master Voone",
			defeated = 0,
			encounterID = 9237,
			portrait = 607810,
			loot = {
				{ id = 16676, seasonFilter = "all" },
				{ id = 13179, seasonFilter = "all" },
				{ id = 12582, seasonFilter = "all" },
				{ id = 13177, seasonFilter = "all" },
				{ id = 13175, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 9237 },
			overview = {
				"War Master Voone, a powerful orc commander in Lower Blackrock Spire, is known for his strength.",
				{ heading = "Overview" },
				"Voone hits hard but has no adds. Damage dealers should let the tank initiate and maintain threat. Healers focus on the tank. Tanks manage Voone's hard hits and avoid letting DPS pull aggro.",
				{
					role = DAMAGE,
					"Let the tank establish threat. Avoid standing in front of Voone due to {spell:5532}."
				},
				{
					role = HEALER,
					"Focus on keeping the tank healed through Voone's heavy hits."
				},
				{
					role = TANK,
					"Engage Voone, control his positioning, and use defensive cooldowns for heavy hits."
				}
			},
			abilities = {
			}
		},
		{
			name = "Mother Smolderweb",
			defeated = 0,
			encounterID = 10596,
			portrait = 607719,
			loot = {
				{ id = 13244, seasonFilter = "all" },
				{ id = 13213, seasonFilter = "all" },
				{ id = 13183, seasonFilter = "all" },
				{ id = 16715, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10596 },
			overview = {
				"Mother Smolderweb, a massive spider in Lower Blackrock Spire, is known for her stunning abilities.",
				{ heading = "Overview" },
				"Smolderweb is joined by Worg pups. Focus on the pups, then Smolderweb. Damage dealers should avoid Smolderweb's stuns. Healers increase output during stuns. Tanks manage aggro and face Smolderweb away from the group.",
				{
					role = DAMAGE,
					"Eliminate Worg pups, then focus on Smolderweb. Stay behind to avoid stuns."
				},
				{
					role = HEALER,
					"Heal through the stuns, focusing on the tank and affected party members."
				},
				{
					role = TANK,
					"Control Worg pups, then focus on Smolderweb. Position away from the group."
				}
			},
			abilities = {
			}
		},
		{
			name = "Urok Doomhowl",
			defeated = 0,
			encounterID = 10584,
			portrait = 607801,
			loot = {
				{ id = 13178, seasonFilter = "all" },
				{ id = 22232, seasonFilter = "all" },
				{ id = 13259, seasonFilter = "all" },
				{ id = 13258, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10584 },
			overview = {
				"Urok Doomhowl, a summoned boss in Lower Blackrock Spire, commands the Scarshield Legion.",
				{ heading = "Overview" },
				"Summoned using Ommokk's Head. Manage waves of ogres and focus on Urok once he appears. Damage dealers use crowd control on ogres. Healers keep everyone healed, especially when crowd control breaks. Tanks manage adds and focus on Urok when he appears.",
				{
					role = DAMAGE,
					"Use crowd control on ogres. Focus on Urok once he appears. Manage {spell:16508}."
				},
				{
					role = HEALER,
					"Heal through the ogre waves. Focus on the tank when Urok appears."
				},
				{
					role = TANK,
					"Control ogres with crowd control. Engage Urok and manage his hard hits."
				}
			},
			abilities = {
			}
		},
		{
			name = "Quartermaster Zigris",
			defeated = 0,
			encounterID = 9736,
			portrait = 607751,
			loot = {
				{ id = 13252, seasonFilter = "all" },
				{ id = 13253, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 9736 },
			overview = {
				"Quartermaster Zigris, an orc quartermaster in Lower Blackrock Spire, oversees logistics.",
				{ heading = "Overview" },
				"Zigris is a straightforward encounter. Damage dealers focus on him and spread out. Healers concentrate on the tank. Tanks maintain threat and spread out to manage {spell:16497}.",
				{
					role = DAMAGE,
					"Focus on Zigris and spread to avoid {spell:16497}."
				},
				{
					role = HEALER,
					"Focus on tank and spread to avoid {spell:16497}."
				},
				{
					role = TANK,
					"Maintain threat and spread to avoid {spell:16497}."
				}
			},
			abilities = {
			}
		},
		{
			name = "Halycon",
			defeated = 0,
			encounterID = 10220,
			portrait = 607634,
			loot = {
				{ id = 22313, seasonFilter = "all" },
				{ id = 13212, seasonFilter = "all" },
				{ id = 13210, seasonFilter = "all" },
				{ id = 13211, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10220 },
			overview = {
				"Halycon, a giant Worg in Upper Blackrock Spire, is accompanied by Worg pups.",
				{ heading = "Overview" },
				"Focus on Worg pups, then Halycon. Damage dealers handle pups first. Healers use HoT effects and shields at the start. Tanks pull Halycon away and control threat.",
				{
					role = DAMAGE,
					"Eliminate Worg pups, then focus on Halycon. Stay behind to avoid frontal attacks."
				},
				{
					role = HEALER,
					"Use heal over time spells and shields on the party at the start. Focus healing on the tank."
				},
				{
					role = TANK,
					"Control Worg pups, then focus on Halycon. Position away from the group."
				}
			},
			abilities = {
			}
		},
		{
			name = "Gizrul the Slavener",
			defeated = 0,
			encounterID = 10268,
			portrait = 607615,
			loot = {
				{ id = 13208, seasonFilter = "all" },
				{ id = 13205, seasonFilter = "all" },
				{ id = 16718, seasonFilter = "all" },
				{ id = 13206, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10268 },
			overview = {
				"Gizrul the Slavener, a Worg boss in Upper Blackrock Spire, follows after Halycon.",
				{ heading = "Overview" },
				"Prepare quickly before engaging Gizrul. Damage dealers focus on Gizrul. Healers manage Damage Over Time effects. Tanks control Gizrul and use cooldowns during enrage.",
				{
					role = DAMAGE,
					"Quickly engage Gizrul after Halycon. Focus on the boss."
				},
				{
					role = HEALER,
					"Manage Damage Over Time effects. Focus on the tank during enrage."
				},
				{
					role = TANK,
					"Control Gizrul. Use defensive cooldowns for {spell:8269} and {spell:16128}."
				}
			},
			abilities = {
			}
		},
		{
			name = "Overlord Wyrmthalak",
			defeated = 0,
			encounterID = 9568,
			portrait = 607737,
			loot = {
				{ id = 22321, seasonFilter = "all" },
				{ id = 16679, seasonFilter = "all" },
				{ id = 13148, seasonFilter = "all" },
				{ id = 13164, seasonFilter = "all" },
				{ id = 13162, seasonFilter = "all" },
				{ id = 13163, seasonFilter = "all" },
				{ id = 13161, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {
				{ id = 228585, seasonFilter = "exclusive" },
				{ id = 13143, seasonFilter = "restricted" }
			},
			extremelyRareLoot = {},
			npcs = { 9568 },
			overview = {
				"Overlord Wyrmthalak, a pivotal Blackrock orc leader in Upper Blackrock Spire.",
				{ heading = "Overview" },
				"Wyrmthalak summons adds at 50% health. Damage dealers control adds and focus on Wyrmthalak. Healers conserve mana and focus on the tank. Tanks position Wyrmthalak and manage adds.",
				{
					role = DAMAGE,
					"Control adds, focus on Wyrmthalak, then switch to adds. Stay behind the boss."
				},
				{
					role = HEALER,
					"Conserve mana, focus on the tank, and watch for add aggro."
				},
				{
					role = TANK,
					"Position Wyrmthalak, control adds at 50%, and maintain threat."
				}
			},
			abilities = {
			}
		},
		{
			name = "Pyroguard Emberseer",
			defeated = 0,
			encounterID = 9816,
			portrait = 607748,
			loot = {
				{ id = 12905, seasonFilter = "all" },
				{ id = 12926, seasonFilter = "all" },
				{ id = 12927, seasonFilter = "all" },
				{ id = 12929, seasonFilter = "all" },
				{ id = 16672, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 9816 },
			overview = {
				"Pyroguard Emberseer, a fire elemental in Upper Blackrock Spire, is the first boss.",
				{ heading = "Overview" },
				"Summon Emberseer by engaging adds. Damage dealers focus on adds, then Emberseer. Healers manage AoE damage. Tanks engage Emberseer and maintain threat.",
				{
					role = DAMAGE,
					"Eliminate adds, then focus on Emberseer. Stay at range to avoid AoE."
				},
				{
					role = HEALER,
					"Heal through AoE damage. Focus on the tank and affected party members."
				},
				{
					role = TANK,
					"Engage Emberseer, control positioning, and handle AoE effects."
				}
			},
			abilities = {
			}
		},
		{
			name = "Solakar Flamewreath",
			defeated = 0,
			encounterID = 9816,
			portrait = 607737,
			loot = {
				{ id = 12606, seasonFilter = "all" },
				{ id = 12589, seasonFilter = "all" },
				{ id = 12603, seasonFilter = "all" },
				{ id = 12609, seasonFilter = "all" },
				{ id = 16695, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10264 },
			overview = {
				"Solakar Flamewreath, a formidable spellcaster, guards the Father Flame in Upper Blackrock Spire.",
				{ heading = "Overview" },
				"Focus on adds then Solakar. Damage dealers eliminate adds and target Solakar, maintaining distance. Healers stay away from Solakar and keep the group healed. Tanks hold Solakar against the wall and manage adds.",
				{
					role = DAMAGE,
					"Eliminate adds first, then focus on Solakar. Maintain distance. Avoid {spell:20549}."
				},
				{
					role = HEALER,
					"Keep distance from Solakar, focus on group health. Avoid {spell:20549}."
				},
				{
					role = TANK,
					"Tank Solakar against the wall, manage adds. Watch for {spell:20549}."
				}
			},
			abilities = {
			}
		},
		{
			name = "Goraluk Anvilcrack",
			defeated = 0,
			encounterID = 10339,
			portrait = I.UIEJBossGoralukAnvilcrack,
			loot = {
				{ id = 13498, seasonFilter = "all" },
				{ id = 13502, seasonFilter = "all" },
				{ id = 18047, seasonFilter = "all" },
				{ id = 18048, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10899 },
			overview = {
				"Goraluk Anvilcrack, a key Blackrock orc in Upper Blackrock Spire, is an optional melee boss.",
				{ heading = "Overview" },
				"Damage dealers focus on Goraluk avoiding threat. Healers keep the tank healed especially when stunned. Tanks manage Goraluk's positioning and stuns/",
				{
					role = DAMAGE,
					"Focus on Goraluk, maintain threat discipline. Avoid over-aggroing."
				},
				{
					role = HEALER,
					"Heal the tank, especially during stuns. Watch for {spell:6253} on the tank."
				},
				{
					role = TANK,
					"Tank Goraluk away, manage stuns. Handle {spell:6253} with care."
				}
			},
			abilities = {
			}
		},
		{
			name = "Warchief Rend Blackhand",
			defeated = 0,
			encounterID = 10429,
			portrait = 607813,
			loot = {
				{ id = 22225, seasonFilter = "all" },
				{ id = 12952, seasonFilter = "all" },
				{ id = 12953, seasonFilter = "all" },
				{ id = 12960, seasonFilter = "all" },
				{ id = 16669, seasonFilter = "all" },
				{ id = 22247, seasonFilter = "all" },
				{ id = 12587, seasonFilter = "all" },
				{ id = 12935, seasonFilter = "all" },
				{ id = 18102, seasonFilter = "all" },
				{ id = 18103, seasonFilter = "all" },
				{ id = 12936, seasonFilter = "all" },
				{ id = 16733, seasonFilter = "all" },
				{ id = 18104, seasonFilter = "all" },
				{ id = 12583, seasonFilter = "all" },
				{ id = 12940, seasonFilter = "all" },
				{ id = 12939, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {
				{ id = 228757, seasonFilter = "exclusive" },
				{ id = 12590, seasonFilter = "restricted" }
			},
			extremelyRareLoot = {},
			npcs = { 10429, 10339 },
			overview = {
				"Warchief Rend Blackhand, a central figure in Upper Blackrock Spire, presents a complex encounter.",
				{ heading = "Overview" },
				"Manage adds, focus on Gyth, then Rend. Damage dealers prioritize adds, then Gyth, maintaining distance. Healers assign to tanks, handle raid healing. Tanks manage Gyth and Rend, coordinating with DPS.",
				{
					role = DAMAGE,
					"Handle adds, then focus on Gyth. Maintain distance from Rend. Avoid {spell:20667}, {spell:9573}."
				},
				{
					role = HEALER,
					"Assigned healing roles, manage raid damage. Stay distant from Rend's {spell:13736}, {spell:15588}."
				},
				{
					role = TANK,
					"Coordinate tanks for Gyth and Rend, manage positioning. Avoid Rend's {spell:13736}, {spell:15588}."
				}
			},
			abilities = {
			}
		},
		{
			name = "The Beast",
			defeated = 0,
			encounterID = 10430,
			portrait = 607786,
			loot = {
				{ id = 22311, seasonFilter = "all" },
				{ id = 12709, seasonFilter = "all" },
				{ id = 12963, seasonFilter = "all" },
				{ id = 12964, seasonFilter = "all" },
				{ id = 12965, seasonFilter = "all" },
				{ id = 12966, seasonFilter = "all" },
				{ id = 12967, seasonFilter = "all" },
				{ id = 12968, seasonFilter = "all" },
				{ id = 12969, seasonFilter = "all" },
				{ id = 16729, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {},
			extremelyRareLoot = {},
			npcs = { 10430 },
			overview = {
				"The Beast, a massive core hound in Upper Blackrock Spire, is a formidable challenge.",
				{ heading = "Overview" },
				"Clear adds, manage charge and AoE damage. Damage dealers maintain distance, handle charges. Healers focus on tanks, handle AoE damage. Tanks manage threat, positioning against a wall.",
				{
					role = DAMAGE,
					"Maintain distance, handle charges, focus on The Beast. Avoid {spell:5782}, {spell:16785}."
				},
				{
					role = HEALER,
					"Focus on tanks, manage AoE healing. Keep distance from {spell:5782}, {spell:16785}."
				},
				{
					role = TANK,
					"Manage threat, position against a wall. Control The Beast, avoid knockbacks from {spell:16785}."
				}
			},
			abilities = {
			}
		},
		{
			name = "General Drakkisath",
			defeated = 0,
			encounterID = 10363,
			portrait = 607612,
			loot = {
				{ id = 22267, seasonFilter = "all" },
				{ id = 22269, seasonFilter = "all" },
				{ id = 22268, seasonFilter = "all" },
				{ id = 22253, seasonFilter = "all" },
				{ id = 12602, seasonFilter = "all" },
				{ id = 13098, seasonFilter = "all" },
				{ id = 13141, seasonFilter = "all" },
				{ id = 13142, seasonFilter = "all" },
				{ id = 16666, seasonFilter = "all" },
				{ id = 16674, seasonFilter = "all" },
				{ id = 16688, seasonFilter = "all" },
				{ id = 16690, seasonFilter = "all" },
				{ id = 16700, seasonFilter = "all" },
				{ id = 16706, seasonFilter = "all" },
				{ id = 16721, seasonFilter = "all" },
				{ id = 16726, seasonFilter = "all" },
				{ id = 16730, seasonFilter = "all" }
			},
			sharedLoot = {},
			rareLoot = {},
			veryRareLoot = {
				{ id = 228606, seasonFilter = "exclusive" },
				{ id = 12592, seasonFilter = "restricted" }
			},
			extremelyRareLoot = {},
			npcs = { 10363 },
			overview = {
				"General Drakkisath, the final boss of Upper Blackrock Spire, commands two Chromatic Elite Guards.",
				{ heading = "Overview" },
				"Manage adds, kite Drakkisath, then focus on him. Damage dealers control adds, avoid Drakkisath's abilities. Healers manage raid healing, keep tanks up. Tanks handle adds, manage Drakkisath's aggro.",
				{
					role = DAMAGE,
					"Control adds, avoid Drakkisath's abilities, focus on boss. Avoid {spell:9573}, {spell:20569}, {spell:16805}, {spell:8078}."
				},
				{
					role = HEALER,
					"Manage raid healing, focus on tanks. Avoid casting on kiting player. Handle {spell:16805} on tanks."
				},
				{
					role = TANK,
					"Handle adds, manage Drakkisath's threat. Coordinate with damage dealers, avoid {spell:9573}, {spell:20569}."
				}
			},
			abilities = {
			}
		}
})
