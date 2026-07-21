--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Shattered Halls",
	instanceID = 540,
	thumbnail = 608207,
	icon = 136350,
	splash = 608246,
	mapID = 246,
	seasonFilter = "tbc",
	overview = "The Shattered Halls is the training ground and headquarters of the fel orc armies in Hellfire Citadel. Kargath Bladefist personally oversees the brutal training regimen that transforms orcs into bloodthirsty warriors. The halls echo with the screams of those who fail to meet his exacting standards.",
	{
		name = "Grand Warlock Nethekurse",
		defeated = 0,
		encounterID = 16807,
		portrait = 607624,
		loot = {
			{ id = 24312, seasonFilter = "tbc" },
			{ id = 27519, seasonFilter = "tbc" },
			{ id = 27517, seasonFilter = "tbc" },
			{ id = 27521, seasonFilter = "tbc" },
			{ id = 27520, seasonFilter = "tbc" },
			{ id = 27518, seasonFilter = "tbc" },
			{ id = 21525, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16807, 17084 },
		overview = {
			"Grand Warlock Nethekurse is a powerful fel orc warlock who commands both shadow magic and demonic forces. He is accompanied by Lesser Shadow Fissures and demonstrates his mastery over shadow and fire magic. This encounter tests your group's ability to manage add spawns while dealing with a variety of shadow-based attacks.",
			{ heading = "Overview" },
			"Nethekurse begins the encounter behind a barrier, during which Lesser Shadow Fissures spawn and must be killed. Once the barrier drops, engage Nethekurse directly. He uses {spell:30496} to deal heavy shadow damage and should be interrupted. At 20% health, Nethekurse transitions into a dangerous phase where he channels {spell:30500}, healing himself while dealing massive damage to the party. Dispel {spell:30502} debuffs quickly to prevent raid wipes.",
			{
				role = DAMAGE,
				"During the initial phase, kill all Lesser Shadow Fissures before engaging Nethekurse.",
				"Interrupt {spell:30496} whenever possible to reduce shadow damage to the tank.",
				"Focus maximum damage on Nethekurse when he begins channeling {spell:30500} at 20% health.",
				"The Dark Spin phase is a DPS race - burn through his healing to finish him quickly.",
				"On Heroic difficulty, Shadow Bolt Volley hits much harder and interrupts are critical.",
				"Stay spread to minimize the impact of AoE shadow abilities."
			},
			{
				role = HEALER,
				"Dispel {spell:30502} from affected party members immediately - this is your top priority.",
				"During the first phase, manage damage from Shadow Fissures while keeping the party topped off.",
				"The {spell:30500} phase at 20% deals heavy party-wide damage - use major cooldowns.",
				"Keep the tank heavily topped off as Shadow Bolt hits very hard.",
				"On Heroic difficulty, mana efficiency is critical as this can be a lengthy fight.",
				"Be prepared to use group healing abilities during the Dark Spin phase."
			},
			{
				role = TANK,
				"Allow the DPS to clear Lesser Shadow Fissures before engaging Nethekurse.",
				"Maintain solid threat while facing Nethekurse away from the party.",
				"Use defensive cooldowns during the {spell:30500} phase to survive heavy damage.",
				"Pick up any remaining Shadow Fissures if they are still alive when the barrier drops.",
				"Position Nethekurse in the center of the room for optimal party positioning.",
				"On Heroic difficulty, consider using major defensive cooldowns early and often."
			}
		},
		abilities = {}
	},
	{
		name = "Blood Guard Porung",
		defeated = 0,
		encounterID = 20923,
		portrait = 607556,
		loot = {
			{ id = 30709, seasonFilter = "tbc" },
			{ id = 30707, seasonFilter = "tbc" },
			{ id = 30708, seasonFilter = "tbc" },
			{ id = 30705, seasonFilter = "tbc" },
			{ id = 30710, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 20923 },
		overview = {
			"Blood Guard Porung is an optional boss encounter found in the gauntlet section of The Shattered Halls. This elite fel orc warrior commands exceptional combat prowess and leads groups of fel orc soldiers. While defeating Porung is not required to complete the dungeon, he guards valuable loot and presents a significant challenge to those who dare face him.",
			{ heading = "Overview" },
			"Blood Guard Porung is accompanied by multiple fel orc adds including Shattered Hand Heathen, Shattered Hand Reaver, and Shattered Hand Archer. The encounter requires careful crowd control and focus fire to manage the numerous enemies. Porung himself uses {spell:36023} which can be deadly if not properly managed. Clear the surrounding gauntlet carefully before engaging to avoid overwhelming pulls.",
			{
				role = DAMAGE,
				"Use crowd control abilities on as many adds as possible before the pull.",
				"Focus fire on one add at a time based on the tank's kill order.",
				"Interrupt caster mobs to prevent heavy spell damage to the party.",
				"Save Bloodlust/Heroism for when Porung is isolated from his guards.",
				"Ranged DPS should prioritize Shattered Hand Archers first.",
				"On Heroic difficulty, adds hit significantly harder and CC becomes essential."
			},
			{
				role = HEALER,
				"This encounter involves heavy multi-target damage - be prepared for intense healing.",
				"Keep HoTs rolling on the tank as they will be taking damage from multiple sources.",
				"Dispel any debuffs from party members quickly.",
				"Manage your mana carefully as this can be a war of attrition.",
				"Position yourself to avoid line-of-sight issues with the tank.",
				"On Heroic difficulty, consider using major cooldowns early to prevent deaths."
			},
			{
				role = TANK,
				"Pull Porung and his group carefully - use line of sight to stack them.",
				"Mark kill order clearly and use crowd control markers.",
				"Pick up all adds and establish solid threat before DPS begins.",
				"Face melee mobs away from the party to avoid cleave damage.",
				"Use defensive cooldowns when tanking multiple enemies simultaneously.",
				"Porung hits very hard - save your biggest cooldown for when fighting him alone."
			}
		},
		abilities = {}
	},
	{
		name = "Warbringer O'mrogg",
		defeated = 0,
		encounterID = 16809,
		portrait = 607811,
		loot = {
			{ id = 27525, seasonFilter = "tbc" },
			{ id = 27868, seasonFilter = "tbc" },
			{ id = 27524, seasonFilter = "tbc" },
			{ id = 27526, seasonFilter = "tbc" },
			{ id = 27802, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16809 },
		overview = {
			"Warbringer O'mrogg is a massive two-headed ogre who serves as one of Kargath Bladefist's most powerful lieutenants. His two heads constantly bicker and argue with each other, but they coordinate devastating attacks in battle. O'mrogg's unique dual-nature makes him unpredictable, as each head can cast different abilities simultaneously.",
			{ heading = "Overview" },
			"Warbringer O'mrogg is a challenging encounter that requires careful positioning and awareness of his abilities. His right head uses {spell:30584} to knock players away, while his left head channels {spell:30621} that must be interrupted. He also summons adds periodically that need to be killed quickly. The key mechanic is {spell:30500} which O'mrogg casts on random party members - this devastating ability requires immediate attention and spreading out. Tank him away from the party and maintain awareness of his frontal attacks.",
			{
				role = DAMAGE,
				"Interrupt {spell:30621} immediately when cast - this is critical to survival.",
				"Kill adds that spawn as quickly as possible before returning focus to O'mrogg.",
				"Spread out to minimize the impact of {spell:30500} on the party.",
				"Melee DPS should position behind O'mrogg to avoid {spell:30584}.",
				"Use defensive cooldowns if you are targeted by {spell:30500}.",
				"On Heroic difficulty, all abilities hit significantly harder and interrupts are mandatory.",
				"Ranged DPS should maintain maximum distance while staying spread."
			},
			{
				role = HEALER,
				"Keep the entire party topped off - {spell:30500} can quickly kill low-health targets.",
				"Prepare for heavy tank damage when adds are active.",
				"Dispel any debuffs from party members quickly.",
				"Position yourself at maximum range to safely heal while avoiding abilities.",
				"On Heroic difficulty, {spell:30584} can one-shot cloth wearers if they get hit.",
				"Manage mana efficiently as this fight has high sustained healing requirements.",
				"Be ready to spot-heal anyone affected by {spell:30500} immediately."
			},
			{
				role = TANK,
				"Tank O'mrogg facing away from the party to prevent {spell:30584} from hitting them.",
				"Pick up adds immediately when they spawn and maintain solid threat.",
				"Use defensive cooldowns during add phases when taking damage from multiple sources.",
				"Position O'mrogg near the center of the room to give party members room to spread.",
				"Call out when {spell:30621} is being cast so interrupts can be coordinated.",
				"On Heroic difficulty, O'mrogg hits extremely hard - rotate defensive cooldowns throughout.",
				"Be prepared to reposition if the party needs to move for mechanics."
			}
		},
		abilities = {}
	},
	{
		name = "Warchief Kargath Bladefist",
		defeated = 0,
		encounterID = 16808,
		portrait = 607812,
		loot = {
			{ id = 27527, seasonFilter = "tbc" },
			{ id = 27529, seasonFilter = "tbc" },
			{ id = 27534, seasonFilter = "tbc" },
			{ id = 27533, seasonFilter = "tbc" },
			{ id = 27538, seasonFilter = "tbc" },
			{ id = 27540, seasonFilter = "tbc" },
			{ id = 27536, seasonFilter = "tbc" },
			{ id = 27537, seasonFilter = "tbc" },
			{ id = 27531, seasonFilter = "tbc" },
			{ id = 27474, seasonFilter = "tbc" },
			{ id = 27528, seasonFilter = "tbc" },
			{ id = 27535, seasonFilter = "tbc" },
			{ id = 29255, seasonFilter = "tbc" },
			{ id = 29263, seasonFilter = "tbc" },
			{ id = 29254, seasonFilter = "tbc" },
			{ id = 29348, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16808, 16805, 17264 },
		overview = {
			"Warchief Kargath Bladefist is the brutal commander of the Shattered Hand clan and the final boss of the Shattered Halls. A legendary warrior who severed his own hand and replaced it with a deadly blade, Kargath is a master of combat who tests prisoners in his arena. This multi-phase encounter combines add management, positioning challenges, and intense single-target damage requirements.",
			{ heading = "Overview" },
			"Kargath Bladefist is a three-phase encounter that begins in his arena. Phase 1: Fight waves of Shattered Hand Gladiators, Shattered Hand Reavers, and Shattered Hand Assassins. After clearing four waves of adds, Kargath himself enters the arena. Phase 2: Kargath uses {spell:30471} to charge random party members and follows up with {spell:30474}. He periodically casts {spell:36023} which stacks and can become deadly. At approximately 20% health, Kargath activates {spell:36031}, increasing his attack speed dramatically. Phase 3: The soft enrage - burn him down quickly before the entire party is overwhelmed. Tank him facing away from the party and be ready to pick him up after each Blade Dance.",
			{
				role = DAMAGE,
				"Phase 1: Focus fire on one add at a time following the kill order: Assassins > Reavers > Gladiators.",
				"Use crowd control on extra adds to prevent being overwhelmed.",
				"Phase 2: Stack together to bait {spell:30471} charges in a safe direction.",
				"When Kargath uses {spell:30474}, spread out immediately and run away from him.",
				"Maximum DPS during Blade Dance - this is your burn window.",
				"Phase 3: At 20%, use Bloodlust/Heroism and all offensive cooldowns.",
				"On Heroic difficulty, {spell:30474} will likely kill anyone caught in it - movement is mandatory.",
				"Interrupt any caster adds in Phase 1 to reduce party damage."
			},
			{
				role = HEALER,
				"Phase 1: Keep the tank topped off while managing damage on the party from multiple adds.",
				"Be ready for burst damage when Assassins use their stealth openers.",
				"Phase 2: Top off anyone who gets hit by {spell:30471} immediately.",
				"During {spell:30474}, position yourself to maintain line of sight while avoiding the whirlwind.",
				"Dispel {spell:36023} from the tank when stacks get dangerously high.",
				"Phase 3: {spell:36031} causes massive tank damage - use all major healing cooldowns.",
				"On Heroic difficulty, consider pre-shielding or using damage reduction abilities before charges.",
				"Mana conservation in Phase 1 is critical to have resources for the intense final phases."
			},
			{
				role = TANK,
				"Phase 1: Pick up adds as they spawn and position them for efficient cleave damage.",
				"Mark kill priorities clearly - Assassins are the highest threat.",
				"Use area-of-effect threat abilities to maintain aggro on multiple adds.",
				"Phase 2: Immediately regain threat on Kargath after each {spell:30471} charge.",
				"Tank Kargath facing away from the party at all times.",
				"When {spell:30474} begins, run away to avoid the whirlwind - let him reset position.",
				"Phase 3: Use all defensive cooldowns when {spell:36031} activates.",
				"On Heroic difficulty, {spell:36031} can quickly overwhelm - coordinate external defensive cooldowns.",
				"Position Kargath with space behind you so the party can spread for Blade Dance."
			}
		},
		abilities = {}
	}
})
