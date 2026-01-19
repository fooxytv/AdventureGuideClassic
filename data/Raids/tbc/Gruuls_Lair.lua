--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Gruul's Lair",
	instanceID = 565,
	thumbnail = 1396582,
	icon = 136337,
	splash = 1396501,
	mapID = 330,
	seasonFilter = "tbc",
	overview = "Gruul's Lair is a two-boss raid located in the Blade's Edge Mountains. The gronn lord Gruul has claimed this mountain citadel as his own, enslaving ogres and lesser gronn to serve him. Known as 'Dragonkiller,' Gruul has slain countless dragons and poses a significant threat to the Outland.",
	{
		name = "High King Maulgar",
		defeated = 0,
		encounterID = 18831,
		portrait = 1378985,
		loot = {
			{ id = 28801, seasonFilter = "tbc" }, -- Malefic Mask of the Shadows
			{ id = 28800, seasonFilter = "tbc" }, -- Hammer of the Naaru
			{ id = 28795, seasonFilter = "tbc" }, -- Bladespire Warbands
			{ id = 28796, seasonFilter = "tbc" }, -- Malefic Girdle
			{ id = 28797, seasonFilter = "tbc" }, -- Cloak of the Pit Stalker
			{ id = 28810, seasonFilter = "tbc" }, -- Bloodmaw Magus-Blade
			{ id = 29763, seasonFilter = "tbc" }, -- Karazhan Signet Ring
			{ id = 28799, seasonFilter = "tbc" }  -- Belt of Divine Inspiration
		},
		sharedLoot = {
			{ id = 29764, seasonFilter = "tbc" }, -- Leggings of the Fallen Champion (Tier 4 token)
			{ id = 29765, seasonFilter = "tbc" }, -- Leggings of the Fallen Defender (Tier 4 token)
			{ id = 29766, seasonFilter = "tbc" }  -- Leggings of the Fallen Hero (Tier 4 token)
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18831, 18832, 18834, 18835, 18836 },
		overview = {
			"The ogre leader of Gruul's forces, Maulgar commands an elite council of powerful ogres who guard the entrance to the gronn's inner sanctum. This is a complex multi-tank council fight requiring careful positioning, interrupt rotations, and precise kill order execution.",
			{ heading = "Overview" },
			"High King Maulgar is accompanied by four elite council members that must be controlled and killed in a specific order. The fight requires 5 tanks minimum, excellent interrupt coordination on Blindeye the Seer's heals, and careful management of crowd control on adds. The kill order is critical: Blindeye > Krosh > Olm > Kiggler > Maulgar.",
			{
				role = TANK,
				"Main tank takes High King Maulgar in the center. Assign off-tanks to each council member.",
				"A warrior tank should tank Blindeye the Seer to use {spell:23920} to reflect his {spell:33152} back at him.",
				"Maulgar tank must move away during {spell:33238} to avoid damage.",
				"Position Maulgar with tank's back to a wall to prevent knockback from {spell:33230}.",
				"Position council members away from each other to prevent chain reactions from AoE abilities."
			},
			{
				role = HEALER,
				"Assign healers to specific tanks - each tank will need dedicated healing.",
				"Heavy tank damage increases when Maulgar reaches 50% health and gains {spell:33232}.",
				"Be prepared for raid damage from {spell:33061} and fear effects from {spell:16508}.",
				"Mana management is critical - this is a long fight with constant heavy damage.",
				"Do not stand in melee range to avoid {spell:33238}, {spell:33061}, and {spell:16508}."
			},
			{
				role = DAMAGE,
				"Kill order is absolutely critical: Blindeye the Seer > Olm the Summoner > Krosh Firehand > Kiggler the Crazed > High King Maulgar.",
				"Interrupt rotation on Blindeye's {spell:33152} is the highest priority - missed interrupts will cause a wipe.",
				"Mages must use Spellsteal on Krosh Firehand's {spell:33054} to remove his magic damage reduction buff.",
				"Kill or crowd control Wild Fel Stalkers from Olm - warlocks can Enslave Demon, Banish, or Fear them.",
				"Kiggler the Crazed can be crowd controlled with {spell:19386} or {spell:710}.",
				"Spread out to minimize damage from {spell:33061} and {spell:33237}.",
				"At 50% health, Maulgar gains {spell:33232} and begins using {spell:26561} and {spell:16508}."
			}
		},
		abilities = {
			{ spell = 33238, desc = "High King Maulgar whirls around, dealing weapon damage to all nearby enemies. Tank must kite during this ability." },
			{ spell = 33230, desc = "Mighty Blow - a powerful strike that deals weapon damage plus 139-161 to an enemy, knocking them back. Can be mitigated by tanking against a wall." },
			{ spell = 39144, desc = "Arcing Smash - frontal cone attack that deals weapon damage plus 125 to enemies in a cone in front of Maulgar." },
			{ spell = 33232, desc = "Flurry - at 50% health, increases Maulgar's physical damage by 200 and melee attack speed by 200%." },
			{ spell = 26561, desc = "Berserker Charge - Maulgar charges a random raid member, knocking them back and dealing weapon damage plus 300." },
			{ spell = 16508, desc = "Intimidating Roar - incapacitates the main tank for 4 seconds and causes nearby enemies to flee in terror for 8 seconds." },
			{ spell = 33051, desc = "Krosh Firehand hurls a massive fireball dealing heavy fire damage to a single target." },
			{ spell = 33061, desc = "Krosh Firehand creates a wave of flame that damages and knocks back all nearby enemies." },
			{ spell = 33054, desc = "Krosh Firehand shields himself, becoming immune to spell damage. Must be dispelled immediately." },
			{ spell = 33131, desc = "Olm the Summoner summons a Wild Fel Stalker (Felhunter) every 60 seconds. Must be killed, enslaved, banished, or feared." },
			{ spell = 33129, desc = "Olm casts Dark Decay, a stacking debuff that deals shadow damage over time." },
			{ spell = 33130, desc = "Olm casts Death Coil on a random raid member, dealing shadow damage and causing them to flee for 3 seconds." },
			{ spell = 33144, desc = "Blindeye the Seer casts Heal on himself or allies, healing for 46250-53750 health." },
			{ spell = 33175, desc = "Kiggler the Crazed casts Arcane Shock, interrupting spellcasting for 5 seconds." },
			{ spell = 33173, desc = "Kiggler transforms his current target into a sheep with Greater Polymorph. Non-dispellable." },
			{ spell = 33237, desc = "Kiggler casts Arcane Explosion, an area-of-effect spell that knocks back nearby players." },
			{ spell = 33152, desc = "Blindeye the Seer channels Prayer of Healing, healing all nearby allies for 92500-107500 health. 4 second cast. MUST be interrupted or the fight will be unwinnable." },
			{ spell = 33147, desc = "Blindeye shields an ally, absorbing damage. Can be dispelled but interrupts are higher priority." }
		}
	},
	{
		name = "Gruul the Dragonkiller",
		defeated = 0,
		encounterID = 19044,
		portrait = 1378982,
		loot = {
			{ id = 28830, seasonFilter = "tbc" }, -- Dragonspine Trophy
			{ id = 28815, seasonFilter = "tbc" }, -- Cowl of Nature's Breath
			{ id = 28824, seasonFilter = "tbc" }, -- Gauntlets of Martial Perfection
			{ id = 28822, seasonFilter = "tbc" }, -- Teeth of Gruul
			{ id = 28828, seasonFilter = "tbc" }, -- Gronn-Stitched Girdle
			{ id = 28827, seasonFilter = "tbc" }, -- Gauntlets of Cruel Intention
			{ id = 28823, seasonFilter = "tbc" }, -- Axe of the Gronn Lords
			{ id = 28825, seasonFilter = "tbc" }, -- Aldori Legacy Defender
			{ id = 28810, seasonFilter = "tbc" }, -- Windshear Boots
			{ id = 28826, seasonFilter = "tbc" }, -- Shuriken of Negation
			{ id = 28804, seasonFilter = "tbc" }  -- Collar of Cho'gall
		},
		sharedLoot = {
			{ id = 29764, seasonFilter = "tbc" }, -- Leggings of the Fallen Champion (Tier 4 token)
			{ id = 29765, seasonFilter = "tbc" }, -- Leggings of the Fallen Defender (Tier 4 token)
			{ id = 29766, seasonFilter = "tbc" }  -- Leggings of the Fallen Hero (Tier 4 token)
		},
		rareLoot = {
			{ id = 32837, seasonFilter = "tbc" }  -- Warglaive of the Defender (very rare drop)
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19044 },
		overview = {
			"The gronn overlord of Blade's Edge Mountains, Gruul earned his title by slaying countless dragons. His immense size and power make him one of the most fearsome beings in Outland. This is an intense DPS race and execution check requiring precise positioning, perfect spreading mechanics, and careful movement to avoid cave-ins.",
			{ heading = "Overview" },
			"Gruul the Dragonkiller is a single-target encounter with a strict enrage timer via his stacking {spell:36300} buff. The fight tests raid awareness through {spell:33525} and {spell:33654} mechanics that require precise spreading, {spell:36240} zones that must be avoided, and {spell:36297} that disrupts all spellcasting. This is a pure execution fight with zero margin for positioning errors.",
			{
				role = TANK,
				"Main tank and off-tank must both maintain high threat. The off-tank will take {spell:33813} strikes every 8 seconds.",
				"{spell:33813} hits the second-highest threat target in melee range for 12,350-13,650 physical damage - an off-tank is mandatory.",
				"Both tanks should use defensive cooldowns when {spell:36300} stacks get high.",
				"Position Gruul facing away from the raid to prevent {spell:39171} from hitting raid members.",
				"Do not move Gruul unnecessarily - keep him stationary to help melee position correctly.",
				"Save defensive cooldowns for later in the fight when {spell:36300} stacks increase damage significantly."
			},
			{
				role = HEALER,
				"{spell:36297} silences the entire raid for 4 seconds occasionally - top off tanks and apply HoTs before it hits.",
				"Tank damage increases dramatically with each {spell:36300} stack - be ready to use all healing cooldowns in the final phase.",
				"After each {spell:33525}, players receive {spell:33572} stacks and must spread out before {spell:33652} stuns them.",
				"Raid members who fail to spread properly before {spell:33654} will cause massive damage - be ready for emergency healing.",
				"Watch for {spell:36240} zones and move from cave-ins while maintaining healing.",
				"Mana conservation is critical early - this is a long fight with increasing damage."
			},
			{
				role = DAMAGE,
				"This is a strict DPS race - {spell:36300} stacks every 30 seconds, increasing Gruul's damage by 15% per stack.",
				"Spread at least 12-15 yards apart BEFORE each {spell:33525} cast to avoid clustering after knockback.",
				"After {spell:33525}, you receive {spell:33572} stacks. Quickly spread to at least 12 yards from other players before {spell:33654}.",
				"If players are too close when {spell:33654} triggers after {spell:33652}, they will take massive damage and likely die.",
				"Move away from {spell:36240} falling rocks immediately - they create persistent damage zones.",
				"{spell:36297} silences the entire raid for 4 seconds - use instant abilities during this time.",
				"Melee DPS should position behind Gruul but be ready to spread quickly for {spell:33525}.",
				"Ranged DPS should pre-spread around the room while maintaining maximum damage output."
			}
		},
		abilities = {
			{ spell = 36300, desc = "Every 30 seconds, Gruul grows in size and power, increasing his damage by 15% per stack. This is the soft enrage mechanic." },
			{ spell = 33813, desc = "Gruul strikes the second-highest threat target for massive physical damage. Requires a dedicated off-tank to absorb these hits." },
			{ spell = 33525, desc = "Gruul slams the ground, knocking back the entire raid and applying Gronn Lord's Grasp. Players must spread before being Stoned." },
			{ spell = 33572, desc = "Gronn Lord's Grasp - stacking debuff applied by Ground Slam that reduces movement speed by 20% per stack, stacks up to 5 times." },
			{ spell = 33652, desc = "Stoned - after Gronn Lord's Grasp reaches 5 stacks, players are stunned for a brief moment before Shatter occurs." },
			{ spell = 33654, desc = "Shatter - shatters all Stoned players, dealing massive damage to players based on proximity. Players must be 12+ yards apart." },
			{ spell = 36240, desc = "Cave In - randomly targeted areas where rocks fall, dealing 2700 base damage every 3 seconds in the affected area." },
			{ spell = 36297, desc = "Reverberation - zone-wide silence for 4 seconds that occurs occasionally. Cannot be dispelled but can be resisted." },
			{ spell = 39171, desc = "Gruul cleaves targets in front of him. Tank must face Gruul away from the raid." }
		}
	}
})
