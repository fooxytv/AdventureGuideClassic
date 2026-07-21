--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddRaid({
	name = "Black Temple",
	instanceID = 564,
	thumbnail = 1396579,
	icon = 136328,
	splash = 1396498,
	mapID = 339,
	seasonFilter = "tbc",
	overview = "The Black Temple, once the Temple of Karabor, is now the seat of Illidan Stormrage's power in Outland. From this dark fortress in Shadowmoon Valley, the Betrayer commands his armies of blood elves, naga, and demons. Within its halls, Illidan prepares for a war against the Burning Legion, having consumed the Skull of Gul'dan and transformed into a demon himself.",
	{
		name = "High Warlord Naj'entus",
		defeated = 0,
		encounterID = 22887,
		portrait = 1378986,
		loot = {
			{ id = 32239, seasonFilter = "tbc" },
			{ id = 32240, seasonFilter = "tbc" },
			{ id = 32377, seasonFilter = "tbc" },
			{ id = 32241, seasonFilter = "tbc" },
			{ id = 32234, seasonFilter = "tbc" },
			{ id = 32242, seasonFilter = "tbc" },
			{ id = 32232, seasonFilter = "tbc" },
			{ id = 32243, seasonFilter = "tbc" },
			{ id = 32245, seasonFilter = "tbc" },
			{ id = 32238, seasonFilter = "tbc" },
			{ id = 32247, seasonFilter = "tbc" },
			{ id = 32237, seasonFilter = "tbc" },
			{ id = 32236, seasonFilter = "tbc" },
			{ id = 32248, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 32526, seasonFilter = "tbc" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22887 },
		overview = {
			"A massive sea giant and one of Illidan's elite guards, Naj'entus was torn from the depths and brought to serve at the Black Temple. This encounter revolves around the Impaling Spine mechanic where players must throw the spine back at the boss to trigger a vulnerable shield phase.",
			{ heading = "Overview" },
			"When a player is impaled by {spell:39837}, they must throw the spine item back at Naj'entus to create a Tidal Shield phase. The entire raid must then burn the shield before it wipes the raid with Tidal Burst. Tank swap on high {spell:39872} stacks to prevent the main tank from being overwhelmed.",
			{
				role = DAMAGE,
				"When {spell:39837} targets a player, they will receive a spine item in their inventory. Click it and throw it at Naj'entus immediately.",
				"When Tidal Shield appears after the spine is thrown back, all DPS must burn the shield as quickly as possible.",
				"If the shield is not broken within 10 seconds, {spell:39878} will wipe the raid.",
				"Spread out to minimize raid damage from {spell:39835}."
			},
			{
				role = HEALER,
				"Players hit by {spell:39837} and nearby allies take significant damage. Heal impaled targets immediately.",
				"Prepare for heavy raid-wide damage from {spell:39835} throughout the fight.",
				"During Tidal Shield phase, healing is not required - focus returns when shield breaks.",
				"Main tank will take increasing damage from stacking {spell:39872}."
			},
			{
				role = TANK,
				"Tank Naj'entus facing away from the raid to avoid cleave damage.",
				"Swap tanks when {spell:39872} stacks become too high - this debuff reduces armor significantly.",
				"Position the boss consistently so impaled players can easily throw the spine back.",
				"Be ready to regain threat quickly after the Tidal Shield phase ends."
			}
		},
		abilities = {
			{ spell = 39837, role = DAMAGE },
			{ spell = 39878, role = DAMAGE },
			{ spell = 39835 },
			{ spell = 39872, role = TANK }
		}
	},
	{
		name = "Supremus",
		defeated = 0,
		encounterID = 22898,
		portrait = 1379016,
		loot = {
			{ id = 32256, seasonFilter = "tbc" },
			{ id = 32252, seasonFilter = "tbc" },
			{ id = 32259, seasonFilter = "tbc" },
			{ id = 32251, seasonFilter = "tbc" },
			{ id = 32258, seasonFilter = "tbc" },
			{ id = 32250, seasonFilter = "tbc" },
			{ id = 32260, seasonFilter = "tbc" },
			{ id = 32261, seasonFilter = "tbc" },
			{ id = 32257, seasonFilter = "tbc" },
			{ id = 32254, seasonFilter = "tbc" },
			{ id = 32262, seasonFilter = "tbc" },
			{ id = 32255, seasonFilter = "tbc" },
			{ id = 32253, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 32527, seasonFilter = "tbc" },
			{ id = 32528, seasonFilter = "tbc" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22898 },
		overview = {
			"A massive abyssal demon serving as Illidan's war-mount, Supremus is a towering volcano of destruction. The encounter alternates between a traditional tank and spank phase and a chaotic kite phase every 60 seconds.",
			{ heading = "Overview" },
			"Supremus alternates between two phases every 60 seconds. In Phase 1, tanks manage {spell:40126} by maintaining close threat positions. In Phase 2, the boss fixates on random raid members who must kite while the entire raid avoids fire trails. Movement and fire management are critical to success.",
			{
				role = DAMAGE,
				"In Phase 1, focus damage on Supremus while avoiding {spell:40117} eruptions on the ground.",
				"In Phase 2, continue DPS while moving as a group away from the boss and fire patches.",
				"If you are fixated in Phase 2, run in large circles and never cross your own fire path.",
				"Ranged DPS can continue attacking during both phases while managing movement."
			},
			{
				role = HEALER,
				"In Phase 1, tanks with second-highest threat will take massive damage from {spell:40126}.",
				"Main tank will be knocked back by {spell:40126} and require immediate healing.",
				"In Phase 2, heal the fixated target and manage raid movement together.",
				"Watch for players standing in fire from {spell:40265} or {spell:42052}."
			},
			{
				role = TANK,
				"Phase 1 requires 2-3 tanks staying close in threat to split {spell:40126} damage.",
				"Main tank should be prepared for {spell:40126} knockback and fire damage.",
				"In Phase 2, Supremus ignores threat - stay with the raid and help with positioning.",
				"Do not stand in {spell:40117} volcanic geysers that erupt randomly."
			}
		},
		abilities = {
			{ spell = 40126, role = TANK },
			{ spell = 40117 },
			{ spell = 40265 },
			{ spell = 42052 }
		}
	},
	{
		name = "Shade of Akama",
		defeated = 0,
		encounterID = 22841,
		portrait = 1379011,
		loot = {
			{ id = 32273, seasonFilter = "tbc" },
			{ id = 32270, seasonFilter = "tbc" },
			{ id = 32513, seasonFilter = "tbc" },
			{ id = 32265, seasonFilter = "tbc" },
			{ id = 32271, seasonFilter = "tbc" },
			{ id = 32264, seasonFilter = "tbc" },
			{ id = 32275, seasonFilter = "tbc" },
			{ id = 32276, seasonFilter = "tbc" },
			{ id = 32279, seasonFilter = "tbc" },
			{ id = 32278, seasonFilter = "tbc" },
			{ id = 32263, seasonFilter = "tbc" },
			{ id = 32268, seasonFilter = "tbc" },
			{ id = 32266, seasonFilter = "tbc" },
			{ id = 32361, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22841, 23191 },
		overview = {
			"The embodiment of Akama's broken spirit, kept prisoner by Illidan as insurance against the Broken leader's betrayal. The encounter features two distinct phases: defending against waves of adds while killing channelers, then burning the Shade once it becomes active.",
			{ heading = "Overview" },
			"Phase 1 requires defending against waves of Ashtongue adds from both sides of the room while systematically killing six channelers to break the Shade's protective shield. Phase 2 is a straightforward burn phase with Akama assisting the raid. Kill priority: Spiritbinders > Sorcerers > other adds.",
			{
				role = DAMAGE,
				"In Phase 1, prioritize Ashtongue Spiritbinders (healers) as soon as they spawn.",
				"Kill all six channelers to break the protective shield around the Shade of Akama.",
				"Watch for stealthed Ashtongue Rogues that deal high damage.",
				"In Phase 2, kill Shade Spawns quickly, then burn the Shade of Akama.",
				"Use AoE damage to handle waves of adds efficiently."
			},
			{
				role = HEALER,
				"Phase 1 involves heavy tank damage from waves of adds on both sides.",
				"Dispel and interrupt Ashtongue Sorcerers who cast {spell:39053} and sheep abilities.",
				"Be ready to heal the entire raid from {spell:39309} in Phase 2.",
				"Watch for {spell:29214} which can instantly kill a random player.",
				"Mana conservation is important - Phase 1 can be lengthy."
			},
			{
				role = TANK,
				"Assign tanks to each side of the room to pick up Ashtongue Defenders.",
				"Watch for stealthed Ashtongue Rogues approaching from behind.",
				"Pick up adds quickly to prevent them from reaching healers.",
				"In Phase 2, main tank holds the Shade while off-tanks handle Shade Spawns.",
				"The Shade is not tauntable - maintain consistent threat."
			}
		},
		abilities = {
			{ spell = 39309 },
			{ spell = 29214 },
			{ spell = 39053, role = HEALER }
		}
	},
	{
		name = "Teron Gorefiend",
		defeated = 0,
		encounterID = 22871,
		portrait = 1379018,
		loot = {
			{ id = 32323, seasonFilter = "tbc" },
			{ id = 32329, seasonFilter = "tbc" },
			{ id = 32327, seasonFilter = "tbc" },
			{ id = 32324, seasonFilter = "tbc" },
			{ id = 32328, seasonFilter = "tbc" },
			{ id = 32510, seasonFilter = "tbc" },
			{ id = 32280, seasonFilter = "tbc" },
			{ id = 32512, seasonFilter = "tbc" },
			{ id = 32330, seasonFilter = "tbc" },
			{ id = 32348, seasonFilter = "tbc" },
			{ id = 32326, seasonFilter = "tbc" },
			{ id = 32325, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22871 },
		overview = {
			"The first death knight ever created, Teron Gorefiend is an ancient orc soul bound in a human corpse, serving Illidan in undeath. The defining mechanic of this fight is Shadow of Death, which kills a random player and turns them into a ghost who must kill Shadowy Constructs before they reach the boss.",
			{ heading = "Overview" },
			"Random raid members will be killed by {spell:40251} and become ghosts. As a ghost, you must kill all four Shadowy Constructs that spawn around you before your 60-second timer expires or they reach Gorefiend. If constructs reach the boss, he heals massively. Tanks must swap on high {spell:40239} stacks.",
			{
				role = DAMAGE,
				"When you become a ghost from {spell:40251}, immediately use your ghost abilities to kill all four Shadowy Constructs.",
				"Ghost abilities include Chain Lightning and Fear - use Chain Lightning on cooldown.",
				"You have 60 seconds to kill all constructs before you die permanently.",
				"If constructs reach Teron Gorefiend, he heals for massive amounts.",
				"Continue maximum DPS on the boss when not a ghost.",
				"Avoid standing in {spell:40508} death zones that chase players."
			},
			{
				role = HEALER,
				"Heavy raid-wide damage from {spell:40243} on random players throughout the fight.",
				"You cannot heal players who are ghosts - they must survive on their own.",
				"Main tank takes significant damage from {spell:40239} stacking DoT.",
				"Be prepared for random players to be killed by {spell:40251} - this is intended.",
				"Avoid {spell:40508} zones while maintaining healing assignments."
			},
			{
				role = TANK,
				"Tank swap when {spell:40239} stacks become too high on the current tank.",
				"Position Teron Gorefiend consistently to help raid avoid {spell:40508}.",
				"You may be selected for {spell:40251} - be ready for backup tank to take over.",
				"Maintain threat during transitions and ghost phases.",
				"Keep the boss positioned away from where Shadowy Constructs spawn."
			}
		},
		abilities = {
			{ spell = 40251, role = DAMAGE },
			{ spell = 40239, role = TANK },
			{ spell = 40243 },
			{ spell = 40508 }
		}
	},
	{
		name = "Gurtogg Bloodboil",
		defeated = 0,
		encounterID = 22948,
		portrait = 1378983,
		loot = {
			{ id = 32337, seasonFilter = "tbc" },
			{ id = 32338, seasonFilter = "tbc" },
			{ id = 32340, seasonFilter = "tbc" },
			{ id = 32339, seasonFilter = "tbc" },
			{ id = 32334, seasonFilter = "tbc" },
			{ id = 32342, seasonFilter = "tbc" },
			{ id = 32333, seasonFilter = "tbc" },
			{ id = 32341, seasonFilter = "tbc" },
			{ id = 32335, seasonFilter = "tbc" },
			{ id = 32501, seasonFilter = "tbc" },
			{ id = 32269, seasonFilter = "tbc" },
			{ id = 32344, seasonFilter = "tbc" },
			{ id = 32343, seasonFilter = "tbc" }
		},
		sharedLoot = {
			{ id = 32527, seasonFilter = "tbc" },
			{ id = 32528, seasonFilter = "tbc" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22948 },
		overview = {
			"A massive fel orc commander who rules through brutal strength and bloodthirsty violence. Every 60 seconds, Gurtogg casts Fel Rage on a random raid member, causing them to become the new tank with massively increased health while the entire raid takes heavy damage.",
			{ heading = "Overview" },
			"Every 60 seconds, {spell:40594} targets a random raid member who gains 35k+ HP and becomes the new tank. All healers must switch to healing the Fel Rage target while the entire raid takes massive ticking damage from Fel Geyser. Normal phase involves tank swaps on {spell:40481} stacks and avoiding the frontal {spell:40508}.",
			{
				role = DAMAGE,
				"Continue maximum DPS on Gurtogg Bloodboil throughout all phases.",
				"Every 60 seconds, a random player gets {spell:40594} - if it's you, prepare to tank the boss.",
				"Do not stand in front of the boss to avoid {spell:40508} frontal cone.",
				"The entire raid takes damage from {spell:40491} periodically.",
				"Stay spread to minimize damage from {spell:42005} AoE."
			},
			{
				role = HEALER,
				"During normal phase, focus healing on the main tank who takes stacking {spell:40481} DoT.",
				"Every 60 seconds during {spell:40594}, ALL healers must switch to healing the Fel Rage target.",
				"The entire raid except the Fel Rage target takes massive damage from {spell:40594} during this phase.",
				"Players affected by {spell:40508} will have reduced healing taken - heal them extra.",
				"Heavy mana drain fight - manage cooldowns and mana carefully."
			},
			{
				role = TANK,
				"Main tank during normal phase, tank swap when {spell:40481} stacks become too high.",
				"Tank gets knocked back by {spell:40599} - be ready to reposition.",
				"Face the boss away from the raid to prevent {spell:40508} from hitting raid members.",
				"During {spell:40594} phase, you are not needed - the random target tanks the boss.",
				"Be ready to regain threat when Fel Rage ends and normal phase resumes."
			}
		},
		abilities = {
			{ spell = 40481, role = TANK },
			{ spell = 40599, role = TANK },
			{ spell = 40508 },
			{ spell = 40594, role = HEALER },
			{ spell = 42005 },
			{ spell = 40491 }
		}
	},
	{
		name = "Reliquary of Souls",
		defeated = 0,
		encounterID = 23418,
		portrait = 1385764,
		loot = {
			{ id = 32353, seasonFilter = "tbc" },
			{ id = 32351, seasonFilter = "tbc" },
			{ id = 32347, seasonFilter = "tbc" },
			{ id = 32352, seasonFilter = "tbc" },
			{ id = 32517, seasonFilter = "tbc" },
			{ id = 32346, seasonFilter = "tbc" },
			{ id = 32354, seasonFilter = "tbc" },
			{ id = 32345, seasonFilter = "tbc" },
			{ id = 32349, seasonFilter = "tbc" },
			{ id = 32362, seasonFilter = "tbc" },
			{ id = 32350, seasonFilter = "tbc" },
			{ id = 32332, seasonFilter = "tbc" },
			{ id = 32363, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22856, 23417, 23418 },
		overview = {
			"The tortured, fragmented soul of a naaru, imprisoned and corrupted by Illidan into three aspects of mortal suffering. This fight features three sequential phases that cannot be reversed, each with unique mechanics and challenges. Essence of Suffering, Essence of Desire, and Essence of Anger must all be defeated.",
			{ heading = "Overview" },
			"Three sequential phases with completely different mechanics. Phase 1 (Suffering) reduces healing and requires kiting. Phase 2 (Desire) drains mana and summons adds. Phase 3 (Anger) is a DPS race with stacking damage buff. Mana management is critical - conserve resources in Phase 1 and 2 for the burn in Phase 3.",
			{
				role = DAMAGE,
				"Phase 1: Burn Essence of Suffering before {spell:41292} stacks become overwhelming.",
				"Phase 2: Break the {spell:41431} quickly and kill Spirit Shock adds immediately.",
				"Phase 2: Mana users will be heavily drained by {spell:41350} - use mana potions.",
				"Phase 3: Maximum DPS burn phase - {spell:41305} stacks make this a hard enrage.",
				"Phase 3: Use Heroism/Bloodlust in Phase 3 for the final burn.",
				"Spread out for {spell:41545} to minimize raid damage."
			},
			{
				role = HEALER,
				"Phase 1: Extremely difficult healing due to {spell:41292} reducing all healing done.",
				"Phase 1: {spell:41294} reduces the raid's maximum health - top players off constantly.",
				"Phase 2: Critical mana management - {spell:41350} drains mana from entire raid.",
				"Phase 2: Use {spell:41410} carefully - it reduces damage and healing done.",
				"Phase 3: Constant raid damage from {spell:41337} - heavy AoE healing required.",
				"Save major mana cooldowns for Phase 3 where healing is most intensive."
			},
			{
				role = TANK,
				"Phase 1: When {spell:41303} fixates on you, kite the Essence of Suffering away from raid.",
				"Phase 1: {spell:41292} stacks increase damage - survive as long as possible.",
				"Phase 2: Tank the Essence of Desire and maintain threat through {spell:41431}.",
				"Phase 2: Tank Spirit Shock adds away from the raid when they spawn.",
				"Phase 3: Tank Essence of Anger, taunt off when {spell:41340} fixates on random players.",
				"Phase 3: Heavy raid damage from {spell:41337} aura throughout this burn phase."
			}
		},
		abilities = {
			{ spell = 41303, role = TANK },
			{ spell = 41292 },
			{ spell = 41294 },
			{ spell = 41431, role = DAMAGE },
			{ spell = 41350 },
			{ spell = 41410 },
			{ spell = 41305 },
			{ spell = 41545 },
			{ spell = 41337 },
			{ spell = 41340, role = TANK }
		}
	},
	{
		name = "Mother Shahraz",
		defeated = 0,
		encounterID = 22947,
		portrait = 1379000,
		loot = {
			{ id = 32367, seasonFilter = "tbc" },
			{ id = 32366, seasonFilter = "tbc" },
			{ id = 32365, seasonFilter = "tbc" },
			{ id = 32370, seasonFilter = "tbc" },
			{ id = 32368, seasonFilter = "tbc" },
			{ id = 32369, seasonFilter = "tbc" },
			{ id = 31101, seasonFilter = "tbc" },
			{ id = 31103, seasonFilter = "tbc" },
			{ id = 31102, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22947 },
		overview = {
			"A powerful shivarra demon, one of Illidan's consorts and a master of shadow magic. This encounter has a hard requirement of 250+ shadow resistance on all raid members. The fight features Prismatic Shield, Saber Lash tank stacking, and Fatal Attraction teleport mechanics.",
			{ heading = "Overview" },
			"HARD REQUIREMENT: All raid members need 250+ shadow resistance. Three tanks must stack on the boss to split {spell:40816} damage. When {spell:40869} teleports three players together, they must spread immediately or take massive damage. Switch DPS schools based on {spell:40879} immunities.",
			{
				role = DAMAGE,
				"Shadow resistance is mandatory - 250+ shadow resist required for all raid members.",
				"Mother Shahraz gains immunity to 3 random schools of magic with {spell:40879}.",
				"When {spell:40879} changes, switch to damage types that are not immune.",
				"When hit by {spell:40869}, spread away from other teleported players immediately.",
				"Standing near other teleported players causes massive damage to the entire raid.",
				"Avoid being hit by the six elemental beams that target random players."
			},
			{
				role = HEALER,
				"Shadow resistance is mandatory - 250+ shadow resist required for all raid members.",
				"Extremely heavy raid-wide damage throughout the fight from random beams.",
				"Three tanks stacking for {spell:40816} will take constant heavy damage.",
				"{spell:40823} silences the entire raid periodically - use instant casts during this.",
				"Players hit by {spell:40869} take massive damage if they don't spread quickly.",
				"Six different elemental beams deal heavy damage: shadow, fire, nature, arcane, holy, frost."
			},
			{
				role = TANK,
				"Shadow resistance is mandatory - 250+ shadow resist required for all raid members.",
				"Three tanks must stack directly on Mother Shahraz to split {spell:40816} damage.",
				"If tanks are not stacked, {spell:40816} will one-shot a single tank.",
				"When affected by {spell:40869}, spread away from other teleported players immediately.",
				"Face the boss away from the raid to prevent cleave damage.",
				"Maintain threat while managing positioning for Fatal Attraction teleports."
			}
		},
		abilities = {
			{ spell = 40879, role = DAMAGE },
			{ spell = 40816, role = TANK },
			{ spell = 40869 },
			{ spell = 40823, role = HEALER },
			{ spell = 40827 },
			{ spell = 40860 },
			{ spell = 40861 },
			{ spell = 40862 },
			{ spell = 40863 },
			{ spell = 40864 }
		}
	},
	{
		name = "The Illidari Council",
		defeated = 0,
		encounterID = 23426,
		portrait = 1385743,
		loot = {
			{ id = 32331, seasonFilter = "tbc" },
			{ id = 32519, seasonFilter = "tbc" },
			{ id = 32518, seasonFilter = "tbc" },
			{ id = 32376, seasonFilter = "tbc" },
			{ id = 32373, seasonFilter = "tbc" },
			{ id = 32505, seasonFilter = "tbc" },
			{ id = 31098, seasonFilter = "tbc" },
			{ id = 31100, seasonFilter = "tbc" },
			{ id = 31099, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22949, 22950, 22951, 22952 },
		overview = {
			"Illidan's four most elite lieutenants, each a master of their respective combat discipline, who fight in perfect coordination. All four council members share a health pool and must be kept separated. Gathios (Paladin), Zerevor (Mage), Malande (Priest), and Veras (Rogue) each have unique deadly abilities.",
			{ heading = "Overview" },
			"Four bosses fight simultaneously with shared health pool. Keep council members 40+ yards apart. Interrupt Lady Malande's {spell:41455} at all costs - this is the top priority. Dispel Gathios's {spell:41450} immediately. Kill order typically: Gathios > Malande > Veras > Zerevor, though this varies by raid composition.",
			{
				role = DAMAGE,
				"Keep all four council members separated - they must be 40+ yards apart at all times.",
				"TOP PRIORITY: Interrupt Lady Malande's {spell:41455} - it heals all council members.",
				"Dispel Gathios the Shatterer's {spell:41450} buff immediately or he becomes immune.",
				"Focus DPS on one target at a time following the assigned kill order.",
				"When Veras Darkshadow uses {spell:41476}, he will reappear and {spell:41508} a random player.",
				"Avoid standing in Gathios's {spell:41541} ground effect.",
				"Move away from High Nethermancer Zerevor's {spell:41481} and {spell:41482} AoE zones."
			},
			{
				role = HEALER,
				"Assign healers to specific tanks - each council member needs dedicated healing.",
				"TOP PRIORITY: Interrupt Lady Malande's {spell:41455} - it heals all council members.",
				"Dispel {spell:41475} on tanks immediately - it reduces healing received.",
				"When Veras uses {spell:41476}, the {spell:41508} target needs emergency healing.",
				"Heavy raid damage from Zerevor's {spell:41482}, {spell:41481}, and {spell:41345} abilities.",
				"Players affected by {spell:41475} need extra healing attention."
			},
			{
				role = TANK,
				"Assign one tank per council member - keep them separated 40+ yards apart.",
				"Tank Gathios the Shatterer: face away from raid, watch for {spell:41468} stun.",
				"Tank High Nethermancer Zerevor: move out of his AoE abilities quickly.",
				"Tank Lady Malande: position for interrupts on {spell:41455}.",
				"Tank Veras Darkshadow: maintain threat, he will {spell:41476} and {spell:41508} random players.",
				"Never let council members get close to each other or they gain massive buffs."
			}
		},
		abilities = {
			{ spell = 41455, role = DAMAGE },
			{ spell = 41450, role = DAMAGE },
			{ spell = 41468 },
			{ spell = 41541 },
			{ spell = 41481 },
			{ spell = 41482 },
			{ spell = 41345 },
			{ spell = 41476 },
			{ spell = 41508, role = HEALER },
			{ spell = 41475, role = HEALER }
		}
	},
	{
		name = "Illidan Stormrage",
		defeated = 0,
		encounterID = 22917,
		portrait = 1378987,
		loot = {
			{ id = 32524, seasonFilter = "tbc" },
			{ id = 32525, seasonFilter = "tbc" },
			{ id = 32235, seasonFilter = "tbc" },
			{ id = 32521, seasonFilter = "tbc" },
			{ id = 32497, seasonFilter = "tbc" },
			{ id = 32483, seasonFilter = "tbc" },
			{ id = 32496, seasonFilter = "tbc" },
			{ id = 32837, seasonFilter = "tbc" },
			{ id = 32838, seasonFilter = "tbc" },
			{ id = 31089, seasonFilter = "tbc" },
			{ id = 31091, seasonFilter = "tbc" },
			{ id = 31090, seasonFilter = "tbc" },
			{ id = 32471, seasonFilter = "tbc" },
			{ id = 32500, seasonFilter = "tbc" },
			{ id = 32374, seasonFilter = "tbc" },
			{ id = 32375, seasonFilter = "tbc" },
			{ id = 32336, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 22917, 23089, 23375 },
		overview = {
			"The Betrayer himself, once a night elf hero who sacrificed everything for power. The climactic encounter of The Burning Crusade features five complex phases with different mechanics. This fight requires 3-4 tanks, precise Shadow Demon handling, Flame of Azzinoth management, and coordinated positioning for Maiev's traps.",
			{ heading = "Overview" },
			"Five-phase encounter with 25-minute berserk timer. Phase 1 (100-65%): Tank rotation for {spell:41032}, kill {spell:41117} adds. Phase 2 (65-30%): Kill Flames of Azzinoth, kite {spell:39908}. Phase 3: Return to Phase 1 mechanics. Phase 4 (30%): Demon form, spread for {spell:40631}. Phase 5: Position Illidan in Maiev's traps, maximum burn.",
			{
				role = DAMAGE,
				"Phase 1: TOP PRIORITY - Kill {spell:41117} adds before they reach their targets.",
				"Phase 1: Avoid {spell:40832} fire patches on the ground.",
				"Phase 2: Burn both Flames of Azzinoth simultaneously at opposite sides of the room.",
				"Phase 2: Designated kiter must run from {spell:39908} beam in large circles.",
				"Phase 3: Same as Phase 1 - kill {spell:41117} adds and avoid {spell:41126}.",
				"Phase 4: Spread out for {spell:40631} AoE fire damage around random players.",
				"Phase 5: Maximum DPS when Illidan is trapped by Maiev - use all cooldowns.",
				"Throughout all phases, players chased by {spell:41117} must kite them while DPS kills them."
			},
			{
				role = HEALER,
				"Phase 1: Heavy tank damage from {spell:41032} - tanks rotate frequently.",
				"Phase 1: Players targeted by {spell:41117} need immediate healing if demons reach them.",
				"Phase 2: Raid spread damage from {spell:39908} and {spell:40637}.",
				"Phase 2: Both Flame tanks need heavy healing due to fire aura damage.",
				"Phase 3: Same healing requirements as Phase 1 plus {spell:41126} DoT on random players.",
				"Phase 4: Heavy raid damage from {spell:40631} and {spell:40585}.",
				"Phase 5: Maintain healing while raid burns boss in Maiev's trap.",
				"Long fight with heavy mana requirements - manage mana carefully throughout."
			},
			{
				role = TANK,
				"Phase 1: Rotate tanks every {spell:41032} application - need 3-4 tanks total.",
				"Phase 1: {spell:41032} reduces armor by 75% and removes threat - swap immediately.",
				"Phase 2: Two tanks pick up Flames of Azzinoth at opposite sides of the room.",
				"Phase 2: Tank Flames away from each other - they have fire aura that stacks if close.",
				"Phase 3: Resume tank rotation for {spell:41032} as in Phase 1.",
				"Phase 4: Main tank holds demon form - very high damage and {spell:40585}.",
				"Phase 5: Position Illidan into Maiev's trap zones when they appear.",
				"Throughout fight, be ready for {spell:41032} to reset your threat - communicate swaps."
			}
		},
		abilities = {
			{ spell = 41032, role = TANK },
			{ spell = 40832 },
			{ spell = 41117, role = DAMAGE },
			{ spell = 39908 },
			{ spell = 40637 },
			{ spell = 41126 },
			{ spell = 40631 },
			{ spell = 40585, role = HEALER },
			{ spell = 41917 }
		}
	}
})
