--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "The Blood Furnace",
	instanceID = 542,
	thumbnail = 608207,
	icon = 136350,
	splash = 608246,
	mapID = 261,
	seasonFilter = "tbc",
	overview = "The Blood Furnace is the heart of the fel orc operation in Hellfire Citadel. Here, Kargath Bladefist oversees the creation of fel orcs, forcing captives to drink the blood of the pit lord Magtheridon. The furnace serves as both a prison and a factory for Illidan's army.",
	{
		name = "The Maker",
		defeated = 0,
		encounterID = 17381,
		portrait = 607789,
		loot = {
			{ id = 24388, seasonFilter = "tbc" },
			{ id = 24387, seasonFilter = "tbc" },
			{ id = 24385, seasonFilter = "tbc" },
			{ id = 24386, seasonFilter = "tbc" },
			{ id = 24384, seasonFilter = "tbc" },
			{ id = 27485, seasonFilter = "tbc" },
			{ id = 27488, seasonFilter = "tbc" },
			{ id = 27483, seasonFilter = "tbc" },
			{ id = 27487, seasonFilter = "tbc" },
			{ id = 27484, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17381, 18621 },
		overview = {
			"The Maker is a massive fel reaver constructed to help process prisoners into fel orcs. This mechanical monstrosity uses alchemical weapons and mind control to dominate its victims. Though not as deadly as the later bosses, The Maker serves as a good introduction to the dangers within the Blood Furnace.",
			{ heading = "Overview" },
			"The Maker will periodically mind control a party member with {spell:30923}, increasing their damage and healing by 100%. The tank must maintain threat while avoiding {spell:30925} and {spell:40059} explosions. Dispel {spell:31117} quickly to reduce raid damage.",
			{
				role = DAMAGE,
				"When a party member is affected by {spell:30923}, focus fire on the boss and ignore the mind-controlled player.",
				"Ranged damage dealers should spread out to minimize damage from {spell:30925} and {spell:40059}.",
				"High burst damage is recommended to minimize the number of mind control cycles."
			},
			{
				role = HEALER,
				"The mind-controlled player cannot be dispelled and will attack the party. Keep the group topped off during {spell:30923}.",
				"Dispel {spell:31117} quickly to prevent excessive shadow damage.",
				"Be prepared for sudden damage spikes from {spell:30925} and {spell:40059} explosions."
			},
			{
				role = TANK,
				"Maintain threat throughout the fight, even when party members are mind-controlled by {spell:30923}.",
				"Position The Maker to avoid unnecessary party damage from {spell:30925} and {spell:40059}.",
				"The mind control lasts 10 seconds and cannot be broken early."
			}
		},
		abilities = {
			{ spell = 30923, seasonFilter = "all" },
			{ spell = 30925, seasonFilter = "all" },
			{ spell = 31117, seasonFilter = "all" },
			{ spell = 40059, seasonFilter = "all" }
		}
	},
	{
		name = "Broggok",
		defeated = 0,
		encounterID = 17380,
		portrait = 607558,
		loot = {
			{ id = 24392, seasonFilter = "tbc" },
			{ id = 24393, seasonFilter = "tbc" },
			{ id = 24391, seasonFilter = "tbc" },
			{ id = 24390, seasonFilter = "tbc" },
			{ id = 24389, seasonFilter = "tbc" },
			{ id = 27848, seasonFilter = "tbc" },
			{ id = 27492, seasonFilter = "tbc" },
			{ id = 27489, seasonFilter = "tbc" },
			{ id = 27491, seasonFilter = "tbc" },
			{ id = 27490, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17380, 18601 },
		overview = {
			"Broggok is a massive poison-spewing monstrosity imprisoned within the Blood Furnace. Before engaging Broggok, players must defeat four waves of Fel Orc prisoners who are released from their cells. Once freed, Broggok unleashes devastating poison attacks that require constant movement and careful positioning.",
			{ heading = "Overview" },
			"Defeat four waves of Fel Orc adds before Broggok is released. Once engaged, the tank must constantly move Broggok to avoid {spell:30916} which expands over time. All players must be ready to dispel {spell:30917} and {spell:38459}, and melee should avoid standing in front during {spell:30913} and {spell:38458}.",
			{
				role = DAMAGE,
				"Clear all four waves of Fel Orc adds before Broggok is released from his prison.",
				"Stay behind Broggok to avoid {spell:30913} and {spell:38458}.",
				"Move out of {spell:30916} immediately as it expands rapidly and deals heavy damage.",
				"Ranged damage dealers should maintain maximum distance while being ready to move from poison clouds."
			},
			{
				role = HEALER,
				"Dispel {spell:30917} and {spell:38459} immediately - this is your top priority.",
				"Prepare for heavy party-wide damage during the add waves before Broggok.",
				"Keep the tank topped off as they will be constantly moving and taking damage from residual poison effects.",
				"Position yourself to avoid {spell:30916} while maintaining healing range."
			},
			{
				role = TANK,
				"Tank Broggok away from the party and constantly move him to avoid {spell:30916}.",
				"Face Broggok away from the party to prevent melee from being hit by {spell:30913} and {spell:38458}.",
				"During the add waves, gather all Fel Orcs for efficient AoE damage.",
				"Be prepared to pick up Broggok immediately when he breaks free from his prison."
			}
		},
		abilities = {
			{ spell = 30913, seasonFilter = "all" },
			{ spell = 30916, seasonFilter = "all" },
			{ spell = 30917, seasonFilter = "all" },
			{ spell = 38458, seasonFilter = "all" },
			{ spell = 38459, seasonFilter = "all" }
		}
	},
	{
		name = "Keli'dan the Breaker",
		defeated = 0,
		encounterID = 17377,
		portrait = 607670,
		loot = {
			{ id = 24397, seasonFilter = "tbc" },
			{ id = 24395, seasonFilter = "tbc" },
			{ id = 24398, seasonFilter = "tbc" },
			{ id = 24396, seasonFilter = "tbc" },
			{ id = 24394, seasonFilter = "tbc" },
			{ id = 32080, seasonFilter = "tbc" },
			{ id = 29245, seasonFilter = "tbc" },
			{ id = 29239, seasonFilter = "tbc" },
			{ id = 29347, seasonFilter = "tbc" },
			{ id = 27506, seasonFilter = "tbc" },
			{ id = 27514, seasonFilter = "tbc" },
			{ id = 27522, seasonFilter = "tbc" },
			{ id = 27494, seasonFilter = "tbc" },
			{ id = 27505, seasonFilter = "tbc" },
			{ id = 27788, seasonFilter = "tbc" },
			{ id = 27495, seasonFilter = "tbc" },
			{ id = 28121, seasonFilter = "tbc" },
			{ id = 28264, seasonFilter = "tbc" },
			{ id = 27497, seasonFilter = "tbc" },
			{ id = 27512, seasonFilter = "tbc" },
			{ id = 27507, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17377, 18607 },
		overview = {
			"Keli'dan the Breaker is the final boss of the Blood Furnace and the jailer of the pit lord Magtheridon. Surrounded by five Shadowmoon Channelers who empower him, Keli'dan wields devastating shadow and fire magic. His signature ability forces him into a brief period of invulnerability while he channels a massive fire nova that will kill unprepared groups.",
			{ heading = "Overview" },
			"Kill all five Shadowmoon Channelers before engaging Keli'dan. When he casts {spell:30940}, run away immediately to avoid the devastating {spell:30940} and {spell:33775}. Spread out to minimize damage from {spell:17228} and {spell:40070}. Dispel {spell:30938} quickly to prevent excessive shadow damage over time.",
			{
				role = DAMAGE,
				"Focus down all five Shadowmoon Channelers before engaging Keli'dan the Breaker.",
				"When Keli'dan yells 'Closer! Come closer! And burn!' and begins casting {spell:30940}, run to maximum range immediately.",
				"Spread out to reduce damage taken from {spell:17228} and {spell:40070}.",
				"Resume damage after {spell:30940} and {spell:33775} complete and Keli'dan becomes vulnerable again.",
				"Interrupt or dispel Shadowmoon Channelers during the initial phase to reduce incoming damage."
			},
			{
				role = HEALER,
				"Dispel {spell:30938} immediately to prevent the shadow damage over time from stacking.",
				"When {spell:30940} is cast, run to maximum range while continuing to heal if possible.",
				"Keep the party topped off as {spell:17228} and {spell:40070} deal significant shadow damage to the entire group.",
				"On Heroic difficulty, {spell:30940} and {spell:33775} will kill anyone within 20 yards, so movement is critical."
			},
			{
				role = TANK,
				"Clear all five Shadowmoon Channelers before pulling Keli'dan to prevent them from healing him.",
				"Tank Keli'dan facing away from the party to minimize damage from cleave effects.",
				"When {spell:30940} is cast, run away to maximum range and be prepared to re-establish threat afterward.",
				"Position yourself to quickly move out of range during {spell:30940} while maintaining boss control."
			}
		},
		abilities = {
			{ spell = 17228, seasonFilter = "all" },
			{ spell = 30935, seasonFilter = "all" },
			{ spell = 30938, seasonFilter = "all" },
			{ spell = 30940, seasonFilter = "all" },
			{ spell = 33775, seasonFilter = "all" },
			{ spell = 37370, seasonFilter = "all" },
			{ spell = 37371, seasonFilter = "all" },
			{ spell = 40070, seasonFilter = "all" }
		}
	}
})
