--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.
]]

select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Auchenai Crypts",
	instanceID = 558,
	thumbnail = 608193,
	icon = 136350,
	splash = 608232,
	mapID = 256,
	seasonFilter = "tbc",
	overview = "Auchenai Crypts is a sacred burial ground in the Bone Wastes of Terokkar Forest. Once a peaceful resting place for draenei dead, it has been corrupted by the Shadow Council. Death cultists now perform dark rituals within, raising the dead to serve their masters.",
	{
		name = "Shirrak the Dead Watcher",
		defeated = 0,
		encounterID = 17371,
		portrait = 607771,
		loot = {
			{ id = 25964, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27410, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27408, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 26055, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27409, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27865, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27846, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27847, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27493, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27845, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27866, seasonFilter = "tbc", difficulty = "heroic" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18371 },
		overview = {
			"Shirrak the Dead Watcher is an undead monstrosity that guards the crypts of Auchindoun. Once a draenei defender, he was corrupted by dark magic and now commands legions of skeletal minions. His presence radiates necrotic energy that slowly drains the life from all who dare enter his domain.",
			{ heading = "Overview" },
			"Shirrak is a straightforward encounter with two primary mechanics to manage. Focus Blast targets random players with a powerful arcane damage beam that must be avoided. The room is filled with Focus Fire orbs that pulse AoE damage - players can use line of sight to prevent damage from these orbs. Kill the skeletal adds that spawn periodically while maintaining damage on Shirrak. Heroic mode adds {spell:32861} which significantly increases raid damage.",
			{
				role = DAMAGE,
				"Focus your damage on Shirrak while being aware of spawning skeletal adds.",
				"Move away from {spell:32300} - this focused beam will kill players caught in it.",
				"Use the pillars and Shirrak's body to line of sight the Focus Fire orbs around the room.",
				"Kill Raise Dead skeletons quickly when they spawn, then return to Shirrak.",
				"In Heroic mode, {spell:32861} deals heavy AoE shadow damage to the entire party every few seconds."
			},
			{
				role = HEALER,
				"Prepare for constant AoE damage from the Focus Fire orbs throughout the room.",
				"Players hit by {spell:32300} will need immediate emergency healing.",
				"Dispel {spell:32314} from party members - this increases spell damage taken.",
				"In Heroic mode, {spell:32861} requires constant group healing throughout the fight.",
				"Watch for players who fail to line of sight the orbs - they will take heavy damage."
			},
			{
				role = TANK,
				"Position Shirrak away from the party to give ranged DPS room to work.",
				"Use Shirrak's body as line of sight to block Focus Fire orb damage.",
				"Pick up Raise Dead skeleton adds as they spawn.",
				"Face Shirrak away from the group to prevent {spell:32300} from hitting multiple targets.",
				"In Heroic mode, defensive cooldowns help survive the increased damage from {spell:32861}."
			}
		},
		abilities = {}
	},
	{
		name = "Exarch Maladaar",
		defeated = 0,
		encounterID = 18373,
		portrait = 607600,
		loot = {
			{ id = 27416, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27412, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27413, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27411, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27415, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27414, seasonFilter = "tbc", difficulty = "normal" },
			{ id = 27867, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27870, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27523, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27871, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27869, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 27872, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29354, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29257, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29244, seasonFilter = "tbc", difficulty = "heroic" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18373, 18478 },
		overview = {
			"Exarch Maladaar was once a noble leader of the draenei, overseeing the burial rites of his people. When the Shadow Council invaded Auchindoun, they corrupted and enslaved him, forcing him to command armies of undead against his will. Now he guards the deepest chambers of the crypts, forever bound to serve the darkness he once fought against.",
			{ heading = "Overview" },
			"Exarch Maladaar presents a challenging two-phase encounter that tests both single-target damage and add management. In Phase 1, deal with {spell:32346} which steals player health, and handle the {spell:32424} adds that spawn periodically. At 25% health, Maladaar summons his Avatar of the Martyred which must be burned down quickly. The Avatar has high health and deals heavy melee damage. Heroic mode adds {spell:32361} which inflicts raid-wide shadow damage over time.",
			{
				role = DAMAGE,
				"Phase 1: Burn Maladaar while quickly switching to kill {spell:32424} adds as they spawn.",
				"Interrupt or dispel {spell:32346} if possible - it steals health from random players.",
				"Save DPS cooldowns for Phase 2 when the Avatar of the Martyred spawns at 25%.",
				"Phase 2: All DPS must focus fire the Avatar - it has high health and will kill the tank without fast execution.",
				"In Heroic mode, {spell:32361} deals constant shadow damage to all party members throughout the fight."
			},
			{
				role = HEALER,
				"Players affected by {spell:32346} will need immediate healing as their health is drained.",
				"The {spell:32424} adds deal shadow damage - keep the party topped off.",
				"Phase 2 requires heavy tank healing - the Avatar hits extremely hard.",
				"In Heroic mode, {spell:32361} adds constant raid damage that requires sustained AoE healing.",
				"Consider saving healing cooldowns for Phase 2 when tank damage spikes significantly."
			},
			{
				role = TANK,
				"Tank Maladaar in place and pick up {spell:32424} adds as they spawn.",
				"At 25% health, Maladaar will summon Avatar of the Martyred - immediately establish threat.",
				"The Avatar deals crushing melee damage - use defensive cooldowns.",
				"Position adds away from party members to avoid cleave damage.",
				"In Heroic mode, the combination of {spell:32361} and Avatar melee damage requires careful cooldown management."
			}
		},
		abilities = {}
	}
})
