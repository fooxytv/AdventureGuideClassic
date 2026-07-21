--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "Shadow Labyrinth",
	instanceID = 555,
	thumbnail = 608193,
	icon = 136350,
	splash = 608232,
	mapID = 260,
	seasonFilter = "tbc",
	overview = "The Shadow Labyrinth is the darkest wing of Auchindoun, where Murmur, an elemental terror from the twisting nether, is imprisoned. The Shadow Council seeks to control this creature of pure sound and destruction to serve their dark masters.",
	{
		name = "Ambassador Hellmaw",
		defeated = 0,
		encounterID = 18731,
		portrait = 607536,
		loot = {
			{ id = 27889, seasonFilter = "tbc" },
			{ id = 27888, seasonFilter = "tbc" },
			{ id = 27884, seasonFilter = "tbc" },
			{ id = 27886, seasonFilter = "tbc" },
			{ id = 27887, seasonFilter = "tbc" },
			{ id = 27885, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18731 },
		overview = {
			"Ambassador Hellmaw is a skeletal demon who patrols the entrance corridors of Shadow Labyrinth. He periodically makes his rounds, and engaging him during his patrol requires careful timing. Hellmaw's most dangerous ability is his AoE fear, which can cause chaotic pulls if not managed properly.",
			{ heading = "Overview" },
			"Ambassador Hellmaw patrols the entrance hallway and must be engaged carefully to avoid nearby trash. His fear is the primary mechanic to manage. Tanks should position him facing away from the group. Interrupt his Corrosive Acid when possible to reduce tank damage.",
			{
				role = DAMAGE,
				"Stay behind Hellmaw to avoid {spell:33551} cleave damage.",
				"Prepare to use fear immunity abilities or {spell:5938} immediately when {spell:33547} is cast.",
				"If feared, be ready to assist with crowd control on any accidentally pulled trash mobs.",
				"Interrupt {spell:33551} to reduce tank damage when available."
			},
			{
				role = HEALER,
				"Keep the tank topped off as {spell:33551} deals heavy damage over time.",
				"Be ready to dispel fear effects quickly if possible, or use fear immunity abilities.",
				"During {spell:33547}, maintain distance from the group to avoid spreading fear.",
				"Have mana available to stabilize after fear if trash is accidentally pulled."
			},
			{
				role = TANK,
				"Pull Hellmaw when he is at the far end of his patrol route to avoid accidental pulls during fear.",
				"Position him facing away from the group to prevent {spell:33551} from hitting multiple players.",
				"Use defensive cooldowns when {spell:33551} stacks become high.",
				"If feared, be ready to quickly re-establish threat when fear breaks."
			}
		},
		abilities = {
			{
				id = 33547,
				name = "Fear",
				description = "Fears all nearby players for 5 seconds, causing them to flee in terror. This can result in additional trash pulls if not managed carefully.",
				icon = 136183
			},
			{
				id = 33551,
				name = "Corrosive Acid",
				description = "Spits acid at the current target, dealing Nature damage over time and reducing armor. Stacks and can be interrupted.",
				icon = 132790
			},
			{
				id = 14873,
				name = "Banish",
				description = "Banishes a random player, making them immune to all damage but unable to act. Lasts 6 seconds.",
				icon = 136135
			}
		}
	},
	{
		name = "Blackheart the Inciter",
		defeated = 0,
		encounterID = 18667,
		portrait = 607555,
		loot = {
			{ id = 27892, seasonFilter = "tbc" },
			{ id = 27893, seasonFilter = "tbc" },
			{ id = 28134, seasonFilter = "tbc" },
			{ id = 27891, seasonFilter = "tbc" },
			{ id = 27890, seasonFilter = "tbc" },
			{ id = 25728, seasonFilter = "tbc" },
			{ id = 27468, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18667 },
		overview = {
			"Blackheart the Inciter is a mind-controlling demon who turns the party against itself. His signature ability causes players to attack their own allies, creating chaos. This fight tests the group's ability to recognize and manage mind control effects while maintaining damage on the boss.",
			{ heading = "Overview" },
			"This encounter revolves around managing {spell:33676} which causes players to attack their allies. Spread out to minimize the impact of mind-controlled players. Do not kill mind-controlled allies. Use crowd control abilities to neutralize them until the effect wears off. Blackheart himself has relatively low health.",
			{
				role = DAMAGE,
				"Watch for the {spell:33676} debuff on yourself and allies.",
				"If you become incited, move away from the group immediately to reduce friendly fire damage.",
				"Use non-lethal crowd control on incited allies: {spell:118}, {spell:6770}, {spell:1776}, {spell:2094}.",
				"Focus damage on Blackheart - the fight ends when he dies, regardless of mind control effects.",
				"Avoid using AoE abilities that could damage mind-controlled allies."
			},
			{
				role = HEALER,
				"Heal through the damage from mind-controlled players attacking the group.",
				"Use {spell:1513} or {spell:605} on incited players if available to reduce their damage output.",
				"If you become incited, run away from the group to minimize damage dealt.",
				"Keep HoTs active on multiple targets as damage will be spread across the party.",
				"Be ready to recover quickly after mind control ends."
			},
			{
				role = TANK,
				"Hold threat on Blackheart and keep him positioned in a central location.",
				"If you become incited, other party members should avoid you until the effect ends.",
				"Maintain threat generation even while party members are mind-controlled.",
				"Use defensive abilities to mitigate damage from incited melee players.",
				"Call out when you or other key players are incited."
			}
		},
		abilities = {
			{
				id = 33676,
				name = "Incite Chaos",
				description = "Mind controls 2 random players, causing them to attack their own party members for 15 seconds. Mind-controlled players deal full damage and must be controlled with non-lethal crowd control.",
				icon = 237511
			},
			{
				id = 33635,
				name = "Charge",
				description = "Charges a random ranged player, dealing physical damage and stunning them briefly. Resets threat on that target.",
				icon = 132368
			},
			{
				id = 33654,
				name = "War Stomp",
				description = "Stuns all nearby enemies for 3 seconds. Interrupts casting and prevents actions.",
				icon = 132091
			}
		}
	},
	{
		name = "Grandmaster Vorpil",
		defeated = 0,
		encounterID = 18732,
		portrait = 607625,
		loot = {
			{ id = 27897, seasonFilter = "tbc" },
			{ id = 27900, seasonFilter = "tbc" },
			{ id = 27901, seasonFilter = "tbc" },
			{ id = 27898, seasonFilter = "tbc" },
			{ id = 21525, seasonFilter = "tbc" },
			{ id = 27775, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18732, 18794 },
		overview = {
			"Grandmaster Vorpil is a powerful warlock of the Shadow Council who commands void travelers and draws upon shadow energy. This fight features add management, teleportation mechanics, and heavy shadow damage. The encounter takes place in a circular room where Vorpil summons Voidwalkers that spawn additional void travelers through portals.",
			{ heading = "Overview" },
			"Grandmaster Vorpil periodically teleports and summons Voidwalkers that open void rifts. Void travelers spawn from these rifts and must be killed quickly. The fight requires strong AoE damage to handle waves of adds while maintaining damage on the boss. Shadow resistance can be helpful but is not required.",
			{
				role = DAMAGE,
				"Kill {spell:33582} Voidwalkers immediately when they spawn to prevent void rifts from opening.",
				"Use AoE abilities to quickly eliminate void travelers that spawn from active rifts.",
				"When Vorpil teleports using {spell:33563}, locate him quickly and resume damage.",
				"Ranged players should spread out to avoid stacking damage from {spell:33551}.",
				"Focus void travelers over Vorpil if they begin to overwhelm the group.",
				"In Heroic mode, interrupt {spell:33841} whenever possible."
			},
			{
				role = HEALER,
				"Prepare for heavy group-wide shadow damage throughout the encounter.",
				"Keep HoTs active on the tank as {spell:33617} deals significant shadow damage over time.",
				"Use group healing abilities when multiple void travelers are active.",
				"Position yourself to maintain line of sight when Vorpil teleports.",
				"Conserve mana early - this is an endurance fight with sustained damage.",
				"In Heroic mode, dispel {spell:33563} effects when safe to do so."
			},
			{
				role = TANK,
				"Tank Vorpil in the center of the room to minimize movement when he teleports.",
				"Pick up Voidwalkers quickly when they spawn and position them for AoE damage.",
				"Use defensive cooldowns during void traveler waves to survive shadow damage.",
				"Mark Voidwalkers for DPS priority to prevent rift spawns.",
				"Maintain threat on Vorpil while also gathering void travelers.",
				"Face Vorpil away from the group to prevent cleave damage."
			}
		},
		abilities = {
			{
				id = 33563,
				name = "Draw Shadows",
				description = "Periodically teleports to a random location in the room and pulls all players to him. Deals shadow damage to all nearby enemies.",
				icon = 136121
			},
			{
				id = 33617,
				name = "Shadow Bolt Volley",
				description = "Unleashes a volley of shadow bolts at all nearby enemies, dealing heavy shadow damage. Cannot be interrupted.",
				icon = 136197
			},
			{
				id = 33582,
				name = "Summon Voidwalker",
				description = "Summons a Voidwalker add. If not killed quickly, the Voidwalker opens a void rift that spawns multiple void travelers.",
				icon = 136221
			},
			{
				id = 38725,
				name = "Rain of Fire",
				description = "Creates a rain of fire at a target location, dealing fire damage over time to all players in the area. Move out of the affected area.",
				icon = 136186
			},
			{
				id = 33841,
				name = "Void Portal",
				description = "Opens a void portal that continuously spawns void travelers. Portals spawn when Voidwalkers are not killed quickly enough. Heroic only: portals spawn more frequently.",
				icon = 135759
			}
		}
	},
	{
		name = "Murmur",
		defeated = 0,
		encounterID = 18708,
		portrait = 607720,
		loot = {
			{ id = 24309, seasonFilter = "tbc" },
			{ id = 27902, seasonFilter = "tbc" },
			{ id = 27912, seasonFilter = "tbc" },
			{ id = 27913, seasonFilter = "tbc" },
			{ id = 27905, seasonFilter = "tbc" },
			{ id = 27903, seasonFilter = "tbc" },
			{ id = 27910, seasonFilter = "tbc" },
			{ id = 27778, seasonFilter = "tbc" },
			{ id = 28232, seasonFilter = "tbc" },
			{ id = 28230, seasonFilter = "tbc" },
			{ id = 27908, seasonFilter = "tbc" },
			{ id = 27909, seasonFilter = "tbc" },
			{ id = 27803, seasonFilter = "tbc" },
			{ id = 30532, seasonFilter = "tbc" },
			{ id = 29357, seasonFilter = "tbc" },
			{ id = 29261, seasonFilter = "tbc" },
			{ id = 29353, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18708 },
		overview = {
			"Murmur is an elemental being of pure sonic energy imprisoned within the Shadow Labyrinth. This creature of sound itself has devastating area-of-effect abilities and a unique mechanic where proximity determines damage taken. The encounter features multiple phases and requires precise positioning and timing. Murmur starts at 40% health, making this a relatively short but intense fight.",
			{ heading = "Overview" },
			"Murmur begins the encounter at 40% health. The fight revolves around managing {spell:33923}, which deals massive damage based on proximity to Murmur. Players must spread out and position themselves carefully. At 20% health, Murmur gains {spell:33331}, drastically increasing his attack speed. The tank must use major defensive cooldowns during this final phase.",
			{
				role = DAMAGE,
				"Maintain maximum distance from Murmur at all times - {spell:33923} damage is based on proximity.",
				"Spread out from other players to avoid having multiple people hit by the same {spell:33923}.",
				"When {spell:33923} is cast, stop all movement immediately to minimize damage taken.",
				"At 20% health, prepare for the {spell:33331} phase with drastically increased boss damage.",
				"Use personal defensive cooldowns during {spell:33923} casts, especially in Heroic mode.",
				"Interrupt {spell:33332} whenever possible to prevent AoE damage.",
				"In Heroic mode, the damage from all abilities is significantly higher - use damage reduction abilities."
			},
			{
				role = HEALER,
				"Position at maximum range to minimize {spell:33923} damage to yourself.",
				"Prepare large heals for the entire group when {spell:33923} is cast.",
				"During the 20% {spell:33331} phase, focus all healing on the tank.",
				"Use healing cooldowns during {spell:33331} - tank damage will be extreme.",
				"Keep HoTs active on the tank at all times, especially before 20%.",
				"In Heroic mode, rotate healing cooldowns for each {spell:33923} cast.",
				"Mana conservation is critical - this fight has heavy sustained healing requirements."
			},
			{
				role = TANK,
				"Stand at melee range but position the group at maximum distance behind you.",
				"Use a major defensive cooldown when {spell:33331} activates at 20% health.",
				"Coordinate with healers before the 20% threshold to ensure cooldowns are ready.",
				"During {spell:33923}, brace for incoming damage but maintain threat generation.",
				"Save your strongest defensive abilities for the final 20% burn phase.",
				"In Heroic mode, consider using multiple cooldowns simultaneously during {spell:33331}.",
				"Call out when Murmur is approaching 20% to prepare the group for the final phase."
			}
		},
		abilities = {
			{
				id = 33923,
				name = "Sonic Boom",
				description = "Releases a massive sonic shockwave that deals Physical damage to all players. Damage is based on proximity to Murmur - the closer you are, the more damage you take. In Heroic mode, this can one-shot players at close range.",
				icon = 136222
			},
			{
				id = 33331,
				name = "Murmur's Touch",
				description = "At 20% health, Murmur becomes enraged, increasing his attack speed by 300%. Tank damage becomes extreme and requires major defensive cooldowns and focused healing.",
				icon = 136147
			},
			{
				id = 38794,
				name = "Magnetic Pull",
				description = "Periodically pulls all players toward Murmur. This is extremely dangerous combined with {spell:33923}. Players must immediately move back to maximum range after being pulled.",
				icon = 135990
			},
			{
				id = 33332,
				name = "Resonance",
				description = "Deals periodic shadow damage to all nearby players. This damage increases over time if not interrupted. Can be interrupted by melee abilities.",
				icon = 136036
			},
			{
				id = 33686,
				name = "Thundering Storm",
				description = "Heroic mode only. Creates a massive storm of sonic energy dealing nature damage to all players. Requires the entire group to use damage reduction abilities.",
				icon = 136014
			}
		}
	}
})
