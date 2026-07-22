--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "Sethekk Halls",
	instanceID = 556,
	thumbnail = 608193,
	icon = 136350,
	splash = 608232,
	mapID = 258,
	seasonFilter = "tbc",
	overview = "Sethekk Halls is a wing of Auchindoun where the arakkoa death cult, the Sethekk, perform dark rituals. They seek to summon their raven god, Anzu, and have allied with agents of the Shadow Council in their twisted ceremonies.",
	{
		name = "Darkweaver Syth",
		defeated = 0,
		encounterID = 18472,
		portrait = 607583,
		loot = {
			{ id = 27919, seasonFilter = "tbc" },
			{ id = 27914, seasonFilter = "tbc" },
			{ id = 27915, seasonFilter = "tbc" },
			{ id = 27918, seasonFilter = "tbc" },
			{ id = 27917, seasonFilter = "tbc" },
			{ id = 27916, seasonFilter = "tbc" },
			{ id = 24160, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18472, 20690 },
		overview = {
			"Darkweaver Syth is the first boss encounter in Sethekk Halls, a powerful arakkoa sorcerer who wields devastating arcane and elemental magic. He summons elemental adds throughout the fight that must be dealt with quickly. This encounter teaches players the importance of add management and ranged positioning.",
			{ heading = "Overview" },
			"Darkweaver Syth summons four different types of elemental adds during the fight. Each add has unique abilities that must be managed. The key to this fight is controlling and killing adds quickly while maintaining damage on Syth. Ranged players should stay spread to avoid chaining abilities.",
			{
				role = DAMAGE,
				"Focus on killing elemental adds as they spawn, prioritizing them over Syth himself.",
				"On Heroic difficulty, Time-Lost Controllers should be interrupted and killed first due to their {spell:32764} ability.",
				"Stay spread out at range to avoid chaining damage from {spell:33526}.",
				"Interrupt Syth's {spell:15039} whenever possible.",
				"DPS cooldowns should be saved for when multiple adds are up simultaneously.",
			},
			{
				role = HEALER,
				"Prepare for heavy party-wide damage when adds spawn and cast their abilities.",
				"The {spell:33526} ability deals heavy damage and chains between nearby players.",
				"Dispel {spell:12548} from affected party members immediately.",
				"On Heroic, be ready for increased incoming damage from {spell:32764} if interrupts are missed.",
				"Position yourself at maximum healing range to avoid being hit by elemental abilities.",
			},
			{
				role = TANK,
				"Tank Darkweaver Syth in place, only moving to avoid frontal cone abilities.",
				"Pick up all elemental adds as they spawn and position them with Syth for AoE damage.",
				"Use defensive cooldowns when multiple adds are alive and casting.",
				"On Heroic difficulty, prioritize interrupting Time-Lost Controllers.",
				"Face Syth away from the group to prevent {spell:33526} from chaining through melee.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Anzu",
		defeated = 0,
		encounterID = 23035,
		portrait = 607544,
		loot = {
			{ id = 32769, seasonFilter = "tbc" },
			{ id = 32778, seasonFilter = "tbc" },
			{ id = 32779, seasonFilter = "tbc" },
			{ id = 32781, seasonFilter = "tbc" },
			{ id = 32780, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {
			{ id = 32768, seasonFilter = "tbc" }
		},
		npcs = { 23035 },
		overview = {
			"Anzu is an optional Heroic-only boss that can only be summoned by Druids who have completed the Swift Flight Form quest chain. This raven god is one of the most challenging 5-player encounters in Burning Crusade, featuring multiple phases, dangerous adds, and complex mechanics. Anzu is famous for dropping the extremely rare Raven Lord mount.",
			{ heading = "Overview" },
			"Anzu is a two-phase encounter available only in Heroic mode. A Druid with the appropriate quest item must use it at the raven statue to summon Anzu. The fight features spell reflection, banishment phases, and waves of dangerous adds. This is one of the most mechanically demanding 5-player encounters in TBC.",
			{
				role = DAMAGE,
				"During Phase 1, focus on damaging Anzu while managing Brood of Anzu adds.",
				"Kill Brood of Anzu adds immediately - they cast {spell:40321} which heals Anzu significantly.",
				"Stop casting when {spell:40109} is active on Anzu to avoid taking reflected damage.",
				"During banishment phases, focus entirely on killing Raven God adds before they reach the summoning circles.",
				"Ranged DPS should prioritize interrupting {spell:40321} from Brood of Anzu.",
				"Save major DPS cooldowns for Phase 2 when Anzu returns and the fight becomes a burn race.",
			},
			{
				role = HEALER,
				"This fight has extremely high healing requirements, especially during banishment phases.",
				"During {spell:40164} phases, Anzu disappears and summons waves of Raven God adds.",
				"Party members will take heavy damage from Raven God adds - keep everyone topped off.",
				"Manage your mana carefully as this is a long fight with sustained high damage.",
				"Watch for reflected spell damage if DPS continue casting during {spell:40109}.",
				"Use major healing cooldowns during the final burn phase when all mechanics overlap.",
			},
			{
				role = TANK,
				"Tank Anzu facing away from the group to protect them from {spell:40486}.",
				"Pick up all Brood of Anzu adds as they spawn and bring them to Anzu for cleave damage.",
				"During {spell:40164} banishment phases, pick up Raven God adds and prevent them from reaching the summoning circles.",
				"Use major defensive cooldowns in Phase 2 as Anzu's damage significantly increases.",
				"Kite or tank Raven God adds away from the summoning circles during banishment phases.",
				"This fight requires excellent threat management as adds constantly spawn.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Talon King Ikiss",
		defeated = 0,
		encounterID = 18473,
		portrait = 607780,
		loot = {
			{ id = 27946, seasonFilter = "tbc" },
			{ id = 27981, seasonFilter = "tbc" },
			{ id = 27985, seasonFilter = "tbc" },
			{ id = 27925, seasonFilter = "tbc" },
			{ id = 27980, seasonFilter = "tbc" },
			{ id = 27986, seasonFilter = "tbc" },
			{ id = 27948, seasonFilter = "tbc" },
			{ id = 27838, seasonFilter = "tbc" },
			{ id = 27875, seasonFilter = "tbc" },
			{ id = 27776, seasonFilter = "tbc" },
			{ id = 27936, seasonFilter = "tbc" },
			{ id = 29249, seasonFilter = "tbc" },
			{ id = 29259, seasonFilter = "tbc" },
			{ id = 32073, seasonFilter = "tbc" },
			{ id = 29355, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18473, 20706 },
		overview = {
			"Talon King Ikiss is the final boss of Sethekk Halls, a powerful arakkoa sorcerer who serves as leader of the Sethekk death cult. This fight features arcane magic, polymorph mechanics, and a deadly mana detonation ability that requires careful positioning and awareness. The encounter becomes significantly more dangerous on Heroic difficulty.",
			{ heading = "Overview" },
			"Talon King Ikiss uses powerful arcane magic and polymorph effects to devastate unprepared groups. The most dangerous mechanic is {spell:38197}, which causes massive damage to players within line of sight. Players must hide behind pillars to avoid this deadly ability. Proper positioning and quick reactions are essential for survival.",
			{
				role = DAMAGE,
				"Break line of sight behind pillars immediately when Ikiss begins casting {spell:38197}.",
				"On Heroic difficulty, {spell:38197} is called {spell:40425} and will instantly kill players in line of sight.",
				"DPS players who are polymorphed by {spell:38245} should be left alone - the polymorph breaks on damage.",
				"Focus damage on Ikiss during safe phases between {spell:38197} casts.",
				"Ranged DPS should position near pillars to minimize movement time when hiding.",
				"Interrupt {spell:38194} whenever possible to reduce incoming damage.",
			},
			{
				role = HEALER,
				"Hide behind pillars immediately when Ikiss casts {spell:38197} - healing can wait.",
				"On Heroic difficulty, failing to break line of sight during {spell:40425} means instant death.",
				"Do not dispel or damage players affected by {spell:38245} - it will break naturally and they are safely healed.",
				"Position yourself near a pillar to minimize movement when {spell:38197} is cast.",
				"Top off the group between {spell:38197} casts as players may take damage from {spell:38194}.",
				"The tank may need healing while you are hiding - use HoTs before breaking line of sight.",
			},
			{
				role = TANK,
				"Tank Talon King Ikiss near the center of the room to give all players access to pillars.",
				"Hide behind a pillar when {spell:38197} is cast - survival takes priority over threat.",
				"On Heroic mode, {spell:40425} will instantly kill you if you remain in line of sight.",
				"Be ready to quickly re-establish threat after everyone returns from hiding behind pillars.",
				"If polymorphed by {spell:38245}, you will be safely healed and can resume tanking when it breaks.",
				"Use defensive cooldowns during the periods between {spell:38197} casts when taking sustained damage.",
			}
		},
		abilities = {
		}
	}
})
