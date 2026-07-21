--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "The Arcatraz",
	instanceID = 552,
	thumbnail = 608218,
	icon = 136350,
	splash = 608257,
	mapID = 269,
	seasonFilter = "tbc",
	overview = "The Arcatraz is the satellite prison of the dimensional fortress known as Tempest Keep. Kael'thas Sunstrider has opened many of its cells, unleashing the most dangerous criminals and creatures that were locked away by the naaru. Deep within, the warlock Harbinger Skyriss plots his escape.",
	{
		name = "Zereketh the Unbound",
		defeated = 0,
		encounterID = 20870,
		portrait = 607823,
		loot = {
			{ id = 28373, seasonFilter = "tbc" },
			{ id = 28374, seasonFilter = "tbc" },
			{ id = 28384, seasonFilter = "tbc" },
			{ id = 28375, seasonFilter = "tbc" },
			{ id = 28372, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 20870, 21626 },
		overview = {
			"Zereketh the Unbound is a voidlord imprisoned by the naaru in the Arcatraz. This ethereal creature wields devastating arcane and shadow magic, draining the life essence of those who dare challenge him.",
			{ heading = "Overview" },
			"Zereketh is a straightforward encounter that tests the raid's ability to manage void zones and interrupt key abilities. The fight becomes significantly more dangerous on Heroic difficulty with increased damage and faster void zone spawning.",
			{
				role = DAMAGE,
				"Immediately move out of Void Zones created by {spell:36119}.",
				"Interrupt {spell:36127} whenever possible to reduce raid damage.",
				"Ranged DPS should maintain maximum distance to have more time to react to void zones.",
				"On Heroic difficulty, be prepared for more frequent void zones and higher damage output."
			},
			{
				role = HEALER,
				"Players affected by {spell:36127} will take heavy shadow damage - prepare to heal them quickly.",
				"Keep the tank topped off as {spell:36153} deals significant shadow damage.",
				"Dispel {spell:36127} immediately if possible to reduce damage taken.",
				"Heroic mode requires faster reaction times and more efficient mana management."
			},
			{
				role = TANK,
				"Position Zereketh away from the raid to avoid exposing them to unnecessary damage.",
				"Be prepared to move the boss if void zones appear under your feet.",
				"Use defensive cooldowns when {spell:36153} is cast on you.",
				"Maintain high threat as DPS will be dealing consistent damage throughout the fight."
			}
		},
		abilities = {
			{ spell = 36119, description = "Creates void zones on the ground that deal heavy shadow damage to anyone standing in them. Move out immediately." },
			{ spell = 36127, description = "Deals shadow damage over time to random raid members. Should be interrupted when possible." },
			{ spell = 36153, description = "Shadow Bolt Volley - Deals shadow damage to nearby enemies. Tanks should use defensive cooldowns." },
			{ spell = 39003, description = "Heroic version - Increases all shadow damage by 50%." }
		}
	},
	{
		name = "Dalliah the Doomsayer",
		defeated = 0,
		encounterID = 20885,
		portrait = 607574,
		loot = {
			{ id = 24308, seasonFilter = "tbc" },
			{ id = 28391, seasonFilter = "tbc" },
			{ id = 28390, seasonFilter = "tbc" },
			{ id = 28387, seasonFilter = "tbc" },
			{ id = 28392, seasonFilter = "tbc" },
			{ id = 28386, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 20885, 21590 },
		overview = {
			"Dalliah the Doomsayer is a powerful eredar warlock imprisoned alongside Wrath-Scryer Soccothrates. These two enemies were once allies but now loathe each other. When engaged, both will attack the party simultaneously, creating a chaotic two-boss encounter.",
			{ heading = "Overview" },
			"This is a dual boss encounter where Dalliah fights alongside Wrath-Scryer Soccothrates. The key to success is managing both bosses' abilities simultaneously while controlling their positioning. On Heroic difficulty, their abilities hit significantly harder and require precise coordination.",
			{
				role = DAMAGE,
				"When Dalliah casts {spell:36175}, immediately stop attacking her and switch to Soccothrates.",
				"Interrupt {spell:36173} whenever possible - this heal is powerful and can reset the fight.",
				"Watch for {spell:36175} - Dalliah becomes immune to all attacks during this phase and heals rapidly.",
				"After {spell:36175} ends, switch back to Dalliah and burn her down.",
				"On Heroic, the {spell:39013} ability hits much harder - maintain maximum distance when possible."
			},
			{
				role = HEALER,
				"Be prepared for heavy tank damage when both bosses are active.",
				"During {spell:36175}, focus healing on the Soccothrates tank as he'll be taking all the damage.",
				"The {spell:36173} must be interrupted - if it goes off, be ready to dispel or heal through heavy damage.",
				"Heroic mode requires precise cooldown management during high damage phases.",
				"Keep the raid topped off as {spell:36175} transitions can be deadly."
			},
			{
				role = TANK,
				"Main tank takes Dalliah, off-tank takes Soccothrates.",
				"Position the bosses at least 20 yards apart to avoid overlapping abilities.",
				"When Dalliah uses {spell:36175}, she becomes immune - off-tank must hold Soccothrates alone.",
				"Be ready to quickly re-establish threat on Dalliah when {spell:36175} ends.",
				"Use major defensive cooldowns during {spell:36175} transitions on Heroic difficulty."
			}
		},
		abilities = {
			{ spell = 36173, description = "Heal - Dalliah heals herself for 50% of her health. Must be interrupted." },
			{ spell = 36175, description = "Whirlwind - Dalliah becomes immune to all attacks and spins rapidly, healing herself. Switch to Soccothrates during this phase." },
			{ spell = 36151, description = "Shadow Word: Pain - DoT effect that should be dispelled when possible." },
			{ spell = 39013, description = "Heroic version - Shadow Bolt Volley deals increased shadow damage to all nearby enemies." },
			{ spell = 36183, description = "Soccothrates - Fel Immolation - Fire AoE damage around Soccothrates." },
			{ spell = 35915, description = "Soccothrates - Knock Away - Knocks back the current target and reduces threat." },
			{ spell = 36512, description = "Soccothrates - Heroic Felfire Shock - Powerful fire spell that must be interrupted." }
		}
	},
	{
		name = "Wrath-Scryer Soccothrates",
		defeated = 0,
		encounterID = 20886,
		portrait = 607820,
		loot = {
			{ id = 28396, seasonFilter = "tbc" },
			{ id = 28398, seasonFilter = "tbc" },
			{ id = 28394, seasonFilter = "tbc" },
			{ id = 28393, seasonFilter = "tbc" },
			{ id = 28397, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 20886, 21624 },
		overview = {
			"Wrath-Scryer Soccothrates is a powerful eredar warlock imprisoned alongside Dalliah the Doomsayer. Despite being imprisoned together, these two former allies now despise each other. When engaged, both will attack the party simultaneously, making this a challenging dual encounter.",
			{ heading = "Overview" },
			"This encounter is identical to the Dalliah fight as both bosses are fought together. Soccothrates uses fire-based abilities while Dalliah uses shadow magic. The key is managing both threats while handling Dalliah's immunity phases. See Dalliah's strategy for complete tactics.",
			{
				role = DAMAGE,
				"Primary focus should be on Dalliah - kill her first.",
				"When Dalliah uses {spell:36175}, switch all DPS to Soccothrates.",
				"Interrupt {spell:36512} on Heroic difficulty - this Felfire Shock deals devastating damage.",
				"Stay spread to minimize damage from {spell:36183}.",
				"After Dalliah dies, focus entirely on burning down Soccothrates."
			},
			{
				role = HEALER,
				"Both tanks will take heavy damage throughout this fight.",
				"The {spell:36183} aura deals constant fire damage - keep tanks topped off.",
				"During Dalliah's {spell:36175}, the Soccothrates tank needs extra attention.",
				"Be ready with dispels for any DoT effects.",
				"On Heroic, {spell:36512} can one-shot players - ensure interrupts are assigned."
			},
			{
				role = TANK,
				"Off-tank picks up Soccothrates immediately on pull.",
				"Keep Soccothrates at least 20 yards away from Dalliah to avoid ability overlap.",
				"Watch for {spell:35915} - this knock away will reset your position and threat.",
				"Use fire resistance gear if available on Heroic difficulty.",
				"After the knock back, quickly re-position to avoid exposing the raid to cleaves."
			}
		},
		abilities = {
			{ spell = 36183, description = "Fel Immolation - Constant fire damage aura around Soccothrates. Stay away unless tanking." },
			{ spell = 35915, description = "Knock Away - Knocks back the current target and significantly reduces threat." },
			{ spell = 36512, description = "Heroic - Felfire Shock - Devastating fire damage spell that must be interrupted." },
			{ spell = 36511, description = "Charge - Charges a random player, dealing damage and stunning them." },
			{ spell = 36173, description = "Dalliah - Heal - Dalliah heals herself for 50% health. Must interrupt." },
			{ spell = 36175, description = "Dalliah - Whirlwind - Dalliah becomes immune. Switch all DPS to Soccothrates." },
			{ spell = 39013, description = "Dalliah Heroic - Shadow Bolt Volley deals heavy shadow damage." }
		}
	},
	{
		name = "Harbinger Skyriss",
		defeated = 0,
		encounterID = 20912,
		portrait = 607635,
		loot = {
			{ id = 28406, seasonFilter = "tbc" },
			{ id = 28419, seasonFilter = "tbc" },
			{ id = 28407, seasonFilter = "tbc" },
			{ id = 28418, seasonFilter = "tbc" },
			{ id = 28412, seasonFilter = "tbc" },
			{ id = 28416, seasonFilter = "tbc" },
			{ id = 28415, seasonFilter = "tbc" },
			{ id = 28413, seasonFilter = "tbc" },
			{ id = 28414, seasonFilter = "tbc" },
			{ id = 28231, seasonFilter = "tbc" },
			{ id = 28403, seasonFilter = "tbc" },
			{ id = 28205, seasonFilter = "tbc" },
			{ id = 29241, seasonFilter = "tbc" },
			{ id = 29248, seasonFilter = "tbc" },
			{ id = 29252, seasonFilter = "tbc" },
			{ id = 29360, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 20912, 21599 },
		overview = {
			"Harbinger Skyriss is the final boss of the Arcatraz, a powerful eredar warlock who has masterminded a prison break. He commands devastating shadow magic and summons powerful illusions throughout the encounter. This is one of the most challenging 5-player encounters in The Burning Crusade.",
			{ heading = "Overview" },
			"This multi-phase encounter tests every aspect of your group's coordination. Skyriss summons increasingly powerful adds at specific health thresholds while maintaining constant pressure with mind control and shadow magic. Success requires careful add management, quick reflexes to break mind control, and sustained DPS during burn phases.",
			{
				role = DAMAGE,
				"Phase 1 (100%-66%): Burn Skyriss while avoiding {spell:36924}. When he splits at 66%, kill all four illusions.",
				"Phase 2 (66%-33%): Continue DPS on Skyriss. At 66%, two Arcane Aberrations spawn - kill them immediately.",
				"Phase 3 (33%-0%): At 33%, two Arcane Aberrations spawn again. Kill them, then burn Skyriss.",
				"Breaking {spell:36866} is critical - players must target and attack mind controlled allies to free them.",
				"Interrupt {spell:36924} whenever possible to prevent massive shadow damage.",
				"On Heroic difficulty, the Arcane Aberrations hit much harder and must be killed quickly.",
				"Save cooldowns for the final burn phase after adds are dead."
			},
			{
				role = HEALER,
				"Players affected by {spell:36866} will turn on the raid - prepare to heal mind control targets.",
				"The tank will take heavy damage from both Skyriss and the Arcane Aberrations.",
				"During split phases, spread healing across the raid as illusions deal AoE damage.",
				"{spell:36924} cannot be interrupted every time - be ready to heal through massive shadow damage.",
				"Use major healing cooldowns during Phase 3 when both adds and Skyriss are active.",
				"Heroic mode may require Nature Protection Potions to survive the Arcane Aberration's {spell:36730}."
			},
			{
				role = TANK,
				"Phase 1: Tank Skyriss in the center. At 66%, the illusions will split - gather and tank them together.",
				"Phase 2 & 3: When Arcane Aberrations spawn, quickly pick them up and position away from Skyriss.",
				"Arcane Aberrations must be tanked separately from Skyriss to avoid their {spell:36730} splash damage.",
				"Be prepared for {spell:36866} - if mind controlled, your group must break you out quickly.",
				"Use major defensive cooldowns when both Skyriss and adds are alive.",
				"On Heroic, consider using Nature Protection Potions during Arcane Aberration phases."
			}
		},
		abilities = {
			{ spell = 36866, description = "Mind Rend - Mind controls a random player for 6 seconds. Party members must attack them to break the effect." },
			{ spell = 36924, description = "Mind Flay - Channels a devastating shadow damage spell on the current target. Interrupt when possible." },
			{ spell = 39019, description = "Heroic - Fear - AoE fear effect. Can be broken with tremor totem or fear ward." },
			{ spell = 36659, description = "Skyriss Split - At 66% health, Skyriss splits into four illusions. All must be killed to proceed." },
			{ spell = 36730, description = "Arcane Aberrations - Arcane Buffet - Stacking arcane damage debuff. Tank away from raid." },
			{ spell = 36718, description = "Arcane Aberrations - Arcane Explosion - Large AoE arcane damage. Stay away from adds unless tanking." },
			{ spell = 36698, description = "Illusions - Shadow Bolt Volley - Shadow damage to all nearby enemies during split phase." }
		}
	}
})
