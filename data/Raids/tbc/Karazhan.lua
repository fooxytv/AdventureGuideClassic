--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Karazhan",
	instanceID = 532,
	thumbnail = 1396584,
	icon = 136343,
	splash = 1396503,
	mapID = 350,
	seasonFilter = "tbc",
	overview = "Karazhan is a 10-player raid dungeon located in Deadwind Pass. Once the home of the great wizard Medivh, this dark tower is now haunted by demons, undead, and the echoes of Medivh's tragic corruption. The tower contains 12 bosses across multiple floors, each presenting unique challenges and mechanics that defined early Burning Crusade raiding.",
	{
		name = "Servant's Quarters",
		encounterID = 16179,
		portrait = 1385766,
		loot = {
			{ id = 30675, seasonFilter = "tbc" },
			{ id = 30676, seasonFilter = "tbc" },
			{ id = 30677, seasonFilter = "tbc" },
			{ id = 30678, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16179, 16180, 16181 },
		overview = {
			"The Servant's Quarters is an optional encounter in Karazhan's basement. One of three random bosses spawns after clearing all trash in the area within 30 minutes: Hyakiss the Lurker (spider), Rokad the Ravager (hound), or Shadikith the Glider (bat). Each boss has unique mechanics but is relatively straightforward.",
			{ heading = "Overview" },
			"Clear all spiders, bats, and hounds in the basement within 30 minutes to spawn one random boss. Hyakiss the Lurker: Dispel {spell:29896} stuns and {spell:29901} poison stacks immediately. Rokad the Ravager: Heavy tank damage from {spell:29906} bleed - heal through it. Shadikith the Glider: Tank against wall, have off-tank ready for {spell:32914} threat drops, dispel {spell:29904} silence from casters.",
			{
				role = DAMAGE,
				"Hyakiss: Spread out to minimize {spell:29901} splash. Kill quickly before poison stacks overwhelm healers.",
				"Rokad: Standard burn fight. Stay behind the boss to avoid frontal attacks.",
				"Shadikith: The farthest player gets charged - assign an off-tank or mail wearer to stand at max range.",
				"Shadikith: Stay spread to minimize {spell:29904} silence hitting multiple casters."
			},
			{
				role = HEALER,
				"Hyakiss: Dispel {spell:29896} web stun immediately. Dispel {spell:29901} poison before stacks get high.",
				"Rokad: Heavy tank healing required - {spell:29906} causes significant bleed damage over 10 seconds.",
				"Shadikith: Dispel {spell:29904} silence from yourself and other healers immediately.",
				"Shadikith: Heal the charge target quickly - hits for 5,000-9,000 damage on cloth."
			},
			{
				role = TANK,
				"Hyakiss: Tank in place. Watch for {spell:29896} stunning you briefly.",
				"Rokad: Use defensive cooldowns during {spell:29906} - the bleed deals heavy damage.",
				"Shadikith: Tank with your back against a wall to prevent knockback from repositioning you.",
				"Shadikith: {spell:32914} drops threat - off-tank must be ready to taunt immediately."
			}
		},
		abilities = {
			{ spell = 29896, role = HEALER },
			{ spell = 29901, role = HEALER },
			{ spell = 29906, role = TANK },
			{ spell = 29904 },
			{ spell = 32914, role = TANK },
			{ spell = 29847 }
		}
	},
	{
		name = "Attumen the Huntsman",
		encounterID = 15550,
		portrait = 1378965,
		loot = {
			{ id = 28477, seasonFilter = "tbc" },
			{ id = 28507, seasonFilter = "tbc" },
			{ id = 28508, seasonFilter = "tbc" },
			{ id = 28453, seasonFilter = "tbc" },
			{ id = 28506, seasonFilter = "tbc" },
			{ id = 28503, seasonFilter = "tbc" },
			{ id = 28454, seasonFilter = "tbc" },
			{ id = 28502, seasonFilter = "tbc" },
			{ id = 28505, seasonFilter = "tbc" },
			{ id = 28509, seasonFilter = "tbc" },
			{ id = 28510, seasonFilter = "tbc" },
			{ id = 28504, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {
			{ id = 30480, seasonFilter = "tbc" }
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15550, 16151 },
		overview = {
			"Attumen the Huntsman is the first boss of Karazhan, patrolling the stables with his ethereal steed Midnight. The encounter begins as a two-phase fight where players first battle Midnight alone, then face Attumen who joins midway. At 25% health, Attumen mounts Midnight creating a single powerful combined enemy.",
			{ heading = "Overview" },
			"Phase 1: Burn down Midnight to 95% health. Phase 2: Attumen joins the fight - tank them together and cleave both. Phase 3: At 25%, they merge into one mounted unit. Tank away from raid to avoid charge damage. Healers prepare for increased tank damage in phase 3.",
			{
				role = DAMAGE,
				"Phase 1: Focus all damage on Midnight.",
				"Phase 2: Use cleave abilities to damage both Midnight and Attumen simultaneously.",
				"Phase 3: Continue full DPS on the mounted Attumen. Ranged stay spread to avoid chaining {spell:29833}.",
				"Melee DPS watch for {spell:29711} and move out quickly."
			},
			{
				role = HEALER,
				"Keep the main tank topped off throughout all phases.",
				"Phase 3 significantly increases tank damage - use major healing cooldowns.",
				"Watch for {spell:29833} damage on ranged players.",
				"Keep HoTs rolling on the tank during the entire encounter."
			},
			{
				role = TANK,
				"Phase 1: Pick up Midnight and tank in place.",
				"Phase 2: Position both Midnight and Attumen together for cleave damage, facing away from the raid.",
				"Phase 3: Tank the mounted boss away from the raid. Prepare for {spell:29711} with defensive cooldowns.",
				"Use major cooldowns during phase 3 when damage is highest."
			}
		},
		abilities = {}
	},
	{
		name = "Moroes",
		encounterID = 15687,
		portrait = 1378999,
		loot = {
			{ id = 28529, seasonFilter = "tbc" },
			{ id = 28570, seasonFilter = "tbc" },
			{ id = 28565, seasonFilter = "tbc" },
			{ id = 28545, seasonFilter = "tbc" },
			{ id = 28567, seasonFilter = "tbc" },
			{ id = 28566, seasonFilter = "tbc" },
			{ id = 28569, seasonFilter = "tbc" },
			{ id = 28530, seasonFilter = "tbc" },
			{ id = 28528, seasonFilter = "tbc" },
			{ id = 28525, seasonFilter = "tbc" },
			{ id = 28568, seasonFilter = "tbc" },
			{ id = 28524, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15687, 19872, 19873, 19874, 19875, 19876, 19877 },
		overview = {
			"Moroes is Karazhan's loyal steward who never abandoned his post even after death. He fights alongside four randomly selected guests from a pool of six possible adds. Each combination presents different challenges with unique abilities. Moroes periodically vanishes and garrotes random players, requiring careful coordination.",
			{ heading = "Overview" },
			"This fight requires crowd control. Assign crowd control to 2-3 of the 4 active guests. Kill guests in order: typically kill the most dangerous uncontrolled add first. Moroes will vanish and apply {spell:34694} to random players - healers must dispel this quickly. Tank Moroes away from crowd-controlled adds.",
			{
				role = DAMAGE,
				"Assist with crowd control if your class can (Polymorph, Shackle, Trap).",
				"Focus fire on kill targets in the assigned order.",
				"Do NOT break crowd control with AoE abilities.",
				"When affected by {spell:34694}, stop DPS and let healers dispel you.",
				"Interrupt heal casts from Lord Crispin Ference if he is active."
			},
			{
				role = HEALER,
				"Dispel {spell:34694} immediately - it does massive damage over time.",
				"Keep crowd control targets in your peripheral vision but do not heal them.",
				"{spell:34694} targets need urgent attention - they take heavy DoT damage.",
				"Manage mana carefully as this is a long fight with sustained damage."
			},
			{
				role = TANK,
				"Main tank picks up Moroes immediately.",
				"Off-tanks pick up the four guests and position them for crowd control.",
				"Do not tank near crowd-controlled adds.",
				"When Moroes vanishes, maintain threat by continuing to attack when he returns.",
				"Watch for {spell:34653} which can be deadly - use cooldowns when vanish occurs."
			}
		},
		abilities = {}
	},
	{
		name = "Maiden of Virtue",
		encounterID = 16457,
		portrait = 1378997,
		loot = {
			{ id = 28511, seasonFilter = "tbc" },
			{ id = 28515, seasonFilter = "tbc" },
			{ id = 28517, seasonFilter = "tbc" },
			{ id = 28514, seasonFilter = "tbc" },
			{ id = 28521, seasonFilter = "tbc" },
			{ id = 28520, seasonFilter = "tbc" },
			{ id = 28519, seasonFilter = "tbc" },
			{ id = 28512, seasonFilter = "tbc" },
			{ id = 28518, seasonFilter = "tbc" },
			{ id = 28516, seasonFilter = "tbc" },
			{ id = 28523, seasonFilter = "tbc" },
			{ id = 28522, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16457 },
		overview = {
			"The Maiden of Virtue is a ghostly figure radiating holy energy that tests the raid's positioning and movement. This is a gear and execution check that requires precise spacing and quick reactions to avoid her devastating holy abilities. There are no adds or phases - just pure mechanical execution.",
			{ heading = "Overview" },
			"Spread out at least 10 yards apart before pull. Stay spread throughout the fight. When Maiden casts {spell:29511}, run far away (40+ yards) immediately. When {spell:29522} is cast, stop all casting and movement or take massive damage. This is a simple but precise fight - perfect positioning wins.",
			{
				role = DAMAGE,
				"Maintain 10+ yards distance from all other raid members at all times.",
				"When {spell:29511} is cast, run away from Maiden immediately to 40+ yards.",
				"During {spell:29522}, STOP all actions - do not cast, do not move, do not attack.",
				"Return to the boss quickly after {spell:29522} ends to maximize DPS uptime.",
				"Ranged DPS can continue attacking during {spell:29511} if positioned correctly."
			},
			{
				role = HEALER,
				"Stay spread 10+ yards from all raid members.",
				"During {spell:29522}, STOP all casting immediately or you will die.",
				"Prepare for heavy raid damage after {spell:29522} ends.",
				"Keep HoTs active but stop casting new spells during {spell:29522}.",
				"Run far during {spell:29511} - healing can wait until you're safe."
			},
			{
				role = TANK,
				"Tank Maiden near her spawn position.",
				"Maintain 10+ yards from all other raid members while keeping threat.",
				"During {spell:29522}, stop all attacks and movement.",
				"Run away during {spell:29511} - threat is meaningless if you're dead.",
				"Use cooldowns during high damage phases after {spell:29522}."
			}
		},
		abilities = {}
	},
	{
		name = "Opera Hall",
		encounterID = 16812,
		portrait = 1385758,
		loot = {
			{ id = 28586, seasonFilter = "tbc" },
			{ id = 28585, seasonFilter = "tbc" },
			{ id = 28587, seasonFilter = "tbc" },
			{ id = 28588, seasonFilter = "tbc" },
			{ id = 28594, seasonFilter = "tbc" },
			{ id = 28591, seasonFilter = "tbc" },
			{ id = 28589, seasonFilter = "tbc" },
			{ id = 28593, seasonFilter = "tbc" },
			{ id = 28590, seasonFilter = "tbc" },
			{ id = 28592, seasonFilter = "tbc" },
			{ id = 28582, seasonFilter = "tbc" },
			{ id = 28583, seasonFilter = "tbc" },
			{ id = 28584, seasonFilter = "tbc" },
			{ id = 28581, seasonFilter = "tbc" },
			{ id = 28578, seasonFilter = "tbc" },
			{ id = 28579, seasonFilter = "tbc" },
			{ id = 28572, seasonFilter = "tbc" },
			{ id = 28573, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17535, 17521, 17534 },
		overview = {
			"The Opera Event is one of three random encounters: Wizard of Oz, Red Riding Hood, or Romulo & Julianne. Each week the event changes randomly. All three versions drop the same loot but have completely different mechanics. Raids must be prepared for all three variations.",
			{ heading = "Overview" },
			"Check which event is active before engaging. Wizard of Oz: Kill Dorothee first, dispel {spell:31013}, kill Tito, then burn Roar, Strawman, and Tinhead. Red Riding Hood: Burn boss, kill Big Bad Wolf when he spawns, repeat. Romulo & Julianne: Kill both within 10 seconds of each other.",
			{
				role = DAMAGE,
				"Wizard of Oz: Focus Dorothee > Tito > Roar > Strawman > Tinhead. Use AoE during the final phase.",
				"Red Riding Hood: Burn the boss, then switch to Big Bad Wolf immediately when he spawns.",
				"Romulo & Julianne: Damage both evenly, burst to kill within 10 seconds.",
				"Interrupt casts when possible on all opera events."
			},
			{
				role = HEALER,
				"Wizard of Oz: Dispel {spell:31013} immediately. Heal through AoE fear from Roar.",
				"Red Riding Hood: Whoever gets eaten by Big Bad Wolf needs emergency healing.",
				"Romulo & Julianne: Heal through {spell:30890} damage. Prepare for resurrection mechanics.",
				"All events have high sustained damage - manage mana carefully."
			},
			{
				role = TANK,
				"Wizard of Oz: Main tank on Roar, off-tanks pick up others. Group them for AoE in final phase.",
				"Red Riding Hood: Tank boss away from raid. Pick up Big Bad Wolf immediately when he spawns.",
				"Romulo & Julianne: Tank them apart. Watch for {spell:30830} which makes them unattackable temporarily.",
				"Be ready to adapt to whichever event is active that week."
			}
		},
		abilities = {}
	},
	{
		name = "Curator",
		encounterID = 15691,
		portrait = 1379020,
		loot = {
			{ id = 28612, seasonFilter = "tbc" },
			{ id = 28647, seasonFilter = "tbc" },
			{ id = 28631, seasonFilter = "tbc" },
			{ id = 28621, seasonFilter = "tbc" },
			{ id = 28649, seasonFilter = "tbc" },
			{ id = 28633, seasonFilter = "tbc" },
			{ id = 29757, seasonFilter = "tbc" },
			{ id = 29758, seasonFilter = "tbc" },
			{ id = 29756, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15691 },
		overview = {
			"The Curator is a massive arcane golem that guards Medivh's art gallery. This DPS race encounter features wave after wave of Astral Flares that must be killed quickly. The Curator also periodically Evocates to restore power, providing a DPS window. This fight tests the raid's sustained damage output and add management.",
			{ heading = "Overview" },
			"DPS race: burn the Curator while killing Astral Flare adds. Flares spawn every 10 seconds - assign ranged DPS to kill them before they reach the raid. When Curator uses {spell:30254}, burn him hard - he takes 200% increased damage. Continue until boss dies. Healers conserve mana for the long fight.",
			{
				role = DAMAGE,
				"Melee: Stay on Curator full time unless adds are near you.",
				"Ranged: Assign 2-3 ranged to permanently kill Astral Flares. Others DPS Curator.",
				"During {spell:30254}, all DPS burn the Curator - he takes double damage.",
				"Use mana efficiently - this is a long fight. Save cooldowns for Evocate phases.",
				"Kill Flares before they reach the raid or they will explode for massive damage."
			},
			{
				role = HEALER,
				"This is a long fight - manage mana very carefully.",
				"Tank damage is moderate but consistent. Keep tank topped off.",
				"If Astral Flares reach the raid, prepare for heavy AoE damage.",
				"Use efficient healing spells - you need mana for the full fight duration.",
				"Innervate, mana potions, and Dark Runes are essential."
			},
			{
				role = TANK,
				"Single tank fight - tank Curator in the center of the room.",
				"Face boss away from raid to avoid {spell:29765} hitting multiple targets.",
				"During {spell:30254}, use the opportunity to build extra threat - boss takes double damage.",
				"Astral Flares cannot be tanked - let ranged DPS handle them.",
				"Use defensive cooldowns during non-Evocate phases when damage is higher."
			}
		},
		abilities = {}
	},
	{
		name = "Terestian Illhoof",
		encounterID = 15688,
		portrait = 1379017,
		loot = {
			{ id = 28660, seasonFilter = "tbc" },
			{ id = 28653, seasonFilter = "tbc" },
			{ id = 28652, seasonFilter = "tbc" },
			{ id = 28654, seasonFilter = "tbc" },
			{ id = 28655, seasonFilter = "tbc" },
			{ id = 28656, seasonFilter = "tbc" },
			{ id = 28662, seasonFilter = "tbc" },
			{ id = 28661, seasonFilter = "tbc" },
			{ id = 28785, seasonFilter = "tbc" },
			{ id = 28657, seasonFilter = "tbc" },
			{ id = 28658, seasonFilter = "tbc" },
			{ id = 28659, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15688, 17229, 17267, 17248 },
		overview = {
			"Terestian Illhoof is a demonic satyr warlock who has taken residence in Karazhan's library. He fights alongside his loyal imp Kil'rek and continuously summons lesser imps through a Fiendish Portal. The fight's central mechanic is Sacrifice, which chains a random player and requires immediate add-swapping to free them.",
			{ heading = "Overview" },
			"Kill Kil'rek immediately at pull to apply {spell:30065} debuff to Illhoof, increasing damage taken by 25%. Assign DPS to handle imp portal adds while maintaining damage on the boss. When Illhoof casts {spell:30115}, immediately switch all DPS to the Demon Chains to free the sacrificed player. Keep the raid stacked loosely to enable quick target swapping. The sacrificed player takes 1,500 shadow damage per second and Illhoof heals for 3,000 per second until freed.",
			{
				role = DAMAGE,
				"Kill Kil'rek first to apply {spell:30065}, increasing Illhoof's damage taken by 25%.",
				"Assign 1-2 DPS to permanently kill imps from the Fiendish Portal.",
				"When {spell:30115} is cast, ALL DPS immediately switch to {spell:17248} (approximately 13,000 HP).",
				"Imps respawn infinitely - maintain add control throughout the fight.",
				"Kil'rek respawns after 45 seconds - kill him again when he returns."
			},
			{
				role = HEALER,
				"The sacrificed player takes 1,500 unresistable shadow damage per second during {spell:30115}.",
				"Keep the sacrifice target topped off while DPS breaks the chains.",
				"Watch for {spell:30053} from Kil'rek, which increases fire damage taken.",
				"Manage mana carefully - this is a long fight with sustained raid damage from imps.",
				"Be ready to quickly heal when chains break, as the player will be low."
			},
			{
				role = TANK,
				"Tank Illhoof in the center of the room, facing away from the raid.",
				"Position near the imp portal so melee can easily cleave imps.",
				"Demon Chains cannot be tanked - they are stationary and must be killed.",
				"Pick up Kil'rek when he respawns and position him with Illhoof for cleave damage.",
				"Use defensive cooldowns during heavy imp waves or when healers are sacrificed."
			}
		},
		abilities = {}
	},
	{
		name = "Shade of Aran",
		encounterID = 16524,
		portrait = 1379012,
		loot = {
			{ id = 28672, seasonFilter = "tbc" },
			{ id = 28726, seasonFilter = "tbc" },
			{ id = 28670, seasonFilter = "tbc" },
			{ id = 28663, seasonFilter = "tbc" },
			{ id = 28669, seasonFilter = "tbc" },
			{ id = 28671, seasonFilter = "tbc" },
			{ id = 28666, seasonFilter = "tbc" },
			{ id = 28674, seasonFilter = "tbc" },
			{ id = 28675, seasonFilter = "tbc" },
			{ id = 28727, seasonFilter = "tbc" },
			{ id = 28728, seasonFilter = "tbc" },
			{ id = 28673, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16524, 17167 },
		overview = {
			"The Shade of Aran is the ghostly echo of Medivh's father, Guardian Aran. This arcane gauntlet tests the raid's ability to follow precise mechanics while maintaining DPS. Every 30 seconds, Aran casts one of three special abilities that require specific positioning. The fight demands perfect execution - a single mistake on Flame Wreath will wipe the raid.",
			{ heading = "Overview" },
			"Interrupt {spell:29955} whenever possible - it deals massive single-target damage. Every 30 seconds, Aran uses one special ability: {spell:30004} (DON'T MOVE), Blizzard (move to center), or Magnetic Pull + {spell:29973} (run to edges). At 40% health, he drinks to restore mana - this triggers Mass Polymorph followed by {spell:29962}. Kill the elementals quickly and resume normal mechanics.",
			{
				role = DAMAGE,
				"Priority interrupt {spell:29955} - deals 6,300-7,700 total damage to one target.",
				"During {spell:30004}: STOP ALL MOVEMENT. Any movement wipes the raid. Stand still even in Blizzard.",
				"During Blizzard: Move to the center of the room (safe zone) before casting stops.",
				"During Magnetic Pull: Immediately run to the room's edges before {spell:29973}.",
				"At 40% health: Break polymorph on others, then kill all four {spell:29962} quickly."
			},
			{
				role = HEALER,
				"Top priority: Keep {spell:29955} target alive - use major healing cooldowns.",
				"During {spell:30004}: STOP CASTING. HoTs are safe, but no new casts or movement.",
				"Blizzard deals 1,313-1,687 frost damage every 2 seconds. Heal through it if players can't move.",
				"After Mass Polymorph, be ready for heavy tank damage from Water Elementals.",
				"Conserve mana - this is a long fight with intense healing requirements."
			},
			{
				role = TANK,
				"Aran cannot be tanked traditionally - spread threat generation across multiple players.",
				"During {spell:30004}: STOP ALL ATTACKS AND MOVEMENT immediately.",
				"Pick up all four {spell:29962} at 40% and group them for AoE.",
				"Use defensive cooldowns during elemental phase and after {spell:29973}.",
				"Position near the center to minimize movement during Blizzard phases."
			}
		},
		abilities = {}
	},
	{
		name = "Netherspite",
		encounterID = 15689,
		portrait = 1379002,
		loot = {
			{ id = 28744, seasonFilter = "tbc" },
			{ id = 28742, seasonFilter = "tbc" },
			{ id = 28732, seasonFilter = "tbc" },
			{ id = 28741, seasonFilter = "tbc" },
			{ id = 28735, seasonFilter = "tbc" },
			{ id = 28740, seasonFilter = "tbc" },
			{ id = 28743, seasonFilter = "tbc" },
			{ id = 28733, seasonFilter = "tbc" },
			{ id = 28731, seasonFilter = "tbc" },
			{ id = 28730, seasonFilter = "tbc" },
			{ id = 28734, seasonFilter = "tbc" },
			{ id = 28729, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15689 },
		overview = {
			"Netherspite is a massive nether drake with an encounter based entirely around beam management. Three colored portal beams spawn during 60-second portal phases - each beam must be intercepted by players or Netherspite gains devastating buffs. The fight alternates between portal phases (complex mechanics) and banish phases (burn phases), testing coordination and execution.",
			{ heading = "Overview" },
			"Portal Phase (60s): Assign players to beams. Red beam = tank, Green beam = 2 healers rotating, Blue beam = 2-3 DPS rotating at ~30 stacks. Beams stack a debuff - swap before it becomes lethal. During portal phase, raid takes {spell:30522} damage (avoid line of sight to boss). Banish Phase (30s): Netherspite immobile, takes double damage. Stack at max range, avoid {spell:37063} on ground. Repeat phases until boss dies or 9-minute enrage.",
			{
				role = DAMAGE,
				"Portal Phase: 2-3 DPS rotate {spell:30468} (blue beam). Swap at 25-30 stacks maximum.",
				"Blue beam increases damage dealt but also damage taken and reduces healing received.",
				"{spell:30468} boosts Netherspite's damage by 15% per stack if not intercepted.",
				"Banish Phase: Use all DPS cooldowns. Boss takes double damage and cannot move.",
				"Avoid {spell:37063} void zones on the ground - they deal heavy shadow damage."
			},
			{
				role = HEALER,
				"Portal Phase: 2 healers rotate {spell:30467} (green beam). Swap before mana is fully drained.",
				"Green beam restores mana but reduces maximum mana. Heal 4,000/sec if boss gets it.",
				"During portal phase, heal through {spell:30522} - constant shadow damage aura.",
				"Banish Phase: Netherspite casts {spell:37634} - heavy arcane cone damage with knockback.",
				"Spread at least 10 yards apart during banish to reduce {spell:37063} overlap."
			},
			{
				role = TANK,
				"Portal Phase: Solo tank {spell:30466} (red beam) entire duration if possible.",
				"Red beam massively increases threat, healing taken, and maximum health.",
				"Position Netherspite facing away from raid during portal phases.",
				"Banish Phase: Tank boss at room entrance. Raid stacks at max range behind.",
				"{spell:37634} hits in a cone toward tank - face boss away from all raid members."
			}
		},
		abilities = {}
	},
	{
		name = "Chess Event",
		encounterID = 16816,
		portrait = 1385725,
		loot = {
			{ id = 28756, seasonFilter = "tbc" },
			{ id = 28755, seasonFilter = "tbc" },
			{ id = 28750, seasonFilter = "tbc" },
			{ id = 28752, seasonFilter = "tbc" },
			{ id = 28751, seasonFilter = "tbc" },
			{ id = 28746, seasonFilter = "tbc" },
			{ id = 28748, seasonFilter = "tbc" },
			{ id = 28747, seasonFilter = "tbc" },
			{ id = 28745, seasonFilter = "tbc" },
			{ id = 28753, seasonFilter = "tbc" },
			{ id = 28749, seasonFilter = "tbc" },
			{ id = 28754, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16816, 17211, 17469, 21752, 21750, 21747, 21748, 21726, 21682, 21683, 21684, 21664 },
		overview = {
			"The Chess Event is a unique encounter where the raid controls chess pieces in a magical game against Medivh. Players possess pieces and use their abilities strategically to defeat the enemy king. Success requires coordination, understanding piece abilities, and adapting to Medivh's cheats. This is a required encounter and cannot be skipped.",
			{ heading = "Overview" },
			"Strategy: Possess chess pieces by right-clicking them. First priority: kill both enemy Bishops (they heal). Second: kill the enemy Queen (highest damage). Third: push to the King and burn him down. Use your King's Heroism and Queen's abilities on cooldown. Medivh cheats every 30-60 seconds: he may heal all his pieces, berserk a piece, or cast fire on the board. Maintain multiple players in pieces at all times to quickly adapt.",
			{
				role = DAMAGE,
				"Possess damage pieces: Queen (highest priority), Rooks, Knights, or Pawns.",
				"Queen: Use Elemental Blast on cooldown (4,000 damage, massive range).",
				"Queen: Use Rain of Fire to hit multiple enemy pieces (6,000 damage AoE).",
				"Rook: Use Geyser for AoE damage (3,000 to all nearby pieces).",
				"Kill order: Enemy Bishops > Enemy Queen > Enemy King. Avoid attacking pawns unless necessary."
			},
			{
				role = HEALER,
				"Possess Bishop pieces - your role is healing friendly pieces.",
				"Bishops: Use Healing on friendly pieces for 12,000 health.",
				"Bishops: Use Holy Lance for 2,000 damage in a line (3-tile range).",
				"Keep the friendly King alive at all costs - if he dies, you lose.",
				"Heal the Queen as secondary priority - she is your main damage dealer."
			},
			{
				role = TANK,
				"Possess the King or Knight pieces.",
				"King: Move carefully (1 tile any direction). Use Heroism on cooldown (50% damage boost).",
				"Knight: Use Stomp for AoE damage, Heroic Blow for single target.",
				"Rook: Use Water Shield to reduce damage by 50% for 5 seconds.",
				"Stay behind your pawns initially - they tank enemy pieces while you set up."
			}
		},
		abilities = {}
	},
	{
		name = "Prince Malchezaar",
		encounterID = 15690,
		portrait = 1379006,
		loot = {
			{ id = 28765, seasonFilter = "tbc" },
			{ id = 28766, seasonFilter = "tbc" },
			{ id = 28764, seasonFilter = "tbc" },
			{ id = 28762, seasonFilter = "tbc" },
			{ id = 28763, seasonFilter = "tbc" },
			{ id = 28757, seasonFilter = "tbc" },
			{ id = 28770, seasonFilter = "tbc" },
			{ id = 28768, seasonFilter = "tbc" },
			{ id = 28767, seasonFilter = "tbc" },
			{ id = 28773, seasonFilter = "tbc" },
			{ id = 28771, seasonFilter = "tbc" },
			{ id = 28772, seasonFilter = "tbc" },
			{ id = 29760, seasonFilter = "tbc" },
			{ id = 29761, seasonFilter = "tbc" },
			{ id = 29759, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15690, 17646 },
		overview = {
			"Prince Malchezaar is the final boss of Karazhan, a powerful eredar who has taken over Medivh's tower. The fight has three phases with escalating mechanics: Phase 1 is straightforward tanking, Phase 2 adds axe weapons that attack the raid, and Phase 3 dramatically increases infernal spawn rate. The signature mechanic is Enfeeble, which reduces five random players to 1 HP.",
			{ heading = "Overview" },
			"Phase 1 (100-60%): Tank and spank. Spread 30+ yards apart before {spell:30843}. Phase 2 (60-30%): Two flying axes attack random players - off-tanks must grab them. Continue spreading for {spell:30843}. Phase 3 (30-0%): Infernals spawn every 15 seconds (was 45s). Burn the boss quickly. {spell:30843} targets 5 random players, reducing them to 1 HP for 7 seconds, followed by {spell:30852} 4 seconds later. Enfeebled players must be 30+ yards from boss to survive.",
			{
				role = DAMAGE,
				"Spread 30+ yards from Malchezaar before {spell:30843} is cast.",
				"{spell:30843} reduces you to 1 HP for 7 seconds. Any damage kills you instantly.",
				"{spell:30852} hits 4 seconds after Enfeeble. Stay at range if enfeebled.",
				"Phase 2: Ignore the axes - off-tanks handle them. Maintain boss DPS.",
				"Phase 3: Avoid infernals (they spam Hellfire). Burn boss to zero quickly."
			},
			{
				role = HEALER,
				"{spell:30843} targets 5 random non-tank players. They have 1 HP for 7 seconds.",
				"DO NOT heal enfeebled players during the debuff - healing does nothing.",
				"After {spell:30843} expires (7s), immediately top them off before next cast.",
				"Watch for {spell:30854} - moderate shadow DoT on the tank.",
				"Phase 3 is chaotic - infernals everywhere. Focus on keeping tanks and enfeebled players alive."
			},
			{
				role = TANK,
				"Main tank: Keep Malchezaar facing away from raid at all times.",
				"Phase 2: Two off-tanks must immediately grab the flying axes when they spawn.",
				"Tank is never targeted by {spell:30843} - you maintain full health.",
				"Use major defensive cooldowns during Phase 3 when boss damage increases.",
				"Avoid infernal Hellfire zones while maintaining threat on the boss."
			}
		},
		abilities = {}
	},
	{
		name = "Nightbane",
		encounterID = 17225,
		portrait = 1379003,
		loot = {
			{ id = 28602, seasonFilter = "tbc" },
			{ id = 28600, seasonFilter = "tbc" },
			{ id = 28601, seasonFilter = "tbc" },
			{ id = 28599, seasonFilter = "tbc" },
			{ id = 28610, seasonFilter = "tbc" },
			{ id = 28597, seasonFilter = "tbc" },
			{ id = 28608, seasonFilter = "tbc" },
			{ id = 28609, seasonFilter = "tbc" },
			{ id = 28603, seasonFilter = "tbc" },
			{ id = 28604, seasonFilter = "tbc" },
			{ id = 28611, seasonFilter = "tbc" },
			{ id = 28606, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17225, 17261 },
		overview = {
			"Nightbane is an optional boss summoned on Karazhan's terrace after completing a quest chain. The fight alternates between ground phases (tank and spank with positioning mechanics) and air phases (add management and avoidance). The dragon flies up at 75%, 50%, and 25% health, requiring the raid to kill Restless Skeletons while avoiding massive damage.",
			{ heading = "Overview" },
			"Ground Phase: Tank faces boss away from raid. Melee on rear right side only. Ranged spread 10+ yards apart. Move out of {spell:30209} ground effects. Run away during {spell:36922} fear. Air Phase: Stack under the boss to group {spell:37098} skeletons, then move away. AoE skeletons down quickly - they have Immolation aura. One player soaks {spell:37057} (2,000 damage per second for 15s). Repeat ground/air cycle at 75%, 50%, and 25% until boss dies.",
			{
				role = DAMAGE,
				"Ground: Melee DPS position on rear RIGHT leg only. Avoid {spell:25653} on left side.",
				"Ground: Move out of {spell:30209} immediately - it deals heavy fire damage over time.",
				"Air: Stack with raid under boss to group {spell:37098} skeleton spawns.",
				"Air: AoE all five Restless Skeletons down before ground phase resumes.",
				"Air: Ranged continue DPS on Nightbane during air phase for maximum efficiency."
			},
			{
				role = HEALER,
				"Ground: Tank takes heavy damage from {spell:30131} and {spell:30210}.",
				"Ground: Raid takes moderate damage from {spell:30130} - be ready to dispel curses.",
				"Air: Assign 1-2 healers to keep {spell:37057} target alive (2,000 damage per second).",
				"Air: Heal through skeleton Immolation aura if melee must help kill them.",
				"Use major healing cooldowns during {spell:36922} recovery - raid is scattered and taking damage."
			},
			{
				role = TANK,
				"Ground: Tank Nightbane facing away from raid. Position near center of terrace.",
				"Ground: {spell:25653} hits behind the boss. Do NOT stand directly behind him.",
				"Ground: Move boss out of {spell:30209} - it damages everyone in the area.",
				"Air: No tanking required. Help DPS skeletons or prepare for landing.",
				"Use defensive cooldowns after {spell:36922} - boss hits harder during debuff recovery."
			}
		},
		abilities = {}
	}
})
