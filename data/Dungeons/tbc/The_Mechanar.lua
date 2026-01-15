--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Mechanar",
	instanceID = 554,
	thumbnail = 608218,
	icon = 136350,
	splash = 608257,
	mapID = 265,
	seasonFilter = "tbc",
	overview = "The Mechanar is the manufacturing facility of Tempest Keep, where the naaru once forged weapons and technology. Since Kael'thas seized control, the blood elves have been reverse-engineering naaru technology to create an army of mechanical servants. Pathaleon the Calculator oversees these operations.",
	{
		name = "Mechano-Lord Capacitus",
		defeated = 0,
		encounterID = 19219,
		portrait = 607712,
		loot = {
			{ id = 27902, seasonFilter = "tbc" }, -- Silent Slippers of Meditation
			{ id = 27903, seasonFilter = "tbc" }, -- Lunar Crescent Pauldrons
			{ id = 27904, seasonFilter = "tbc" }, -- Silvermoon Crest Shield
			{ id = 27905, seasonFilter = "tbc" }, -- Peculiar Neurological Apparatus
			{ id = 27906, seasonFilter = "tbc" }, -- Bloodfyre Robes of Annihilation
			{ id = 27907, seasonFilter = "tbc" }, -- Boots of the Glade-Keeper
			{ id = 27744, seasonFilter = "tbc" }, -- Jagged Bark Pendant (Heroic)
			{ id = 27796, seasonFilter = "tbc" }, -- Mithril-Chain of the Auger (Heroic)
			{ id = 27797, seasonFilter = "tbc" }, -- Wastewalker Shoulderpads (Heroic)
			{ id = 27911, seasonFilter = "tbc" }, -- Capacitus' Cloak of Calibration (Heroic)
			{ id = 27908, seasonFilter = "tbc" }, -- Nether Core's Control Ring (Heroic)
			{ id = 27909, seasonFilter = "tbc" }, -- Tidefury Chestpiece (Heroic)
			{ id = 27910, seasonFilter = "tbc" }, -- Silvermoon Signet (Heroic)
			{ id = 28202, seasonFilter = "tbc" }, -- Recoilless Rocket Ripper X-54 (Heroic)
			{ id = 28286, seasonFilter = "tbc" }, -- Weighted Jack-o'-Lantern (Heroic)
			{ id = 28205, seasonFilter = "tbc" }  -- Breastplate of the Bold (Heroic)
		},
		sharedLoot = {
			{ id = 30533, seasonFilter = "tbc" }, -- Vanquisher's Marks
			{ id = 29434, seasonFilter = "tbc" }  -- Badge of Justice
		},
		rareLoot = {
			{ id = 30565, seasonFilter = "tbc" }, -- Assassin's Fire Opal
			{ id = 30566, seasonFilter = "tbc" }, -- Defender's Tanzanite
			{ id = 30564, seasonFilter = "tbc" }  -- Mysterious Fire Opal
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19219 },
		overview = {
			"Mechano-Lord Capacitus is a massive mechanized construct and the first boss of The Mechanar. This encounter tests the group's ability to manage a polarity mechanic where players must alternate between positive and negative charges to avoid devastating raid-wide damage. The fight requires careful coordination and awareness of debuff status.",
			{ heading = "Overview" },
			"The core mechanic of this fight revolves around {spell:35059} and {spell:35060}. Every 20 seconds, Capacitus assigns all raid members either a positive or negative charge. Players with the same charge standing near each other will detonate, causing massive damage. Spread out when you have the same charge as nearby players, and stack when you have opposite charges.",
			{
				role = TANK,
				"Tank Capacitus in a central location to allow maximum space for players to spread during polarity changes.",
				"Be aware of {spell:39088} which deals 250-350 Nature damage every 3 seconds on Normal, or 925-1075 on Heroic.",
				"{spell:35056} deals moderate Physical damage and can be mitigated with armor.",
				"Watch your polarity debuff and position away from other raid members with the same charge.",
				"Capacitus hits for approximately 2,500-3,500 on Normal, 4,500-6,500 on Heroic."
			},
			{
				role = HEALER,
				"Monitor all raid members' polarity debuffs closely - players with matching polarities standing together take exponentially more damage.",
				"Be prepared for raid-wide damage spikes when players fail polarity mechanics.",
				"Top priority is maintaining tank health through consistent melee damage and {spell:39088} ticks.",
				"{spell:35056} strikes will require immediate healing attention on the tank.",
				"Position according to your polarity - avoid standing near other healers with the same charge."
			},
			{
				role = DAMAGE,
				"Watch your debuff bar for {spell:35059} or {spell:35060} indicators.",
				"Immediately move away from other players showing the same polarity icon above their heads.",
				"You can safely stack with players of the opposite polarity without penalty.",
				"Maximum DPS uptime requires pre-positioning before polarity shifts occur.",
				"Ranged DPS should position in a semi-circle to allow easy spreading and stacking.",
				"The polarity shift occurs every 20 seconds - prepare to reposition."
			}
		},
		abilities = {
			{ spell = 35056, heroicSpell = 39194 }, -- Head Crack
			{ spell = 35059 }, -- Reflective Magic Shield (Positive Charge)
			{ spell = 35060 }, -- Reflective Damage Shield (Negative Charge)
			{ spell = 39088 }  -- Nether Charge (Heroic)
		}
	},
	{
		name = "Nethermancer Sepethrea",
		defeated = 0,
		encounterID = 19221,
		portrait = 607725,
		loot = {
			{ id = 27898, seasonFilter = "tbc" }, -- Stellaris
			{ id = 27899, seasonFilter = "tbc" }, -- Shiffar's Nexus-Horn
			{ id = 27900, seasonFilter = "tbc" }, -- Ironstaff of Regeneration
			{ id = 27901, seasonFilter = "tbc" }, -- Blackened Naaru Sliver
			{ id = 27915, seasonFilter = "tbc" }, -- Starfire Waistband
			{ id = 27916, seasonFilter = "tbc" }, -- Collar of the Aldor
			{ id = 27917, seasonFilter = "tbc" }, -- Baba's Cloak
			{ id = 27918, seasonFilter = "tbc" }, -- Bands of Nethekurse
			{ id = 27919, seasonFilter = "tbc" }, -- Redeemer's Legguards
			{ id = 27920, seasonFilter = "tbc" }, -- Mantle of Three Terrors
			{ id = 27921, seasonFilter = "tbc" }, -- Ring of Umbral Doom
			{ id = 27914, seasonFilter = "tbc" }, -- Leggings of the Astromancer (Heroic)
			{ id = 27924, seasonFilter = "tbc" }, -- Sparking Arcanite Ring (Heroic)
			{ id = 27925, seasonFilter = "tbc" }, -- Ravenwing Pauldrons (Heroic)
			{ id = 27912, seasonFilter = "tbc" }, -- Starlight Gauntlets (Heroic)
			{ id = 27913, seasonFilter = "tbc" }, -- Topaz-Studded Battlegrips (Heroic)
			{ id = 28204, seasonFilter = "tbc" }, -- Tunic of the Ranger Lord (Heroic)
			{ id = 28227, seasonFilter = "tbc" }, -- Nethershard (Heroic)
			{ id = 28285, seasonFilter = "tbc" }  -- Mantle of the Mind Flayer (Heroic)
		},
		sharedLoot = {
			{ id = 30533, seasonFilter = "tbc" }, -- Vanquisher's Marks
			{ id = 29434, seasonFilter = "tbc" }  -- Badge of Justice
		},
		rareLoot = {
			{ id = 30565, seasonFilter = "tbc" }, -- Assassin's Fire Opal
			{ id = 30566, seasonFilter = "tbc" }, -- Defender's Tanzanite
			{ id = 30564, seasonFilter = "tbc" }  -- Mysterious Fire Opal
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19221, 19167 }, -- Nethermancer Sepethrea, Ragin' Flames
		overview = {
			"Nethermancer Sepethrea is a blood elf mage and the second boss of The Mechanar. This encounter is a complex multi-phase fight featuring summoned elemental adds, massive AoE fire damage, and a unique mechanic requiring ranged positioning. The fight tests the group's ability to manage dangerous adds while dealing with heavy raid damage.",
			{ heading = "Overview" },
			"This encounter alternates between two distinct phases. During the main phase, Sepethrea summons {spell:35268} elementals that must be quickly eliminated while the group handles {spell:35279} and {spell:35280}. Every 10 seconds, she casts {spell:35250} which summons five Ragin' Flames adds. These adds are immune to all forms of crowd control and must be burned down immediately as they cast {spell:35278} which deals devastating fire damage.",
			{
				role = TANK,
				"Tank Sepethrea against one wall to create space for ranged to kite the Ragin' Flames adds.",
				"Be ready to pick up {spell:35268} elementals when they spawn - they have low health but deal significant melee damage.",
				"Position yourself to avoid {spell:35280} which deals 1850-2150 Fire damage on Normal, 3238-3762 on Heroic.",
				"{spell:35279} deals 463-537 Fire damage every second and can stack - use fire resistance if available.",
				"Ragin' Flames cannot be tanked traditionally as they fixate on random targets and move at 200% speed."
			},
			{
				role = HEALER,
				"Prepare for massive raid-wide damage when Ragin' Flames cast {spell:35278} for 2775-3225 Fire damage on Normal, 4163-4837 on Heroic.",
				"Prioritize healing targets affected by {spell:35279} as the DoT can stack and deals damage every second.",
				"{spell:35268} elementals should be killed immediately - assign DPS to focus them.",
				"Use cooldowns during Ragin' Flames spawn as five adds casting {spell:35278} simultaneously can wipe the group.",
				"Position at maximum range to avoid {spell:35280} and maintain line of sight for healing."
			},
			{
				role = DAMAGE,
				"Immediately switch to {spell:35268} elementals when they spawn - they only have 1,575 HP on Normal, 4,725 HP on Heroic.",
				"When Ragin' Flames spawn via {spell:35250}, all DPS must focus fire and kill them before their {spell:35278} casts complete.",
				"Ragin' Flames have 8,925 HP on Normal, 15,750 HP on Heroic - burn them fast with AoE and single target damage.",
				"Ranged DPS should spread out at maximum range to minimize players hit by {spell:35280}.",
				"The fight is a DPS race - failing to kill Ragin' Flames quickly will result in overwhelming raid damage.",
				"Fire resistance gear is extremely beneficial for this encounter, especially on Heroic difficulty."
			}
		},
		abilities = {
			{ spell = 35250 }, -- Summon Ragin' Flames
			{ spell = 35268 }, -- Inferno
			{ spell = 35278 }, -- Arcane Blast (Ragin' Flames)
			{ spell = 35279, heroicSpell = 39253 }, -- Searing Flames
			{ spell = 35280, heroicSpell = 39189 }  -- Dragon's Breath
		}
	},
	{
		name = "Pathaleon the Calculator",
		defeated = 0,
		encounterID = 19220,
		portrait = 607739,
		loot = {
			{ id = 27892, seasonFilter = "tbc" }, -- Molten Earth Kilt
			{ id = 27893, seasonFilter = "tbc" }, -- Nethershade Boots
			{ id = 27894, seasonFilter = "tbc" }, -- Aethereal Clasp
			{ id = 27895, seasonFilter = "tbc" }, -- Band of the Crystalline Void
			{ id = 27896, seasonFilter = "tbc" }, -- Sigil of the Violet Tower
			{ id = 27897, seasonFilter = "tbc" }, -- Libram of the Eternal Rest
			{ id = 27930, seasonFilter = "tbc" }, -- Bloodfyre Robes of Annihilation
			{ id = 27931, seasonFilter = "tbc" }, -- Midrealm Hat
			{ id = 27932, seasonFilter = "tbc" }, -- Molten Earth Kilt
			{ id = 27933, seasonFilter = "tbc" }, -- Icon of Unyielding Courage
			{ id = 27927, seasonFilter = "tbc" }, -- Greaves of the Shatterer (Heroic)
			{ id = 27928, seasonFilter = "tbc" }, -- Gauntlets of the Chosen (Heroic)
			{ id = 27929, seasonFilter = "tbc" }, -- Mithril Band of the Unscarred (Heroic)
			{ id = 27923, seasonFilter = "tbc" }, -- Nethershard (Heroic)
			{ id = 27926, seasonFilter = "tbc" }, -- Dreamer's Dragonstaff (Heroic)
			{ id = 28206, seasonFilter = "tbc" }, -- Cowl of the Grand Engineer (Heroic)
			{ id = 28203, seasonFilter = "tbc" }, -- Void Slayer's Tunic (Heroic)
			{ id = 28275, seasonFilter = "tbc" }, -- Beast Lord Leggings (Heroic)
			{ id = 28288, seasonFilter = "tbc" }, -- Abacus of Violent Odds (Heroic)
			{ id = 29362, seasonFilter = "tbc" }, -- The Sun Eater (Heroic)
			{ id = 30532, seasonFilter = "tbc" }, -- Kirin Tor Master's Trousers (Heroic)
			{ id = 30533, seasonFilter = "tbc" }  -- Vanquisher's Legplates (Heroic)
		},
		sharedLoot = {
			{ id = 30533, seasonFilter = "tbc" }, -- Vanquisher's Marks
			{ id = 29434, seasonFilter = "tbc" }  -- Badge of Justice
		},
		rareLoot = {
			{ id = 30565, seasonFilter = "tbc" }, -- Assassin's Fire Opal
			{ id = 30566, seasonFilter = "tbc" }, -- Defender's Tanzanite
			{ id = 30564, seasonFilter = "tbc" }  -- Mysterious Fire Opal
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19220, 21230 }, -- Pathaleon the Calculator, Nether Wraith
		overview = {
			"Pathaleon the Calculator is the final boss of The Mechanar and overseer of Kael'thas Sunstrider's mechanized army production. This encounter features mind control mechanics, summoned adds, and devastating arcane abilities. At 20% health, Pathaleon summons three Nether Wraith adds that must be dealt with while finishing the boss.",
			{ heading = "Overview" },
			"This fight revolves around managing {spell:35280} which mind controls random party members, forcing them to attack their allies. The dominated player becomes hostile for 12 seconds and can be crowd controlled or damaged to break the effect. At 20% health, Pathaleon casts {spell:35285} to summon three Nether Wraiths that cannot be tanked and chase random players while casting {spell:34162}.",
			{
				role = TANK,
				"Tank Pathaleon facing away from the group to protect melee DPS from {spell:35314} frontal cone.",
				"When you are affected by {spell:35280}, your healers must heal through your attacks or have DPS crowd control you.",
				"{spell:35314} deals 1850-2150 Arcane damage in a frontal cone on Normal, 5550-6450 on Heroic.",
				"{spell:35059} deals moderate Arcane damage on a 2-second cast timer.",
				"At 20% health, position yourself to allow ranged to kite the three {spell:35285} Nether Wraiths.",
				"Nether Wraiths cannot be tanked and will fixate on random targets - focus on maintaining threat on Pathaleon."
			},
			{
				role = HEALER,
				"Prepare to dispel or heal through {spell:35280} mind control effects - dominated players become hostile for 12 seconds.",
				"Mind controlled players can be crowd controlled with {spell:118}, {spell:2637}, or {spell:1513} to reduce damage.",
				"Alternatively, healing the dominated player's target can keep the victim alive until the mind control expires.",
				"{spell:34162} from Nether Wraiths deals 1850-2150 Arcane damage on Normal, 3700-4300 on Heroic.",
				"At 20% health, prepare for intense healing as three Nether Wraiths spawn and begin casting {spell:34162} simultaneously.",
				"Position to avoid {spell:35314} while maintaining healing range on both tank and dominated players."
			},
			{
				role = DAMAGE,
				"When allies are affected by {spell:35280}, you can either crowd control them or DPS them to 50% health to break the effect early.",
				"Rogues, Mages, and Hunters have excellent tools to control dominated players - assign these classes to handle mind control.",
				"At 20% health when {spell:35285} summons three Nether Wraiths, you must decide whether to burn the boss or kill the adds first.",
				"Nether Wraiths have 23,625 HP on Heroic and cast {spell:34162} repeatedly - they can overwhelm healers if ignored.",
				"Recommended strategy is to burn Pathaleon from 20% to 0% while healers manage Nether Wraith damage.",
				"AoE damage is effective on the Nether Wraiths if your group lacks the DPS to burn through 20% quickly.",
				"Stay spread to minimize players affected by {spell:35314} frontal cone."
			}
		},
		abilities = {
			{ spell = 35059, heroicSpell = 39016 }, -- Arcane Bolt
			{ spell = 35280 }, -- Domination (Mind Control)
			{ spell = 35285 }, -- Summon Nether Wraith
			{ spell = 35314, heroicSpell = 39078 }, -- Mana Tap
			{ spell = 34162 }  -- Arcane Missiles (Nether Wraith)
		}
	}
})
