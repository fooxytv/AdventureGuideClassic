--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "The Temple of Atal'hakkar",
	instanceID = 237,
	thumbnail = 608217,
	icon = 136360,
	splash = 608256,
	mapID = 109,
	season = true,
	overview = "Thousands of years ago, the Gurubashi empire was plunged into a civil war by a powerful sect of priests, the Atal'ai, who sought to summon to Azeroth an avatar of their god of blood, Hakkar the Soulflayer. The Gurubashi people exiled the Atal'ai to the Swamp of Sorrows, where the priests built the Temple of Atal'Hakkar. Ysera, Aspect of the green dragonflight, sank the temple beneath the swamp and assigned wardens to ensure that the summoning rituals never be performed again.",
	{
		name = "Atal'alarion",
		defeated = 0,
		encounterID = 8580,
		portrait = I.UIEJBossAtalalarion,
		loot = {
			{ id = 10798, seasonFilter = "all" },
			{ id = 10800, seasonFilter = "all" },
			{ id = 10799, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Atal'alarion is a powerful and vengeful spirit bound within The Temple of Atal'Hakkar. Once a guardian of the temple, he has been corrupted by dark forces and now seeks to defend it with a malevolent rage. This 20-player raid encounter tests the raid's coordination and positioning as they manage deadly knockbacks and stacking damage buffs.",
			{ heading = "Overview" },
			"Atal'alarion is the first boss encounter in the Season of Discovery 20-player raid. To summon him, activate the six shrines in the room. This boss encounter emphasizes positioning and pillar destruction. The boss will periodically create pillars around the arena that increase his damage by 5% per pillar. When he casts Demolishing Smash, players must use the knockback to collide with and destroy these pillars, preventing his damage from overwhelming the raid.",
			{
				role = DAMAGE,
				"Position yourself with your back to a pillar so that when {spell:437597} knocks you back, you will collide with and destroy the pillar. Melee damage dealers should angle themselves carefully to maintain uptime while still being positioned to break pillars. Use {spell:411684} or similar gap closers to quickly return to the boss after being knocked back. All pillars must be destroyed with each cast or the stacking damage buff will overwhelm healers.",
			},
			{
				role = HEALER,
				"Keep the raid at full health before each {spell:437597} cast, as it deals massive AoE damage. Position yourself with your back toward a pillar to destroy it when knocked back, while maintaining line of sight for healing. The boss gains a 5% damage increase per active pillar from {spell:437585}, making pillar destruction critical for raid survival.",
			},
			{
				role = TANK,
				"Position the boss with your back toward the entrance stairs to minimize knockback displacement. Maintain threat throughout the encounter while positioning to help destroy pillars. The tank should coordinate with the raid to ensure all {spell:437503} pillars are destroyed efficiently to prevent the damage buff from stacking too high.",
			}
		},
		abilities = {
			{ spell = 437503, title = "Pillars of Might", description = "Slams the ground, dealing minor AoE damage and creating pillars around the boss arena." },
			{ spell = 437585, title = "Pillars of Might", description = "Increases damage dealt by 5% for each currently standing pillar. Stacks." },
			{ spell = 437597, title = "Demolishing Smash", description = "Deals massive AoE damage and knocks all players back. Players should position to collide with pillars to destroy them." },
		}
	},
	{
		name = "Jammal'an the Prophet",
		defeated = 0,
		encounterID = 5710,
		portrait = 607665,
		loot = {
			{ id = 10808, seasonFilter = "all" },
			{ id = 10807, seasonFilter = "all" },
			{ id = 10806, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Jammal'an the Prophet is a high-ranking Atal'ai priest within The Temple of Atal'Hakkar. This two-phase encounter requires managing both Jammal'an and his companion Ogom the Wretched, each with distinct abilities. The fight demands strong dispelling, interrupt coordination, and careful positioning to avoid deadly area effects.",
			{ heading = "Overview" },
			"This is the second boss encounter in the Season of Discovery 20-player raid. The fight requires two tanks and at least 5 healers due to high damage output and numerous debuffs. In Phase 1, one tank pulls Jammal'an away from the raid while DPS focuses on burning down Ogom. Jammal'an cannot be damaged initially and casts various AoE spells. Once Ogom dies, he transforms Jammal'an into a shadow priest form for Phase 2. Meanwhile, Ogom consumes Jammal'an's corpse and transforms into a paladin-like form, creating new challenges.",
			{
				role = DAMAGE,
				"In Phase 1, focus all damage on Ogom while avoiding golden {spell:437817} circles on the floor. Decurse {spell:437868} immediately. In Phase 2, interrupt {spell:437805} casts when possible and continue avoiding {spell:437817}. Dispel {spell:437809} and {spell:437927} from affected players. Move out of {spell:437884} zones quickly. During {spell:437921}, spread damage across the raid by maintaining high health pools.",
			},
			{
				role = HEALER,
				"Phase 1 requires intense healing with both bosses active. Prioritize dispelling {spell:437809} and decursing {spell:437868}. In Phase 2, dispel {spell:437927} immediately as it deals heavy shadow damage. Prepare for {spell:437921} raid damage and {spell:437920} pulls. Keep ranged players spread to minimize {spell:437884} impact. Top off the raid constantly as both phases deal sustained damage to multiple targets.",
			},
			{
				role = TANK,
				"Assign one tank to pull Jammal'an away from the raid at the start. The second tank holds Ogom in Phase 1. After the transformation, maintain threat on both bosses in their new forms. Position away from {spell:437884} zones. Be ready for {spell:437915} stuns and {spell:437920} positioning changes. Tank swap if {spell:437891} stacks become dangerous. Keep bosses separated to give DPS room to avoid overlapping mechanics.",
			}
		},
		abilities = {
			{ spell = 437868, title = "Agonizing Weakness (Ogom)", description = "Curse causing 350 Shadow damage every 2 seconds and reducing damage output by 50% for 16 seconds. Can be decursed." },
			{ spell = 437805, title = "Smite (Jammal'an)", description = "Direct holy damage attack dealing 400 damage. Interruptible." },
			{ spell = 437817, title = "Holy Nova", description = "Creates explosive golden zones on the ground requiring player movement to avoid." },
			{ spell = 437809, title = "Holy Fire", description = "Applies to 5 random targets dealing 475-525 initial holy damage plus 500 damage every 2 seconds for 10 seconds. Dispellable." },
			{ spell = 437928, title = "Psychic Scream (Phase 2)", description = "Fears 5 players for 6 seconds." },
			{ spell = 437927, title = "Shadow Sermon: Pain (Phase 2)", description = "Debuffs 10 players with 600 Shadow damage every 2 seconds. Dispellable." },
			{ spell = 437921, title = "Mass Penance (Phase 2)", description = "Deals 500 raid-wide damage per second for 3 seconds." },
			{ spell = 437884, title = "Consecration (Ogom Phase 2)", description = "Creates a damaging zone inflicting 200 Holy damage per second for 1 minute." },
			{ spell = 437920, title = "Divine Storm (Ogom Phase 2)", description = "Pulls all players toward the caster, dealing 750 Holy damage." },
			{ spell = 437915, title = "Hammers of Justice (Ogom Phase 2)", description = "Stuns targets for 6 seconds." },
			{ spell = 437891, title = "Holy Strike (Ogom Phase 2)", description = "Weapon damage attack increasing Holy damage taken by 50% for 30 seconds." },
		}
	},
	{
		name = "Dreamscythe and Weaver",
		defeated = 0,
		encounterID = 5721,
		portrait = 608311,
		loot = {
			{ id = 12243, seasonFilter = "all" },
			{ id = 10797, seasonFilter = "all" },
			{ id = 12463, seasonFilter = "all" },
			{ id = 10796, seasonFilter = "all" },
			{ id = 10795, seasonFilter = "all" },
			{ id = 12465, seasonFilter = "all" },
			{ id = 12464, seasonFilter = "all" },
			{ id = 12466, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Dreamscythe and Weaver are two corrupted drakes that share a health pool in this challenging encounter. The fight takes place in an arena with a deadly hole in the center and poison surrounding the edges. This multi-phase encounter requires precise positioning and coordination to avoid being knocked into environmental hazards.",
			{ heading = "Overview" },
			"This is the fourth boss encounter in the Season of Discovery 20-player raid. The two drakes share a single health pool. The fight begins with Dreamscythe alone until 80% health, then Weaver joins. At 60%, Dreamscythe despawns, leaving only Weaver. The arena features a central pit and poison pools around the outer rim created by Caustic Overflow. Both drakes periodically fly to the corners and use knockback abilities, making positioning critical.",
			{
				role = DAMAGE,
				"Never stand with your back to the center hole or the poison pools around the edges. Position at safe angles to avoid being knocked by {spell:442620} or {spell:443827}. Tanks should swap every 2-3 stacks of {spell:442622} to prevent dangerous debuff accumulation. Stay close to the dragon during knockback casts to minimize knockback distance. Maintain constant awareness of your positioning relative to environmental hazards.",
			},
			{
				role = HEALER,
				"Bring at least 5 healers for this encounter. Position safely away from both the central pit and outer {spell:443856} poison. Focus healing on tanks who are accumulating {spell:442622} stacks. The DoT component lasts 45 seconds and stacks, requiring sustained tank healing. Shadow Priests provide excellent passive raid healing during this encounter. Keep the raid topped as players may take splash damage from positioning errors.",
			},
			{
				role = TANK,
				"You need 2-3 tanks for this encounter. Taunt swap every 2-3 stacks of {spell:442622} to manage the stacking Nature damage DoT. Position the active drake away from the center hole and outer poison. During knockback phases when the drakes fly to corners, maintain positioning to avoid being knocked into hazards. The closer you are to the drake during {spell:442620} or {spell:443827}, the farther you will be knocked back.",
			}
		},
		abilities = {
			{ spell = 442622, title = "Acid Breath", description = "Frontal cone breath attack inflicting 450-550 Nature damage and applying a stacking DoT that lasts 45 seconds." },
			{ spell = 442620, title = "Wing Flap (Weaver)", description = "Strikes enemies in a cone in front of the caster, knocking them back. Used after repositioning to corners." },
			{ spell = 443827, title = "Delayed Wing Buffet (Dreamscythe)", description = "Strikes enemies in a cone in front of the caster, knocking them back. Used after Weaver's Wing Flap." },
			{ spell = 443856, title = "Caustic Overflow", description = "Poison pool surrounding the arena's edge that deals 1000 Fire damage every 0.5 seconds to players standing in it." },
		}
	},
	{
		name = "Morphaz and Hazzas",
		defeated = 0,
		encounterID = 5722,
		portrait = 608311,
		loot = {
			{ id = 12243, seasonFilter = "all" },
			{ id = 10797, seasonFilter = "all" },
			{ id = 12463, seasonFilter = "all" },
			{ id = 10796, seasonFilter = "all" },
			{ id = 10795, seasonFilter = "all" },
			{ id = 12465, seasonFilter = "all" },
			{ id = 12464, seasonFilter = "all" },
			{ id = 12466, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Morphaz and Hazzas present a unique two-realm encounter where the raid must battle Hazzas in the physical realm while dealing with periodic transitions to the Dream realm where Morphaz awaits. The dragons share a health pool, and players deal 100% increased damage in the Dream realm, creating a strategic push-and-pull between realms.",
			{ heading = "Overview" },
			"This is the sixth boss encounter in the Season of Discovery 20-player raid. Hazzas exists in the physical realm while Morphaz occupies the Dream realm. Both dragons share the same health pool. At 80% health, Hazzas spawns fire elementals. Periodically, Hazzas channels Lucid Dreaming for 20 seconds, teleporting the raid to the Dream realm where they face Morphaz. In the Dream realm, Morphaz channels Eternal Slumber for 30 seconds - if the channel completes, all players in the Dream realm die. Players must kill Nightmare Vines to open portals that allow one person per portal to escape back to the physical realm.",
			{
				role = DAMAGE,
				"Never stand in front of Hazzas to avoid {spell:446487}. Position to the side to avoid {spell:446489} behind the boss. At 80% health, immediately kill fire elementals from {spell:446661} and avoid standing in fire patches they leave behind. When teleported to the Dream realm by {spell:449422}, you deal 100% increased damage to Morphaz. Quickly burn down Nightmare Vines to create escape portals before {spell:446034} completes its 30-second channel. Tank swap every few {spell:446487} casts to prevent dangerous DoT stacking.",
			},
			{
				role = HEALER,
				"Bring at least 4 healers. Monitor {spell:446468} DoT on affected players. Heal through sustained {spell:446270} damage when it falls. Keep players who get {spell:445555} debuff from fire patches topped off. During Dream realm phases from {spell:449422}, players take {spell:445158} sleep debuff - coordinate with DPS to ensure vines die quickly. You can skip the entire Dream realm mechanic by breaking line of sight during {spell:449422} channel, though this may be hotfixed.",
			},
			{
				role = TANK,
				"You can solo tank this encounter if Dream realm is avoided via line-of-sight, otherwise bring 2 tanks. Swap between {spell:446487} casts as it applies a stacking Nature damage DoT. Position Hazzas so melee are at his sides, safe from both {spell:446487} in front and {spell:446489} behind. When fire elementals spawn at 80%, position away from fire patches. If entering Dream realm, maintain threat on Morphaz while DPS burns vines to create escape portals before {spell:446034} wipes the raid.",
			}
		},
		abilities = {
			{ spell = 446487, title = "Corrupted Breath (Hazzas)", description = "Frontal cone inflicting 1200-1700 Nature damage with a stacking DoT component." },
			{ spell = 446489, title = "Backfire (Hazzas)", description = "Inflicts 1800-2200 damage on enemies in a cone behind the caster, knocking them back." },
			{ spell = 446468, title = "Dreamer's Lament (Hazzas)", description = "Powerful DoT that cannot be dispelled." },
			{ spell = 446661, title = "Animate Flame (Hazzas)", description = "At 80% health, spawns fire elementals that leave fire patches on the ground." },
			{ spell = 445555, title = "On Fire!!", description = "Debuff applied when standing in fire patches left by elementals." },
			{ spell = 449422, title = "Lucid Dreaming (Hazzas)", description = "Hazzas flies to center and channels for 20 seconds, teleporting the raid to the Dream realm." },
			{ spell = 446270, title = "Falling Rocks (Hazzas)", description = "Acid rain falls from above, inflicting 1300-1700 Nature damage to players struck." },
			{ spell = 446034, title = "Eternal Slumber (Morphaz)", description = "30-second channel in Dream realm. If completed, kills all players in the Dream realm. DPS check mechanic." },
			{ spell = 445158, title = "Lucid Dreaming (Morphaz)", description = "Sleep debuff applied to players sent to the Dream realm." },
		}
	},
	{
		name = "Avatar of Hakkar",
		defeated = 0,
		encounterID = 8443,
		portrait = 607548,
		loot = {
			{ id = 10846, seasonFilter = "all" },
			{ id = 10843, seasonFilter = "all" },
			{ id = 10842, seasonFilter = "all" },
			{ id = 10845, seasonFilter = "all" },
			{ id = 10838, seasonFilter = "all" },
			{ id = 10844, seasonFilter = "all" },
			{ id = 12462, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"The Avatar of Hakkar is a manifestation of the bloodthirsty god Hakkar the Soulflayer within The Temple of Atal'Hakkar. This encounter requires careful management of spreading diseases, mind control mechanics, and a pre-boss phase where the raid must kill ritualists and a blood-powered mini-boss to summon the Avatar.",
			{ heading = "Overview" },
			"This is the seventh boss encounter in the Season of Discovery 20-player raid. To spawn the Avatar, first kill the four Hakkari Ritualists, then engage the Hakkari Bloodkeeper. The Bloodkeeper regenerates 3% mana per second via Tides of Blood and must be interrupted or killed before reaching 100% mana, at which point the Avatar spawns. The Avatar encounter features spreading disease mechanics, curses that slow casting, mind control effects, and a devastating drain ability. Key mechanics include managing Corrupted Blood spread, dispelling curses and mind control, and positioning for Drain Blood.",
			{
				role = DAMAGE,
				"During the Bloodkeeper phase, interrupt {spell:443990} to prevent fear and damage. Burn down the Bloodkeeper quickly before {spell:443917} regenerates to 100% mana. Against the Avatar, stay spread to prevent {spell:444255} from spreading to multiple players. If you get Corrupted Blood, move away from the raid behind the tank. Assist with dispelling {spell:444039} mind control effects immediately. Ranged players must stay at maximum range to avoid {spell:444046}. The {spell:444132} ability removes Corrupted Blood, so affected players can return to position afterward.",
			},
			{
				role = HEALER,
				"Keep the raid topped off constantly due to {spell:444050} damage and {spell:444255} spreading. When two players are hit by Corrupted Blood, they must move behind the tank immediately. Dispel {spell:444046} from casters ASAP as it reduces casting speed by 50%. Remove {spell:444039} mind control effects immediately to prevent the affected player from attacking allies. During {spell:444132}, be ready for spike damage on the tank. {spell:444165} prevents healing for 6 seconds, so anticipate this debuff timing. Manage {spell:443975} DoT from the Bloodkeeper phase carefully.",
			},
			{
				role = TANK,
				"During the Bloodkeeper phase, maintain threat while DPS burns before {spell:443917} reaches 100% mana. Watch for {spell:443940} ground effects and {spell:443975} movement slow. For the Avatar, position centrally to allow Corrupted Blood players to move behind you safely. When {spell:444132} is cast, Corrupted Blood will be removed and affected players can return. Use cooldowns during {spell:444165} debuff windows when you cannot be healed. Control or stun players affected by {spell:444039} mind control.",
			}
		},
		abilities = {
			{ spell = 443940, title = "Bubbling Blood (Bloodkeeper)", description = "Launches blood at a target, inflicting Shadow damage to players within the area." },
			{ spell = 443975, title = "Spirit Chains (Bloodkeeper)", description = "Applies 200 Shadow damage every 2 seconds for 18 seconds and reduces movement, attack, and cast speed by 50%." },
			{ spell = 443990, title = "Frightsome Howl (Bloodkeeper)", description = "Interruptible ability dealing 1500 Shadow damage and causing a 4-second fear effect." },
			{ spell = 443917, title = "Tides of Blood (Bloodkeeper)", description = "Regenerates 3% maximum mana per second. Avatar spawns when Bloodkeeper reaches 100% mana." },
			{ spell = 444050, title = "Blood Nova", description = "Blasts players with blood, inflicting 500 Shadow damage." },
			{ spell = 444255, title = "Corrupted Blood", description = "Inflicts 350 Shadow damage every 2 seconds. Spreads to nearby players if not isolated." },
			{ spell = 444132, title = "Drain Blood", description = "Frontal cast that removes the Corrupted Blood debuff from affected players." },
			{ spell = 444046, title = "Curse of Tongues", description = "Decursable curse reducing casting speed by 50% for 15 seconds. Ranged players should stay at max range to avoid." },
			{ spell = 444039, title = "Insanity", description = "Dispellable mind control that increases target's maximum health by 25%. Must be removed immediately." },
			{ spell = 444165, title = "Skeletal", description = "Temporary 6-second debuff preventing all healing received while granting increased movement speed." },
		}
	},
	{
		name = "Shade of Eranikus",
		defeated = 0,
		encounterID = 5709,
		portrait = 607768,
		loot = {
			{ id = 10836, seasonFilter = "all" },
			{ id = 10837, seasonFilter = "all" },
			{ id = 10833, seasonFilter = "all" },
			{ id = 10828, seasonFilter = "all" },
			{ id = 10835, seasonFilter = "all" },
			{ id = 10829, seasonFilter = "all" },
			{ id = 10847, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"The Shade of Eranikus is a corrupted green dragon who has fallen under the sway of the malevolent god Hakkar the Soulflayer. Once a protector of nature, Eranikus now serves as the final and most challenging boss in the Season of Discovery Sunken Temple raid. This multi-phase encounter tests raid coordination with sleep mechanics, add waves, and devastating abilities.",
			{ heading = "Overview" },
			"This is the eighth and final boss in the Season of Discovery 20-player raid. The encounter features four distinct phases with transitions at 70%, 40%, and 10% health. Phase 1 focuses on tank swaps and managing the Lethargic Poison debuff. At 70% and 40%, Eranikus enters intermission phases, going to sleep and spawning two Lumbering Dreamwalkers that must be killed. Phase 2 (starting at 70%) introduces Nightmare Whelps that spawn every 10 seconds and must be AoE'd down. Phase 3 (starting at 40%) brings Nightmare Scalebanes and Acid Rain. The final burn phase begins at 10%. Critical to survival is the Deep Slumber mechanic paired with Waking Nightmare - players must sleep in clouds to avoid instant death.",
			{
				role = DAMAGE,
				"Never stand in front of the boss to avoid {spell:437353}. Stay away from behind to avoid {spell:437375}. Dispel {spell:437390} from affected players immediately. During {spell:437398} casts, run into a {spell:437301} cloud to fall asleep - this reduces damage taken by 99% and prevents the 30,000 Shadow damage. Interrupt {spell:445498} whenever possible to prevent the 6-second raid-wide fear. In Phase 2, AoE down Nightmare Whelps quickly every 10 seconds. In Phase 3, kill {spell:445571} Nightmare Scalebanes before returning to the boss. Use cooldowns during the final burn at 10%.",
			},
			{
				role = HEALER,
				"Bring at least 4 healers for this long encounter. Monitor tanks carefully during {spell:437353} which reduces armor by 33% and stacks. Dispel {spell:437390} immediately as it reduces hit chance by 50% and increases ability costs by 100%. Before each {spell:437398} cast, ensure everyone moves into {spell:437301} clouds to sleep and survive. During intermissions at 70% and 40%, heal through Lumbering Dreamwalker damage. In Phase 2, keep the raid topped for constant Nightmare Whelp cleave. In Phase 3, prepare for {spell:445571} raining down from Nightmare Scalebanes. Manage mana carefully as this is a long fight.",
			},
			{
				role = TANK,
				"Bring at least 2 tanks. Swap tanks every few {spell:437353} casts to prevent dangerous armor reduction stacking (reduces armor by 33% per stack). Position Eranikus facing away from the raid to prevent {spell:437353} hitting others, and keep melee safe from {spell:437375} tail sweep. When {spell:437398} is being cast, move into a {spell:437301} cloud to sleep, reducing damage taken by 99%. Be ready for {spell:3391} which grants the boss two additional melee strikes. During intermissions, tank the two Lumbering Dreamwalkers. In Phase 2, gather and hold Nightmare Whelps for AoE. In Phase 3, pick up Nightmare Scalebanes quickly.",
			}
		},
		abilities = {
			{ spell = 445498, title = "Bellowing Roar", description = "Releases a shaking roar, sending all enemies within 200 yards fleeing in fear for 6 seconds. Should be interrupted." },
			{ spell = 437353, title = "Corrosive Breath", description = "Frontal breath attack dealing heavy Nature damage and reducing target's armor by 33% for 20 seconds. Tank swap mechanic." },
			{ spell = 437390, title = "Lethargic Poison", description = "Spits poison at players inflicting 300 Nature damage every 3 seconds for 15 seconds. Reduces hit chance by 50% and increases ability costs by 100%. Must be dispelled." },
			{ spell = 437301, title = "Deep Slumber", description = "Creates sleep clouds throughout the arena. Standing in a cloud puts you to sleep for 20 seconds, reducing all damage taken by 99%." },
			{ spell = 437398, title = "Waking Nightmare", description = "Shatters the mind of all waking players, inflicting 30,000 Shadow damage. Players must be asleep in Deep Slumber clouds to survive." },
			{ spell = 437375, title = "Tail Sweep", description = "Inflicts 760-840 damage to targets behind the caster, knocking them back." },
			{ spell = 3391, title = "Thrash", description = "Grants the boss two additional melee strikes." },
			{ spell = 445571, title = "Acid Rain", description = "In Phase 3, acid rain falls from the ceiling inflicting 1000 Nature damage to players struck. Cast by Nightmare Scalebanes." },
			{ spell = 445517, title = "Acid Shot", description = "Direct acid attack used by Nightmare Whelplings in Phase 2." },
		}
	},
})
