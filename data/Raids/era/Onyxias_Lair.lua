--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Onyxia's Lair",
	instanceID = 249,
	thumbnail = 1378999,
	icon = 134153,
	splash = 1379000,
	mapID = 249,
	season = false,
	overview = "Deep within the mountains of Dustwallow Marsh lies Onyxia's Lair, home to the black dragon Onyxia, daughter of Deathwing. Disguised as Lady Katrana Prestor, she manipulated the nobles of Stormwind while secretly plotting to destroy the kingdom from within. This legendary 40-player raid features a single, challenging three-phase encounter that tests coordination, positioning, and raid awareness.",
	{
		name = "Onyxia",
		encounterID = 10184,
		portrait = 1378999,
		loot = {
			{ id = 18423, seasonFilter = "all" }, -- Head of Onyxia
			{ id = 17966, seasonFilter = "all" }, -- Onyxia Hide Backpack
			{ id = 18705, seasonFilter = "all" }, -- Mature Black Dragon Sinew
			{ id = 17068, seasonFilter = "all" }, -- Deathbringer
			{ id = 17075, seasonFilter = "all" }, -- Vis'kag the Bloodletter
			{ id = 18813, seasonFilter = "all" }, -- Ring of Binding
			{ id = 17078, seasonFilter = "all" }, -- Sapphiron Drape
			{ id = 18205, seasonFilter = "all" }, -- Eskhandar's Collar
			{ id = 17064, seasonFilter = "all" }, -- Shard of the Scale
			{ id = 18422, seasonFilter = "all" }, -- Onyxia Tooth Pendant
			{ id = 17067, seasonFilter = "all" }, -- Ancient Cornerstone Grimoire
			{ id = 16900, seasonFilter = "all" }, -- Stormrage Cover (Druid T2)
			{ id = 16939, seasonFilter = "all" }, -- Dragonstalker's Helm (Hunter T2)
			{ id = 16921, seasonFilter = "all" }, -- Halo of Transcendence (Priest T2)
			{ id = 16908, seasonFilter = "all" }, -- Bloodfang Hood (Rogue T2)
			{ id = 16947, seasonFilter = "all" }, -- Helmet of Ten Storms (Shaman T2)
			{ id = 16914, seasonFilter = "all" }, -- Netherwind Crown (Mage T2)
			{ id = 16929, seasonFilter = "all" }, -- Nemesis Skullcap (Warlock T2)
			{ id = 16955, seasonFilter = "all" }, -- Judgment Crown (Paladin T2)
			{ id = 16963, seasonFilter = "all" }, -- Helm of Wrath (Warrior T2)
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 10184 },
		overview = {
			"Onyxia, the daughter of Deathwing, has infiltrated Stormwind nobility under the guise of Lady Katrana Prestor. After being exposed by Highlord Bolvar Fordragon and Marshal Reginald Windsor, adventurers must venture into her lair to eliminate this ancient menace. The encounter consists of three distinct phases that test positioning, movement, and raid coordination.",
			{ heading = "Phase 1: The Ground Phase (100%-65%)" },
			"Onyxia begins the fight on the ground, using devastating frontal and tail attacks. Position her with her tail toward the entrance and tanks against the back wall to prevent knockbacks from resetting the fight. All raid members should attack from the sides to avoid {spell:18435} and Tail Sweep. Save major DPS cooldowns for Phase 2. The tank must be careful not to be knocked into the whelp eggs along the sides of the room.",
			{ heading = "Phase 2: The Air Phase (65%-40%)" },
			"At 65% health, Onyxia takes flight and begins using {spell:17086} (Fireball) on random raid members and the devastating Deep Breath ability. When she announces 'taking a deep breath,' immediately move to the sides of the room opposite her facing direction. Maintain 8+ yards spacing to minimize Fireball splash damage. {item:13457} is highly recommended. Onyxian Whelps will spawn from eggs and must be controlled by off-tanks. Use all DPS cooldowns at the start of this phase to minimize time spent in the air.",
			{ heading = "Phase 3: The Final Phase (40%-0%)" },
			"Onyxia lands and must be repositioned exactly as in Phase 1 before DPS resumes. She gains {spell:18431}, a raid-wide fear that sends players running into dangerous areas. Tanks should use Berserker Rage, while healers can provide {spell:6346} or place {spell:8143}. Onyxian Whelps continue spawning and must be AoE'd down quickly. Lava cracks pulse periodically dealing fire damage. The raid must burn her down while managing fears, adds, and environmental hazards.",
			{
				role = DAMAGE,
				"Position yourself on Onyxia's sides to avoid {spell:18435} and Tail Sweep throughout Phase 1 and Phase 3.",
				"Save major DPS cooldowns for the start of Phase 2 to minimize time in the air phase.",
				"In Phase 2, maintain 8+ yards spacing from other raid members to minimize {spell:17086} splash damage.",
				"When Onyxia announces 'taking a deep breath,' immediately run to the sides opposite her facing direction to avoid the Deep Breath attack.",
				"Use {item:13457} to mitigate fire damage throughout the encounter.",
				"In Phase 3, DO NOT attack until Onyxia is repositioned by the tank to avoid pulling threat during {spell:18431}.",
				"Help kill Onyxian Whelps quickly with AoE abilities to prevent the raid from being overwhelmed."
			},
			{
				role = HEALER,
				"Stack with ranged DPS on Onyxia's sides to avoid frontal and tail attacks in Phase 1 and Phase 3.",
				"Be prepared for heavy tank damage from {spell:18500} knockbacks, especially if the tank is positioned incorrectly.",
				"In Phase 2, maintain 8+ yards spacing and be ready for constant raid damage from {spell:17086}. Prioritize players with low health as Fireball damage is significant.",
				"Place {spell:8143} before {spell:18431} in Phase 3, or assign priests to use {spell:6346} on tanks.",
				"During Phase 3 fears, be ready to quickly heal players who run into lava cracks or whelp packs.",
				"Use {item:13457} to reduce incoming fire damage and preserve mana."
			},
			{
				role = TANK,
				"Position Onyxia with her tail pointing toward the raid entrance and your back against the far wall to minimize {spell:18500} knockback distance.",
				"Face Onyxia away from the raid to prevent {spell:18435} from hitting ranged DPS and healers.",
				"Be extremely careful not to get knocked into the whelp eggs along the sides of the room, as this will spawn massive waves of adds.",
				"Use {spell:18499} or {spell:6346} to prevent {spell:19633} from reducing your threat by 25%.",
				"In Phase 2, assign off-tanks to gather and control spawning Onyxian Whelps. AoE threat abilities are essential.",
				"When Phase 3 begins, immediately reposition Onyxia exactly as in Phase 1 before allowing DPS to resume.",
				"Use Berserker Rage or similar fear immunity abilities to maintain control during {spell:18431}.",
				"Be prepared for increased damage in Phase 3 and coordinate with healers on defensive cooldown usage."
			}
		},
		abilities = {
			{ spell = 18435 }, -- Flame Breath
			{ spell = 18500 }, -- Wing Buffet
			{ spell = 19633 }, -- Knock Away
			{ spell = 17086 }, -- Breath (Fireball in P2)
			{ spell = 18431 }, -- Bellowing Roar
			{ spell = 18576 }, -- Cleave
			{ spell = 18392 }, -- Fireball (another variant)
		}
	},
})
