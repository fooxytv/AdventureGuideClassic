--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "The Slave Pens",
	instanceID = 547,
	thumbnail = 608199,
	icon = 136350,
	splash = 608238,
	mapID = 265,
	seasonFilter = "tbc",
	overview = "The Slave Pens are the holding cells of Coilfang Reservoir, where the naga imprison those they've captured in their campaign to drain the marshes of Zangarmarsh. Slaves are forced to labor in the pumping stations, extracting the precious water to create a new ocean for Lady Vashj.",
	{
		name = "Mennu the Betrayer",
		defeated = 0,
		encounterID = 17941,
		portrait = 607715,
		loot = {
			{ id = 24359, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24361, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24360, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24357, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24356, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 29674, seasonFilter = "tbc" },
			{ id = 27541, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27542, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27545, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27543, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27546, seasonFilter = "tbc", difficulty = "heroic" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17941, 17940 },
		overview = {
			"Mennu the Betrayer is a Broken draenei who has forsaken his people to serve the naga of Coilfang Reservoir. As the first boss of The Slave Pens, he commands the power of corrupted water magic and shamanic totems. The fight is straightforward but requires awareness of totems and consistent interrupts.",
			{ heading = "Overview" },
			"Interrupt {spell:31991} whenever possible to minimize healing. Destroy {spell:31985} immediately - it heals Mennu significantly. Kill {spell:31981} quickly to prevent raid-wide damage. DPS can safely ignore Earthbind totems. Position away from {spell:33132} puddles in Heroic mode.",
			{
				role = DAMAGE,
				"Prioritize interrupting {spell:31991} casts.",
				"Destroy {spell:31985} immediately when summoned - it heals Mennu for massive amounts.",
				"Kill {spell:31981} as soon as they spawn to prevent heavy party damage.",
				"Ranged DPS should focus totems while maintaining damage on Mennu.",
				"In Heroic mode, quickly move away from {spell:33132} zones on the ground."
			},
			{
				role = HEALER,
				"Be prepared for increased tank damage when totems are active.",
				"{spell:31981} deals significant AoE damage to the party - keep party topped off.",
				"Watch for {spell:31991} casts and top off party members quickly if heals go through.",
				"In Heroic mode, {spell:33132} creates persistent damage zones - position carefully.",
				"Mana management is important if too many healing totems are allowed to function."
			},
			{
				role = TANK,
				"Tank Mennu away from his totems to give DPS clear access.",
				"Face Mennu away from the party to minimize potential cleave damage.",
				"Use interrupts on {spell:31991} when your interrupt is available.",
				"In Heroic mode, kite Mennu away from {spell:33132} pools while maintaining threat.",
				"Maintain solid threat as DPS will be switching to totems frequently."
			}
		},
		abilities = {
			{ spell = 31991, heading = true }, -- Corrupted Nova
			{ spell = 31985, heading = true }, -- Healing Ward
			{ spell = 31981, heading = true }, -- Tainted Earthgrab Totem
			{ spell = 33132, heading = true }  -- Corrupted Nova (Heroic)
		}
	},
	{
		name = "Rokmar the Crackler",
		defeated = 0,
		encounterID = 17991,
		portrait = 607759,
		loot = {
			{ id = 24379, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24380, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24378, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24381, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24376, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27547, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27548, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27550, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 28124, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27551, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27549, seasonFilter = "tbc", difficulty = "heroic" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17991, 21696 },
		overview = {
			"Rokmar the Crackler is a massive bog lord who guards the central caverns of The Slave Pens. This encounter tests the party's ability to manage adds while maintaining damage on the boss. Rokmar summons Lesser Bog Creatures throughout the fight that must be controlled, and his grievous wounds require careful healing management.",
			{ heading = "Overview" },
			"Tank Rokmar in place and maintain solid threat. Kill or CC {spell:31481} as they spawn - do not let them overwhelm the party. Heal through {spell:31956} debuff carefully, as direct healing is reduced. Dispel {spell:35760} in Heroic mode immediately. DPS focus boss but switch to adds when needed.",
			{
				role = DAMAGE,
				"Maintain steady DPS on Rokmar as primary target.",
				"Switch to {spell:31481} when they spawn - use AoE if multiple adds are up.",
				"Use snares and roots on adds to control them while burning down.",
				"In Heroic mode, help interrupt or dispel {spell:35760} if possible.",
				"Melee DPS watch threat carefully as adds can complicate aggro tables."
			},
			{
				role = HEALER,
				"{spell:31956} reduces healing received - use larger heals and HoTs effectively.",
				"Be prepared for heavy tank damage when multiple {spell:31481} are active.",
				"In Heroic mode, dispel {spell:35760} immediately - it deals significant Nature damage over time.",
				"Focus healing on whoever has active {spell:31481} attacking them.",
				"Keep HoTs rolling on the tank constantly due to healing reduction debuff."
			},
			{
				role = TANK,
				"Main tank holds Rokmar in position - movement should be minimal.",
				"Off-tank or DPS must pick up {spell:31481} as they spawn.",
				"Use damage mitigation cooldowns when multiple adds are active.",
				"{spell:31956} will be on you constantly - communicate with healers about health status.",
				"In Heroic mode, prepare for significantly increased damage from {spell:35760} and adds."
			}
		},
		abilities = {
			{ spell = 31956, heading = true }, -- Grievous Wound
			{ spell = 31481, heading = true }, -- Summon Bog Creatures
			{ spell = 31946, heading = true }, -- Water Spit
			{ spell = 35760, heading = true }  -- Frenzy (Heroic)
		}
	},
	{
		name = "Quagmirran",
		defeated = 0,
		encounterID = 17942,
		portrait = 607750,
		loot = {
			{ id = 24364, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24365, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24366, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24362, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 24363, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 29349, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29242, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 30538, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 32078, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27740, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27741, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27800, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27672, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27742, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27796, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27713, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27673, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27683, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27712, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27714, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 33821, seasonFilter = "tbc", difficulty = "heroic" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17942 },
		overview = {
			"Quagmirran is the final boss of The Slave Pens, a powerful bog lord who has claimed dominion over the deepest waters of the reservoir. This encounter features a devastating poison cloud ability and a protective acid geyser shield. The fight requires careful positioning and strong awareness of environmental hazards.",
			{ heading = "Overview" },
			"Tank Quagmirran at the edge of the room for optimal positioning. When {spell:34780} is cast, the entire party must run far away (30+ yards) or die to poison damage. Destroy or avoid {spell:32055} when active - they make Quagmirran immune to damage. In Heroic mode, {spell:38153} deals massive AoE damage. Return to boss quickly after poison cloud dissipates.",
			{
				role = DAMAGE,
				"Maintain consistent DPS on Quagmirran between mechanics.",
				"When {spell:34780} is cast, immediately run to maximum range (30+ yards).",
				"If {spell:32055} spawn, either destroy them quickly or wait for them to despawn.",
				"Do NOT waste cooldowns when Acid Geyser shield is active - boss is immune.",
				"In Heroic mode, spread out slightly to minimize {spell:38153} chain damage.",
				"Ranged DPS have an advantage for handling {spell:34780} mechanics."
			},
			{
				role = HEALER,
				"Position at maximum range to have more reaction time for {spell:34780}.",
				"When Poison Bolt Volley is cast, RUN immediately - you cannot outheal it.",
				"In Heroic mode, {spell:38153} deals heavy party damage - keep everyone topped off.",
				"Do not waste mana healing during {spell:32055} phases when boss is immune.",
				"Use HoTs and instant casts while repositioning for poison cloud.",
				"Be ready for increased tank damage after returning from {spell:34780}."
			},
			{
				role = TANK,
				"Tank Quagmirran near the edge of the room to maximize run distance for party.",
				"When {spell:34780} is cast, run away with the party - threat will hold.",
				"Face the boss away from the party to prevent cleave damage.",
				"During {spell:32055} phases, maintain position but save cooldowns.",
				"Return to boss quickly after poison dissipates to minimize downtime.",
				"In Heroic mode, use defensive cooldowns for {spell:38153} damage."
			}
		},
		abilities = {
			{ spell = 34780, heading = true }, -- Poison Bolt Volley
			{ spell = 32055, heading = true }, -- Quagmirran's Eye (Acid Geyser)
			{ spell = 40504, heading = true }, -- Cleave
			{ spell = 38153, heading = true }  -- Acid Spray (Heroic)
		}
	}
})
