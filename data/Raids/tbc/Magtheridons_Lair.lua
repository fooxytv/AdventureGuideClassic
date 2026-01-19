--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Magtheridon's Lair",
	instanceID = 544,
	thumbnail = 1396585,
	icon = 136340,
	splash = 1396504,
	mapID = 331,
	seasonFilter = "tbc",
	overview = "Deep within Hellfire Citadel lies the prison of the pit lord Magtheridon. Once the ruler of Outland, he was defeated and imprisoned by Illidan and his forces. The fel orcs now drain his blood to create more of their kind, keeping him in a weakened but still dangerous state. Freeing or slaying him could shift the balance of power in Outland.",
	{
		name = "Magtheridon",
		defeated = 0,
		encounterID = 17257,
		portrait = 1378996,
		loot = {
			{ id = 28789, seasonFilter = "tbc" },
			{ id = 28777, seasonFilter = "tbc" },
			{ id = 28780, seasonFilter = "tbc" },
			{ id = 28770, seasonFilter = "tbc" },
			{ id = 28775, seasonFilter = "tbc" },
			{ id = 28776, seasonFilter = "tbc" },
			{ id = 28779, seasonFilter = "tbc" },
			{ id = 28778, seasonFilter = "tbc" },
			{ id = 28781, seasonFilter = "tbc" },
			{ id = 28774, seasonFilter = "tbc" },
			{ id = 28773, seasonFilter = "tbc" },
			{ id = 28772, seasonFilter = "tbc" },
			{ id = 28771, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 29753, seasonFilter = "tbc" },
			{ id = 29754, seasonFilter = "tbc" },
			{ id = 29755, seasonFilter = "tbc" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17257, 17256 },
		overview = {
			"Once the ruler of Outland, Magtheridon was defeated by Illidan Stormrage and imprisoned by Illidan's servants. The fel orcs now drain his blood to create fel orcs, keeping the pit lord in eternal torment. This single-boss encounter is famous for its unique cube-clicking mechanic requiring precise raid coordination.",
			{ heading = "Overview" },
			"This encounter begins with five Hellfire Channelers that must be killed within 20 seconds of each other to minimize their stacking buff. After the channelers die, Magtheridon becomes active. The fight's defining mechanic is {spell:30616}, which must be interrupted by having five players simultaneously click the Manticron Cubes positioned around the room. Failure to interrupt this ability will wipe the raid. Players must spread out to avoid chaining {spell:30757} damage, and at 30% health the encounter becomes a burn race as the ceiling begins to collapse.",
			{
				role = DAMAGE,
				"During Phase 1, focus on killing all five Hellfire Channelers within 20 seconds of each other to prevent their {spell:30531} buff from stacking too high.",
				"Interrupt {spell:30528} whenever possible to prevent channelers from healing.",
				"AoE down the {spell:30511} that spawn when channelers die.",
				"In Phase 2, spread out at least 8 yards apart to avoid chaining {spell:30757} to other raid members.",
				"Watch for {spell:30576} and move out of falling rock indicators during Phase 3.",
				"When {spell:30616} begins casting, assigned clickers must click their cube immediately. Non-clickers continue DPS.",
				"Below 30% health, use all cooldowns as {spell:30576} creates a burn race with constant raid damage."
			},
			{
				role = HEALER,
				"During Phase 1, assign healers to specific tanks holding Hellfire Channelers.",
				"Be prepared for {spell:30510} from the channelers and heavy tank damage.",
				"After Phase 1, maintain healing on the entire raid as {spell:30757} deals significant fire damage.",
				"When {spell:30616} begins, prepare for massive raid damage. Use major healing cooldowns.",
				"Players who click cubes will be stunned and take damage, requiring immediate healing attention.",
				"Below 30%, {spell:30576} deals constant heavy raid damage. Use all healing cooldowns and coordinate with other healers.",
				"Watch for falling debris and be ready to heal players hit by {spell:30632}."
			},
			{
				role = TANK,
				"Phase 1 requires five tanks, each picking up one Hellfire Channeler and keeping them separated at least 30 yards apart.",
				"Position channelers away from the raid to minimize {spell:30510} damage.",
				"Call out when your channeler is ready to die so DPS can coordinate the simultaneous kills.",
				"After channelers die, main tank picks up Magtheridon and positions him in the center of the room.",
				"Face Magtheridon away from the raid to avoid {spell:30619} hitting melee and ranged DPS.",
				"Be prepared to taunt if the other tank gets {spell:30757} to reset the stacking debuff.",
				"During {spell:30616}, maintain threat but focus on survival as raid healing will be stressed.",
				"Below 30%, use all defensive cooldowns to survive {spell:30576} while maintaining threat."
			}
		},
		abilities = {
			{ spell = 30531, name = "Soul Transfer" },
			{ spell = 30528, name = "Dark Mending" },
			{ spell = 30510, name = "Shadow Bolt Volley" },
			{ spell = 30511, name = "Burning Abyssal" },
			{ spell = 30619, name = "Cleave" },
			{ spell = 30757, name = "Conflagration" },
			{ spell = 30616, name = "Blast Nova" },
			{ spell = 30576, name = "Quake" },
			{ spell = 30632, name = "Debris" }
		}
	}
})
