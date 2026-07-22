--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddRaid({
	name = "Sunwell Plateau",
	instanceID = 580,
	thumbnail = 1396592,
	icon = 136361,
	splash = 1396511,
	mapID = 335,
	seasonFilter = "tbc",
	overview = "The Sunwell Plateau is the final raid of the Burning Crusade, located on the Isle of Quel'Danas. After Kael'thas Sunstrider's betrayal, he has used the Sunwell to summon the demon lord Kil'jaeden into Azeroth. The blood elves and their allies must retake the Sunwell and prevent the Burning Legion from completing their invasion.",
	{
		name = "Kalecgos",
		defeated = 0,
		encounterID = 24850,
		portrait = 1385744,
		loot = {
			{ id = 34170, seasonFilter = "tbc" },
			{ id = 34386, seasonFilter = "tbc" },
			{ id = 34169, seasonFilter = "tbc" },
			{ id = 34384, seasonFilter = "tbc" },
			{ id = 34168, seasonFilter = "tbc" },
			{ id = 34167, seasonFilter = "tbc" },
			{ id = 34382, seasonFilter = "tbc" },
			{ id = 34166, seasonFilter = "tbc" },
			{ id = 34848, seasonFilter = "tbc" },
			{ id = 34851, seasonFilter = "tbc" },
			{ id = 34852, seasonFilter = "tbc" },
			{ id = 34165, seasonFilter = "tbc" },
			{ id = 34164, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 24850, 24892 },
		overview = {
			"Kalecgos, a blue dragon, is locked in battle with his demonic counterpart Sathrovarr the Corruptor within the Sunwell's arcane energies. This unique encounter splits the raid between two realms: the Dragon Realm where players fight Kalecgos, and the Spectral Realm where players fight Sathrovarr. Victory requires defeating both bosses simultaneously as they share health thresholds.",
			{ heading = "Overview" },
			"The raid must split between two dimensions. {spell:44866} teleports players into the Spectral Realm and spawns portals others can use. Players gain Spectral Exhaustion after 60 seconds in the Spectral Realm, preventing re-entry for 60 seconds. Both bosses must reach 1% at the same time - if one reaches 1% first, they become banished. Requires 3 tanks for proper rotation.",
			{
				role = DAMAGE,
				"Organize into 3-4 rotation teams before the pull, each with tank, healer, and DPS.",
				"Damage both Kalecgos and Sathrovarr evenly - they must reach low health simultaneously.",
				"When {spell:44866} targets you, a portal spawns at your location for others to use.",
				"Watch for {spell:45001} Wild Magic debuffs - some increase threat generation significantly.",
				"In Spectral Realm, stay spread to manage {spell:45032} when it jumps between players.",
				"Use Ice Block, Cloak of Shadows, or Divine Shield to clear dangerous debuffs."
			},
			{
				role = HEALER,
				"Assign healers to rotation teams - each realm needs constant healing coverage.",
				"Players in Dragon Realm take stacking {spell:45018} damage - rotate realms to clear stacks.",
				"In Spectral Realm, {spell:45032} deals escalating shadow damage over 30 seconds.",
				"Dispel {spell:45032} at 15-20 seconds before damage becomes lethal - it jumps to nearby players.",
				"The two realms cannot interact - no cross-realm healing or dispelling is possible.",
				"Both tanks take heavy sustained damage - coordinate healing cooldowns with rotation."
			},
			{
				role = TANK,
				"Three tanks required - one for Kalecgos, two rotating on Sathrovarr due to Spectral Exhaustion.",
				"Kalecgos tank faces boss away from raid to avoid {spell:44799} frontal cone.",
				"Sathrovarr tank must survive {spell:45029} - deals ~9000 shadow damage plus 3-second stun.",
				"Position Kalecgos against a wall to prevent knockbacks from disrupting positioning.",
				"Rotate through Spectral Realm with your team to clear {spell:45018} stacks.",
				"At 10% health, Kalecgos gains {spell:44806} Crazed Rage - burn quickly to avoid wipe."
			}
		},
		abilities = {
			{ spell = 45018, role = TANK },
			{ spell = 44799, role = TANK },
			{ spell = 44866 },
			{ spell = 45032, role = HEALER },
			{ spell = 45029, role = TANK },
			{ spell = 45001 }
		}
	},
	{
		name = "Brutallus",
		defeated = 0,
		encounterID = 24882,
		portrait = 1385722,
		loot = {
			{ id = 34181, seasonFilter = "tbc" },
			{ id = 34180, seasonFilter = "tbc" },
			{ id = 34381, seasonFilter = "tbc" },
			{ id = 34178, seasonFilter = "tbc" },
			{ id = 34177, seasonFilter = "tbc" },
			{ id = 34853, seasonFilter = "tbc" },
			{ id = 34854, seasonFilter = "tbc" },
			{ id = 34855, seasonFilter = "tbc" },
			{ id = 34176, seasonFilter = "tbc" },
			{ id = 34179, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 24882 },
		overview = {
			"Brutallus is a towering pit lord who stands as a pure gear and execution check. This is the most brutal DPS race in Burning Crusade - the entire raid has exactly 6 minutes to kill him before his enrage wipes the raid. There are no complex phases or gimmicks, just raw tanking coordination and maximum DPS output.",
			{ heading = "Overview" },
			"A pure DPS race with a strict 6-minute {spell:26662} timer. Tanks swap after every 3 {spell:45150} casts while managing {spell:45185}. The {spell:45141} debuff doubles in damage every 10 seconds and must be managed by spreading. This fight requires high gear, coordination, and 7-8 healers minimum.",
			{
				role = DAMAGE,
				"This is the hardest DPS check in TBC - use all consumables, buffs, and cooldowns.",
				"Form soak groups behind each tank to split {spell:45150} damage evenly.",
				"If afflicted by {spell:45141}, immediately spread 4-5 yards from other players.",
				"Mages use Ice Block, Rogues use Cloak of Shadows to remove {spell:45141} instantly.",
				"Use Heroism/Bloodlust at the start and Drums throughout the fight.",
				"Maintain maximum DPS - the 6-minute timer is extremely tight for most guilds."
			},
			{
				role = HEALER,
				"Expect extreme healing requirements - bring 7-8 healers minimum.",
				"Tanks swap after every 3 {spell:45150} casts to let debuff stacks expire.",
				"{spell:45141} deals escalating damage, doubling every 10 seconds for 60 seconds.",
				"Focus heavy healing on {spell:45141} targets in the final 10 seconds (3200 dps).",
				"Brutallus cannot perform crushing blows - Feral Druids make excellent tanks here.",
				"At 6 minutes, {spell:26662} hits and the raid wipes in seconds."
			},
			{
				role = TANK,
				"Two tanks required, swapping after every 3 {spell:45150} casts.",
				"{spell:45185} removes {spell:45141} from the tank but reduces armor by 50%.",
				"When Brutallus uses {spell:45185}, the off-tank must taunt immediately.",
				"Position Brutallus center, form V-shape with tanks at top ends, melee at vertex.",
				"Use avoidance/mitigation gear - Brutallus hits extremely hard but cannot crush.",
				"Non-active tank should maximize DPS to help meet the strict enrage timer."
			}
		},
		abilities = {
			{ spell = 45141, role = HEALER },
			{ spell = 45185, role = TANK },
			{ spell = 45150 },
			{ spell = 26662 }
		}
	},
	{
		name = "Felmyst",
		defeated = 0,
		encounterID = 25038,
		portrait = 607673,
		loot = {
			{ id = 34352, seasonFilter = "tbc" },
			{ id = 34188, seasonFilter = "tbc" },
			{ id = 34385, seasonFilter = "tbc" },
			{ id = 34186, seasonFilter = "tbc" },
			{ id = 34383, seasonFilter = "tbc" },
			{ id = 34184, seasonFilter = "tbc" },
			{ id = 34856, seasonFilter = "tbc" },
			{ id = 34857, seasonFilter = "tbc" },
			{ id = 34858, seasonFilter = "tbc" },
			{ id = 34182, seasonFilter = "tbc" },
			{ id = 34185, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 25038 },
		overview = {
			"The reanimated corpse of Madrigosa, the blue dragon who attempted to stop Kil'jaeden's return. Now corrupted and twisted by fel magic, Felmyst guards the Sunwell with devastating breath attacks and encapsulation mechanics. This encounter alternates between ground and air phases with punishing mechanics in both.",
			{ heading = "Overview" },
			"Ground phase (~60 seconds) features {spell:45855} and {spell:45665}. Air phase (~100 seconds) includes {spell:45402} beam chasing players and {spell:45717} mind-control fog covering one-third of the room. Spread raid into 4 groups, each 20 yards apart. Bring 7-8 healers with Priests for Mass Dispel.",
			{
				role = DAMAGE,
				"Spread in 4 groups (1 melee, 3 ranged) at least 20 yards apart for {spell:45665}.",
				"When {spell:45665} targets a player, they pulse 3500 arcane damage per second - run away from them.",
				"Use Ice Block, Cloak of Shadows, or Divine Shield to escape {spell:45665} early.",
				"During air phase, kill Unyielding Dead skeletons spawned by {spell:45402} trails.",
				"When {spell:45717} fog appears, immediately move to the called safe zone or be mind-controlled.",
				"Ranged can continue DPS on Felmyst during air phase when she's in range."
			},
			{
				role = HEALER,
				"Tank takes heavy damage from {spell:19983} cleave and {spell:45866} which doubles physical damage taken.",
				"Coordinate 3 Priests to Mass Dispel their assigned groups when {spell:45855} hits at ~17 seconds.",
				"{spell:45855} deals ~2000 nature damage plus a debuff dealing 3000 damage and draining 1000 mana every 2 seconds.",
				"Players hit by {spell:45665} take sustained damage - heal them while they're levitated.",
				"During air phase, call out safe zones (tree/middle/fire) to avoid {spell:45717} mind-control fog.",
				"Anyone caught in {spell:45717} is instantly mind-controlled and deals 300% increased damage."
			},
			{
				role = TANK,
				"Tank Felmyst facing away from raid to avoid {spell:19983} cleave damage.",
				"Use defensive cooldowns during {spell:45866} which doubles physical damage taken for 10 seconds.",
				"Felmyst is not tauntable - use Misdirection at the pull and watch threat.",
				"No tail swipe - melee can safely stand behind the boss.",
				"During air phase, immediately pick up Unyielding Dead skeleton adds.",
				"Be ready to pick up Felmyst immediately when she lands - threat does not reset."
			}
		},
		abilities = {
			{ spell = 19983, role = TANK },
			{ spell = 45866, role = TANK },
			{ spell = 45855, role = HEALER },
			{ spell = 45665 },
			{ spell = 45402 },
			{ spell = 45717 }
		}
	},
	{
		name = "The Eredar Twins",
		defeated = 0,
		encounterID = 25165,
		portrait = 1390438,
		loot = {
			{ id = 34205, seasonFilter = "tbc" },
			{ id = 34190, seasonFilter = "tbc" },
			{ id = 34210, seasonFilter = "tbc" },
			{ id = 34202, seasonFilter = "tbc" },
			{ id = 34393, seasonFilter = "tbc" },
			{ id = 34209, seasonFilter = "tbc" },
			{ id = 34391, seasonFilter = "tbc" },
			{ id = 34195, seasonFilter = "tbc" },
			{ id = 34392, seasonFilter = "tbc" },
			{ id = 34194, seasonFilter = "tbc" },
			{ id = 34208, seasonFilter = "tbc" },
			{ id = 34390, seasonFilter = "tbc" },
			{ id = 34192, seasonFilter = "tbc" },
			{ id = 34388, seasonFilter = "tbc" },
			{ id = 34193, seasonFilter = "tbc" },
			{ id = 34389, seasonFilter = "tbc" },
			{ id = 35290, seasonFilter = "tbc" },
			{ id = 35291, seasonFilter = "tbc" },
			{ id = 35292, seasonFilter = "tbc" },
			{ id = 34204, seasonFilter = "tbc" },
			{ id = 34189, seasonFilter = "tbc" },
			{ id = 34206, seasonFilter = "tbc" },
			{ id = 34197, seasonFilter = "tbc" },
			{ id = 34199, seasonFilter = "tbc" },
			{ id = 34203, seasonFilter = "tbc" },
			{ id = 34198, seasonFilter = "tbc" },
			{ id = 34196, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 25166, 25165 },
		overview = {
			"Grand Warlock Alythess and Lady Sacrolash are eredar twins serving Kil'jaeden. Lady Sacrolash wields shadow magic while Grand Warlock Alythess commands fire. This encounter requires splitting the raid between two bosses while managing opposing elemental debuffs. The fight becomes significantly easier once the first twin dies.",
			{ heading = "Overview" },
			"Kill Lady Sacrolash (shadow) first while tanking Alythess separately. Requires 3 tanks - two on Sacrolash, one on Alythess. A Warlock tank on Alythess is highly recommended. Key mechanics: {spell:45342} must be avoided at all costs, {spell:45256} causes temporary threat loss, and {spell:45347}/{spell:45348} debuffs must be cleansed by taking opposite element damage.",
			{
				role = DAMAGE,
				"Focus all DPS on Lady Sacrolash (shadow) first - the fight becomes much easier after she dies.",
				"Ranged and healers stand on the ramp lip to avoid several ground-based mechanics.",
				"If targeted by {spell:45342}, immediately run away from all players or use immunity abilities.",
				"Mages use Ice Block, Rogues use Vanish, Paladins use Divine Shield to cancel {spell:45342} cast.",
				"{spell:45347} stacks reduce healing by 5% each - take fire damage to clear the debuff.",
				"After Sacrolash dies, stack behind Alythess and burn her down."
			},
			{
				role = HEALER,
				"This is one of the hardest healing fights in TBC - bring 6-9 healers with strong AoE healing.",
				"Approximately 70% of damage is raid-wide - Restoration Shamans and Holy Priests excel here.",
				"{spell:45342} disorients for 10 seconds and deals 3200 fire damage per second to nearby players.",
				"{spell:46771} targets up to 5 players with ~7800 fire damage over 6 seconds.",
				"{spell:45348} deals 300 damage every 2 seconds - cleared by shadow damage.",
				"Dispel {spell:45230} from Alythess when possible - it increases her fire damage by 35%."
			},
			{
				role = TANK,
				"Three tanks required - two on Sacrolash (main + off for threat drops), one on Alythess.",
				"Sacrolash tank: {spell:45256} deals ~7000 damage and confuses for 6 seconds, dropping threat.",
				"Off-tank on Sacrolash must always be second on threat to pick up boss during confusion.",
				"Alythess tank (preferably Warlock): Position her away from Sacrolash toward the south.",
				"Alythess drops {spell:45235} fire patches on the ground - move her to keep space clear.",
				"After Sacrolash dies, melee stacks behind Alythess while tanks maintain positioning."
			}
		},
		abilities = {
			{ spell = 45256, role = TANK },
			{ spell = 45329 },
			{ spell = 45248 },
			{ spell = 45342 },
			{ spell = 45347, role = HEALER },
			{ spell = 45348, role = HEALER },
			{ spell = 45235, role = TANK },
			{ spell = 46771 },
			{ spell = 45230 }
		}
	},
	{
		name = "M'uru",
		defeated = 0,
		encounterID = 25741,
		portrait = 1385757,
		loot = {
			{ id = 34232, seasonFilter = "tbc" },
			{ id = 34233, seasonFilter = "tbc" },
			{ id = 34399, seasonFilter = "tbc" },
			{ id = 34212, seasonFilter = "tbc" },
			{ id = 34398, seasonFilter = "tbc" },
			{ id = 34211, seasonFilter = "tbc" },
			{ id = 34397, seasonFilter = "tbc" },
			{ id = 34234, seasonFilter = "tbc" },
			{ id = 34408, seasonFilter = "tbc" },
			{ id = 34229, seasonFilter = "tbc" },
			{ id = 34396, seasonFilter = "tbc" },
			{ id = 34228, seasonFilter = "tbc" },
			{ id = 34215, seasonFilter = "tbc" },
			{ id = 34394, seasonFilter = "tbc" },
			{ id = 34240, seasonFilter = "tbc" },
			{ id = 34216, seasonFilter = "tbc" },
			{ id = 34395, seasonFilter = "tbc" },
			{ id = 34213, seasonFilter = "tbc" },
			{ id = 34230, seasonFilter = "tbc" },
			{ id = 35282, seasonFilter = "tbc" },
			{ id = 35283, seasonFilter = "tbc" },
			{ id = 35284, seasonFilter = "tbc" },
			{ id = 34427, seasonFilter = "tbc" },
			{ id = 34430, seasonFilter = "tbc" },
			{ id = 34429, seasonFilter = "tbc" },
			{ id = 34428, seasonFilter = "tbc" },
			{ id = 34214, seasonFilter = "tbc" },
			{ id = 34231, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 25741, 25840 },
		overview = {
			"M'uru, a darkened naaru being drained of its holy essence to fuel the restoration of the Sunwell. This encounter is one of the most complex and demanding in TBC, featuring two distinct phases. Phase 1 involves managing waves of adds while damaging M'uru. Phase 2 transforms into Entropius with a completely different set of deadly mechanics. Precise execution and raid coordination are mandatory.",
			{ heading = "Overview" },
			"Phase 1: M'uru casts {spell:45996} creating void zones and summoning Dark Fiends. Void Sentinels spawn and must be tanked while {spell:46008} chains between players. Phase 2: At M'uru's death, Entropius spawns. Raid must burn him before {spell:46289} becomes overwhelming while avoiding {spell:46282} void zones. One of TBC's hardest encounters.",
			{
				role = DAMAGE,
				"Phase 1: Priority is killing Dark Fiends that spawn from {spell:45996} void zones.",
				"AoE kill Void Spawns before they reach M'uru - if they do, he gains massive damage buff.",
				"Void Sentinels must be burned quickly after tanks position them.",
				"Continue damage on M'uru when add priorities are handled.",
				"Phase 2: Maximum DPS burn on Entropius - this is a strict timer.",
				"Avoid {spell:46282} void zones that spawn during Entropius phase.",
				"Use all cooldowns and Heroism/Bloodlust in Phase 2 for the burn.",
				"Death during Entropius phase likely means a wipe due to the tight timer."
			},
			{
				role = HEALER,
				"Phase 1: Heavy tank damage from multiple Void Sentinels - coordinate healing assignments.",
				"Players hit by {spell:46008} will take chaining shadow damage - heal through it.",
				"Avoid standing in {spell:45996} void zones which prevent healing.",
				"Phase 2: Entire raid takes escalating damage from {spell:46289} aura.",
				"Players hit by {spell:46282} void zones die almost instantly - positioning is critical.",
				"Damage from {spell:46289} increases with each cast - mana management is crucial.",
				"Phase 2 is a healing throughput check with a hard timer - use all mana cooldowns."
			},
			{
				role = TANK,
				"Phase 1: Assign tanks to pick up Void Sentinels as they spawn - usually 2-3 at a time.",
				"Tank Sentinels away from M'uru and stack them for cleave damage.",
				"Humanoid adds (Berserkers) spawn from {spell:45996} portals - off-tanks pick these up.",
				"Do not let Void Spawns reach M'uru - each one buffs his damage significantly.",
				"Phase 2: Main tank holds Entropius in center, move boss away from {spell:46282} zones.",
				"Entropius phase has no tank swaps - single tank burns defensive cooldowns.",
				"Position Entropius to give raid maximum room to spread and avoid void zones."
			}
		},
		abilities = {
			{ spell = 45996 },
			{ spell = 46008 },
			{ spell = 45988 },
			{ spell = 46289 },
			{ spell = 46282, role = DAMAGE }
		}
	},
	{
		name = "Kil'jaeden",
		defeated = 0,
		encounterID = 25315,
		portrait = 1385746,
		loot = {
			{ id = 34241, seasonFilter = "tbc" },
			{ id = 34242, seasonFilter = "tbc" },
			{ id = 34339, seasonFilter = "tbc" },
			{ id = 34405, seasonFilter = "tbc" },
			{ id = 34340, seasonFilter = "tbc" },
			{ id = 34342, seasonFilter = "tbc" },
			{ id = 34406, seasonFilter = "tbc" },
			{ id = 34344, seasonFilter = "tbc" },
			{ id = 34244, seasonFilter = "tbc" },
			{ id = 34404, seasonFilter = "tbc" },
			{ id = 34245, seasonFilter = "tbc" },
			{ id = 34403, seasonFilter = "tbc" },
			{ id = 34333, seasonFilter = "tbc" },
			{ id = 34332, seasonFilter = "tbc" },
			{ id = 34402, seasonFilter = "tbc" },
			{ id = 34343, seasonFilter = "tbc" },
			{ id = 34243, seasonFilter = "tbc" },
			{ id = 34401, seasonFilter = "tbc" },
			{ id = 34345, seasonFilter = "tbc" },
			{ id = 34400, seasonFilter = "tbc" },
			{ id = 34341, seasonFilter = "tbc" },
			{ id = 34334, seasonFilter = "tbc" },
			{ id = 34329, seasonFilter = "tbc" },
			{ id = 34247, seasonFilter = "tbc" },
			{ id = 34335, seasonFilter = "tbc" },
			{ id = 34331, seasonFilter = "tbc" },
			{ id = 34336, seasonFilter = "tbc" },
			{ id = 34337, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {
			{ id = 34346, seasonFilter = "tbc" }
		},
		veryRareLoot = {},
		extremelyRareLoot = {
			{ id = 34347, seasonFilter = "tbc" }
		},
		npcs = { 25315 },
		overview = {
			"Kil'jaeden the Deceiver, lord of the Burning Legion, attempts to enter Azeroth through the Sunwell. This is the final boss of Burning Crusade and one of the most epic encounters in WoW history. The fight features five phases with increasingly complex mechanics, dragon orbs that grant powerful abilities, and a platform covered in darkness. The raid must coordinate perfectly while utilizing special powers granted by the blue dragonflight.",
			{ heading = "Overview" },
			"Five phases of escalating intensity. Use dragon orbs to gain powerful abilities. Phase 1-3: Manage Shield Orbs, {spell:45641} fire blooms, and {spell:46589} shadow spikes while burning adds. Phase 4: {spell:45892} Sinister Reflection copies spawn. Phase 5: All previous mechanics plus {spell:45657} Darkness of a Thousand Souls. Use {spell:45848} from dragon orbs to survive. 25-minute enrage timer.",
			{
				role = DAMAGE,
				"Burn down Hand of the Deceiver adds in Phase 1 before DPS on Kil'jaeden.",
				"Click blue dragon orbs to gain special abilities including {spell:45839} for damage.",
				"Destroy Shield Orbs before they reach Kil'jaeden or he gains immunity.",
				"Spread out to avoid chaining {spell:45641} fire bloom damage between players.",
				"Phase 4: Kill your {spell:45892} Sinister Reflection add immediately - it copies your abilities.",
				"Phase 5: Use {spell:45848} shield from dragon orbs to survive {spell:45657}.",
				"Stay spread to minimize {spell:45641} fire bloom splash damage.",
				"This is a 25-minute enrage encounter - optimize DPS throughout all phases."
			},
			{
				role = HEALER,
				"Massive sustained raid damage throughout all phases - coordinate healing cooldowns.",
				"Players hit by {spell:46589} shadow spike take heavy damage and reduced healing for 10 sec.",
				"{spell:45641} fire blooms deal increasing damage - affected players must spread out.",
				"Use dragon orb {spell:45860} ability to help restore raid mana and health.",
				"Phase 4: Heal players fighting their {spell:45892} reflections - they take significant damage.",
				"Phase 5: Use {spell:45848} to survive {spell:45657} Darkness of a Thousand Souls.",
				"Conserve mana in early phases - this is one of the longest fights in TBC.",
				"Players hit by {spell:46589} have 50% reduced healing - adjust healing accordingly."
			},
			{
				role = TANK,
				"Phase 1-3: Main tank holds Kil'jaeden center, off-tanks pick up Hand of the Deceiver adds.",
				"Tank faces Kil'jaeden away from raid to avoid frontal cone abilities.",
				"Watch for {spell:45442} Soul Flay - high single target damage on the tank.",
				"Use dragon orb {spell:45848} shield ability to survive {spell:45657}.",
				"Phase 2-5: Position boss to give raid maximum space to avoid {spell:45641} fire blooms.",
				"Phase 4: All players including tanks must kill their own {spell:45892} reflections.",
				"Off-tanks should click orbs to gain dragon abilities for raid utility.",
				"Stay aware of {spell:46589} shadow spike targeting - reduced healing makes tanking harder."
			}
		},
		abilities = {
			{ spell = 45641 },
			{ spell = 46589, role = DAMAGE },
			{ spell = 45892, role = DAMAGE },
			{ spell = 45657 },
			{ spell = 45442, role = TANK },
			{ spell = 45848 },
			{ spell = 45839, role = DAMAGE },
			{ spell = 45860, role = HEALER }
		}
	}
})
