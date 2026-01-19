--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "The Battle for Mount Hyjal",
	instanceID = 534,
	thumbnail = 608198,
	icon = 136330,
	splash = 608237,
	mapID = 329,
	seasonFilter = "tbc",
	overview = "The Battle for Mount Hyjal is a Caverns of Time raid that takes players back to one of Azeroth's most pivotal battles. As the Burning Legion assaults the World Tree Nordrassil, heroes must aid the Alliance and Horde forces in defending the summit. The battle culminates in a confrontation with the pit lord Azgalor and the archimonde Archimonde himself.",
	{
		name = "Rage Winterchill",
		defeated = 0,
		encounterID = 17767,
		portrait = 1385762,
		loot = {
			{ id = 30861, seasonFilter = "tbc" },
			{ id = 30862, seasonFilter = "tbc" },
			{ id = 30863, seasonFilter = "tbc" },
			{ id = 30864, seasonFilter = "tbc" },
			{ id = 30865, seasonFilter = "tbc" },
			{ id = 30866, seasonFilter = "tbc" },
			{ id = 30868, seasonFilter = "tbc" },
			{ id = 30869, seasonFilter = "tbc" },
			{ id = 30870, seasonFilter = "tbc" },
			{ id = 30871, seasonFilter = "tbc" },
			{ id = 30872, seasonFilter = "tbc" },
			{ id = 30873, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 29434, seasonFilter = "tbc" }
		},
		rareLoot = {
			{ id = 32285, seasonFilter = "tbc" },
			{ id = 32289, seasonFilter = "tbc" },
			{ id = 32295, seasonFilter = "tbc" },
			{ id = 32296, seasonFilter = "tbc" },
			{ id = 32297, seasonFilter = "tbc" },
			{ id = 32298, seasonFilter = "tbc" },
			{ id = 32303, seasonFilter = "tbc" },
			{ id = 32307, seasonFilter = "tbc" }
		},
		veryRareLoot = {
			{ id = 32459, seasonFilter = "tbc" }
		},
		extremelyRareLoot = {},
		npcs = { 17767 },
		overview = {
			"A powerful lich serving Archimonde, Rage Winterchill commands legions of undead in the assault on the Alliance base at Hyjal. After defeating 8 waves of undead forces alongside Jaina Proudmoore, the raid must face this frost-wielding commander.",
			{ heading = "Overview" },
			"Rage Winterchill uses devastating frost magic to freeze and damage the raid. Players frozen in {spell:31249} must be broken out immediately by allied DPS. The fight requires constant movement to avoid {spell:31258} and quick response to free frozen allies.",
			{
				role = DAMAGE,
				"Immediately break frozen allies out of {spell:31249} - this is your highest priority.",
				"Spread out to minimize the impact of {spell:31249} hitting multiple players.",
				"Move away from {spell:31258} zones immediately - they deal 15% of maximum health per second.",
				"Melee attackers will be slowed by {spell:31256}, plan your positioning accordingly."
			},
			{
				role = HEALER,
				"Players frozen in {spell:31249} take massive damage and will die in 2-3 seconds if not freed.",
				"Heal frozen players while DPS breaks them out of the ice.",
				"Be ready for spike damage from {spell:31250} freezing melee players in place.",
				"Move away from {spell:31258} zones while maintaining healing assignments."
			},
			{
				role = TANK,
				"Position Rage Winterchill away from the raid to prevent {spell:31250} from hitting ranged players.",
				"Face the boss away from the raid at all times.",
				"Be prepared to move the boss out of {spell:31258} zones.",
				"Your melee attacks will be slowed by {spell:31256}."
			}
		},
		abilities = {
			{ spell = 31249, category = "abilities" },
			{ spell = 31250, category = "abilities" },
			{ spell = 31256, category = "abilities" },
			{ spell = 31258, category = "abilities" }
		}
	},
	{
		name = "Anetheron",
		defeated = 0,
		encounterID = 17808,
		portrait = 1385714,
		loot = {
			{ id = 30874, seasonFilter = "tbc" },
			{ id = 30878, seasonFilter = "tbc" },
			{ id = 30879, seasonFilter = "tbc" },
			{ id = 30880, seasonFilter = "tbc" },
			{ id = 30881, seasonFilter = "tbc" },
			{ id = 30882, seasonFilter = "tbc" },
			{ id = 30883, seasonFilter = "tbc" },
			{ id = 30884, seasonFilter = "tbc" },
			{ id = 30885, seasonFilter = "tbc" },
			{ id = 30886, seasonFilter = "tbc" },
			{ id = 30887, seasonFilter = "tbc" },
			{ id = 30888, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 29434, seasonFilter = "tbc" }
		},
		rareLoot = {
			{ id = 32285, seasonFilter = "tbc" },
			{ id = 32289, seasonFilter = "tbc" },
			{ id = 32295, seasonFilter = "tbc" },
			{ id = 32296, seasonFilter = "tbc" },
			{ id = 32297, seasonFilter = "tbc" },
			{ id = 32298, seasonFilter = "tbc" },
			{ id = 32303, seasonFilter = "tbc" },
			{ id = 32307, seasonFilter = "tbc" }
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17808 },
		overview = {
			"A dreadlord commanding the second wave of the Legion assault, Anetheron leads demonic forces against the Horde encampment. After defeating 8 waves of undead and gargoyles alongside Thrall, the raid must face this powerful demon whose summoned infernals progressively fill the battlefield with fire.",
			{ heading = "Overview" },
			"Anetheron is a positioning-intensive fight where {spell:31299} summons create permanent fire zones that grow throughout the encounter. The battle becomes increasingly difficult as available safe space diminishes. Players must deal with {spell:20669} randomly removing raid members and {spell:31306} dealing heavy shadow damage while reducing healing effectiveness.",
			{
				role = DAMAGE,
				"Focus primary DPS on Anetheron while assigned off-DPS handles {spell:31299} when they are positioned.",
				"Ranged DPS should stay behind the boss to avoid {spell:31306}.",
				"Be prepared to wake sleeping allies by dealing minimal damage to them during {spell:20669}.",
				"Kill {spell:31299} quickly when assigned, but only after they are properly positioned away from the raid."
			},
			{
				role = HEALER,
				"Players hit by {spell:31306} have their healing reduced by 75% for 20 seconds - prioritize them with stronger heals.",
				"During {spell:20669}, some healers will be randomly put to sleep - maintain backup healing assignments.",
				"The fight becomes a healing endurance test as fire zones reduce movement space.",
				"Avoid standing in front of the boss to prevent being hit by {spell:31306}."
			},
			{
				role = TANK,
				"Main tank should hold Anetheron facing away from the raid to prevent {spell:31306} from hitting them.",
				"Off-tanks must pick up each {spell:31299} immediately and tank them away from the raid.",
				"Position {spell:31299} carefully - the fire zones they create are permanent and will limit raid space.",
				"Tank {spell:31299} away from existing fire zones and the main raid group."
			}
		},
		abilities = {
			{ spell = 31306, category = "abilities" },
			{ spell = 20669, category = "abilities" },
			{ spell = 31299, category = "abilities" },
			{ spell = 38196, category = "abilities" }
		}
	},
	{
		name = "Kaz'rogal",
		defeated = 0,
		encounterID = 17888,
		portrait = 1385745,
		loot = {
			{ id = 30889, seasonFilter = "tbc" },
			{ id = 30891, seasonFilter = "tbc" },
			{ id = 30892, seasonFilter = "tbc" },
			{ id = 30893, seasonFilter = "tbc" },
			{ id = 30894, seasonFilter = "tbc" },
			{ id = 30895, seasonFilter = "tbc" },
			{ id = 30914, seasonFilter = "tbc" },
			{ id = 30915, seasonFilter = "tbc" },
			{ id = 30916, seasonFilter = "tbc" },
			{ id = 30917, seasonFilter = "tbc" },
			{ id = 30918, seasonFilter = "tbc" },
			{ id = 30919, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 29434, seasonFilter = "tbc" }
		},
		rareLoot = {
			{ id = 32285, seasonFilter = "tbc" },
			{ id = 32289, seasonFilter = "tbc" },
			{ id = 32295, seasonFilter = "tbc" },
			{ id = 32296, seasonFilter = "tbc" },
			{ id = 32297, seasonFilter = "tbc" },
			{ id = 32298, seasonFilter = "tbc" },
			{ id = 32303, seasonFilter = "tbc" },
			{ id = 32307, seasonFilter = "tbc" }
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17888 },
		overview = {
			"A massive doom lord who commands the third assault wave, Kaz'rogal is one of Archimonde's most brutal commanders. After defeating 8 waves of fel stalkers and undead at the Alliance base, the raid faces this demon whose {spell:31447} creates a unique mana management challenge that defines the entire encounter.",
			{ heading = "Overview" },
			"Kaz'rogal is defined by {spell:31447}, which drains mana from all raid members every 5 seconds. If a player has no mana when the drain occurs, they explode for massive damage to nearby allies. This mechanic requires careful mana management and positioning throughout the fight.",
			{
				role = DAMAGE,
				"All mana users must carefully monitor mana levels and STOP casting before reaching zero mana.",
				"Exploding from {spell:31447} will kill nearby allies - spread out from other raid members.",
				"Use lower rank spells to conserve mana throughout the fight.",
				"Ranged DPS should position behind the boss to avoid {spell:31436}.",
				"Warriors and rogues have a significant advantage as they cannot explode from {spell:31447}."
			},
			{
				role = HEALER,
				"Monitor your mana carefully - stop casting before running out of mana or you will explode.",
				"Spread out from other healers to minimize explosion damage if someone fails to manage mana.",
				"Use lower rank healing spells to extend your mana pool.",
				"Tanks require extra healing when affected by {spell:31477}.",
				"This is primarily a mana management encounter - conserve resources."
			},
			{
				role = TANK,
				"Rotate tanks due to {spell:31477} stacking and reducing melee attack speed.",
				"Position Kaz'rogal facing away from the raid to prevent {spell:31436} from hitting them.",
				"Spread out from the raid to avoid being killed by mana explosions from {spell:31447}.",
				"Be prepared for {spell:36835} stunning all nearby players for 5 seconds."
			}
		},
		abilities = {
			{ spell = 31447, category = "abilities" },
			{ spell = 36835, category = "abilities" },
			{ spell = 31436, category = "abilities" },
			{ spell = 31477, category = "abilities" }
		}
	},
	{
		name = "Azgalor",
		defeated = 0,
		encounterID = 17842,
		portrait = 1385719,
		loot = {
			{ id = 30896, seasonFilter = "tbc" },
			{ id = 30897, seasonFilter = "tbc" },
			{ id = 30898, seasonFilter = "tbc" },
			{ id = 30899, seasonFilter = "tbc" },
			{ id = 30900, seasonFilter = "tbc" },
			{ id = 30901, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 29434, seasonFilter = "tbc" },
			{ id = 31092, seasonFilter = "tbc" },
			{ id = 31093, seasonFilter = "tbc" },
			{ id = 31094, seasonFilter = "tbc" }
		},
		rareLoot = {
			{ id = 32285, seasonFilter = "tbc" },
			{ id = 32289, seasonFilter = "tbc" },
			{ id = 32295, seasonFilter = "tbc" },
			{ id = 32296, seasonFilter = "tbc" },
			{ id = 32297, seasonFilter = "tbc" },
			{ id = 32298, seasonFilter = "tbc" },
			{ id = 32303, seasonFilter = "tbc" },
			{ id = 32307, seasonFilter = "tbc" }
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17842 },
		overview = {
			"Archimonde's lieutenant and a powerful doom lord, Azgalor commands the penultimate assault wave against the World Tree. After defeating 8 waves of fel stalkers and giants alongside Thrall, the raid must face this formidable demon whose abilities create a chaotic battlefield of fire and summoned doomguards.",
			{ heading = "Overview" },
			"Azgalor creates a highly mobile encounter with constant {spell:31340} forcing raid movement and {spell:31347} spawning Lesser Doomguard adds. The fight requires coordination to handle {spell:31344} silence windows and proper add management to prevent being overwhelmed.",
			{
				role = DAMAGE,
				"Constantly move out of {spell:31340} zones - multiple zones will be active simultaneously.",
				"Spread out to minimize being hit by the same {spell:31340}.",
				"Kill Lesser Doomguard adds spawned by {spell:31347} quickly before they overwhelm the raid.",
				"Ranged DPS should stay behind the boss to avoid {spell:31345}.",
				"Plan your casts around {spell:31344}, which silences the entire raid for 8 seconds."
			},
			{
				role = HEALER,
				"Apply heal-over-time effects before {spell:31344} since the 8-second silence prevents all casting.",
				"Constant raid damage from {spell:31340} requires heavy AoE healing.",
				"Be prepared for spike damage when Lesser Doomguard adds from {spell:31347} are active.",
				"The fight requires constant movement - use instant cast heals when possible.",
				"Position to avoid {spell:31340} while maintaining line of sight to the raid."
			},
			{
				role = TANK,
				"Main tank should face Azgalor away from the raid to prevent {spell:31345} from hitting them.",
				"Off-tanks must immediately pick up Lesser Doomguard adds spawned by {spell:31347}.",
				"Position adds away from the main raid group.",
				"Be constantly ready to move Azgalor out of {spell:31340} zones.",
				"Coordinate with healers for {spell:31344} silence windows."
			}
		},
		abilities = {
			{ spell = 31340, category = "abilities" },
			{ spell = 31341, category = "abilities" },
			{ spell = 31344, category = "abilities" },
			{ spell = 31347, category = "abilities" },
			{ spell = 31345, category = "abilities" }
		}
	},
	{
		name = "Archimonde",
		defeated = 0,
		encounterID = 17968,
		portrait = 1385716,
		loot = {
			{ id = 30902, seasonFilter = "tbc" },
			{ id = 30903, seasonFilter = "tbc" },
			{ id = 30904, seasonFilter = "tbc" },
			{ id = 30905, seasonFilter = "tbc" },
			{ id = 30906, seasonFilter = "tbc" },
			{ id = 30907, seasonFilter = "tbc" },
			{ id = 30908, seasonFilter = "tbc" },
			{ id = 30909, seasonFilter = "tbc" },
			{ id = 30910, seasonFilter = "tbc" },
			{ id = 30911, seasonFilter = "tbc" },
			{ id = 30912, seasonFilter = "tbc" },
			{ id = 30913, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 29434, seasonFilter = "tbc" },
			{ id = 31095, seasonFilter = "tbc" },
			{ id = 31096, seasonFilter = "tbc" },
			{ id = 31097, seasonFilter = "tbc" }
		},
		rareLoot = {
			{ id = 32285, seasonFilter = "tbc" },
			{ id = 32289, seasonFilter = "tbc" },
			{ id = 32295, seasonFilter = "tbc" },
			{ id = 32296, seasonFilter = "tbc" },
			{ id = 32297, seasonFilter = "tbc" },
			{ id = 32298, seasonFilter = "tbc" },
			{ id = 32303, seasonFilter = "tbc" },
			{ id = 32307, seasonFilter = "tbc" }
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17968 },
		overview = {
			"The supreme commander of the Burning Legion's forces, Archimonde leads the assault on the World Tree personally. One of the most powerful eredar demons, he seeks to destroy Nordrassil and drain its power. This climactic encounter requires every raid member to use Tears of the Goddess to survive {spell:32014} and masterfully kite {spell:31944} while avoiding catastrophic deaths near the boss that empower him through {spell:32053}.",
			{ heading = "Overview" },
			"Archimonde is a complex encounter testing individual player skill and raid coordination. Players must survive {spell:32014} by using Tears of the Goddess, kite {spell:31944} without touching the deadly fire, and avoid dying near the boss which grants him devastating {spell:32053} stacks. At 10% health, {spell:31984} begins killing one raid member every second in a brutal DPS race.",
			{
				role = DAMAGE,
				"When hit by {spell:32014}, immediately use your Tears of the Goddess item to gain slow fall before landing.",
				"If you have {spell:31944} chasing you, kite it in large circles away from the raid - touching it means death.",
				"Do not cross paths with other {spell:31944} fires while kiting your own.",
				"Maximum DPS is required - at 10% health, {spell:31984} kills one player every second.",
				"Use Heroism or Bloodlust at 10-15% health for the final burn phase.",
				"If you die, do NOT release near Archimonde - deaths near him grant {spell:32053} stacks that increase his damage by 50% per stack."
			},
			{
				role = HEALER,
				"Players affected by {spell:31972} require immediate burst healing as it drains health and mana.",
				"Random fears from {spell:31970} will create gaps in healing coverage - maintain overlapping assignments.",
				"Heavy raid-wide damage throughout the encounter requires strong AoE healing.",
				"Use your Tears of the Goddess when hit by {spell:32014} to survive the fall.",
				"Kite any {spell:31944} assigned to you in large circles away from other fire trails.",
				"The room progressively fills with {spell:31944} - positioning becomes critical as the fight continues."
			},
			{
				role = TANK,
				"Rotate tanks when affected by {spell:31972} debuff.",
				"Keep Archimonde positioned away from where raid members die to prevent {spell:32053} stacks.",
				"Tank swaps must be clean - any deaths near the boss will likely cause a wipe.",
				"Use your Tears of the Goddess when hit by {spell:32014}.",
				"Be prepared to kite {spell:31944} while maintaining threat.",
				"At 10%, maximum threat generation is required as {spell:31984} begins the execute phase."
			}
		},
		abilities = {
			{ spell = 32014, category = "abilities" },
			{ spell = 31944, category = "abilities" },
			{ spell = 32053, category = "abilities" },
			{ spell = 31972, category = "abilities" },
			{ spell = 31970, category = "abilities" },
			{ spell = 31984, category = "abilities" }
		}
	}
})
