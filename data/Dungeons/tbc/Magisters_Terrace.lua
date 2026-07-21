--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Magister's Terrace",
	instanceID = 585,
	thumbnail = 608208,
	icon = 136350,
	splash = 608247,
	mapID = 348,
	seasonFilter = "tbc",
	overview = "Magister's Terrace is an instance on the Isle of Quel'Danas, serving as Kael'thas Sunstrider's personal sanctum. After his defeat in Tempest Keep, the blood elf prince has returned with renewed determination to harness the power of the Sunwell for his dark purposes.",
	{
		name = "Selin Fireheart",
		defeated = 0,
		encounterID = 24723,
		portrait = 607767,
		loot = {
			{ id = 34702, seasonFilter = "tbc" },
			{ id = 34697, seasonFilter = "tbc" },
			{ id = 34701, seasonFilter = "tbc" },
			{ id = 34698, seasonFilter = "tbc" },
			{ id = 34700, seasonFilter = "tbc" },
			{ id = 34699, seasonFilter = "tbc" },
			{ id = 34602, seasonFilter = "tbc" },
			{ id = 34601, seasonFilter = "tbc" },
			{ id = 34604, seasonFilter = "tbc" },
			{ id = 34603, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 24723 },
		overview = {
			"Selin Fireheart is a fallen blood elf who serves Kael'thas Sunstrider. The fel energy he has consumed has altered his appearance, causing him to resemble a demon with wings and horns. He is the first boss encounter in Magister's Terrace and must be defeated to progress through the instance.",
			{ heading = "Overview" },
			"This encounter revolves around managing Selin's mana draining from Fel Crystals positioned around the room. When Selin drains a crystal, he channels {spell:44320} and restores 10% of his maximum mana per second. Interrupt this channel by killing the crystal he is draining. Position the raid to quickly move to and destroy active Fel Crystals. Avoid {spell:44314} which deals massive fire damage to the entire group when Selin has mana. On Heroic difficulty, {spell:46165} must be removed quickly through spell stealing or purging.",
			{
				role = DAMAGE,
				"DPS the boss normally until he begins channeling on a Fel Crystal.",
				"Immediately switch to the Fel Crystal Selin is draining and destroy it before he fully restores his mana.",
				"Ranged damage dealers should position near Fel Crystals to minimize movement when switching targets.",
				"On Heroic difficulty, Mages and Shamans should dispel {spell:46165} from Selin to prevent his {spell:36819} cast.",
				"Avoid standing in {spell:46162} ground effects which deal heavy fire damage over time."
			},
			{
				role = HEALER,
				"Be prepared for heavy raid-wide damage from {spell:44314} if Selin has mana.",
				"Dispel {spell:44294} and {spell:46153} from affected players quickly to reduce healing pressure.",
				"Position between Fel Crystals to maintain healing range while moving to destroy crystals.",
				"On Heroic difficulty, have Shamans or Priests ready to purge {spell:46165} before he casts {spell:36819}.",
				"Conserve mana early in the fight as {spell:46153} can drain significant healer mana."
			},
			{
				role = TANK,
				"Tank Selin in the center of the room to allow easy access to all Fel Crystals.",
				"When Selin begins draining a crystal, maintain aggro while DPS destroys the crystal.",
				"Face Selin away from the raid to avoid cleave damage.",
				"Be prepared for increased threat generation when the raid switches to Fel Crystals.",
				"Use defensive cooldowns during {spell:44314} casts if your raid cannot kill crystals quickly enough."
			}
		},
		abilities = {
			{
				id = 44294,
				name = "Drain Life",
				description = "Drains 4500 health from a player over 3 seconds, healing Selin for the amount drained. On Heroic difficulty ({spell:46155}), drains 6000 health instead."
			},
			{
				id = 46153,
				name = "Drain Mana",
				description = "Drains mana from a random player, transferring it to Selin. Prioritize dispelling this effect from healers."
			},
			{
				id = 44314,
				name = "Fel Explosion",
				description = "Deals heavy Fire damage to all players within 80 yards. Cast continuously while Selin has mana available. This ability makes it crucial to prevent Selin from restoring mana via Fel Crystals."
			},
			{
				id = 44320,
				name = "Mana Rage",
				description = "Selin drains a nearby Fel Crystal, gaining 10% of his mana every second. He continues channeling until the crystal is destroyed or his mana is full. Destroying the crystal interrupts this channel."
			},
			{
				id = 46165,
				name = "Shock Barrier (Heroic)",
				description = "On Heroic difficulty only, Selin surrounds himself with a barrier that absorbs 10,000 damage and makes him immune to interrupts. Must be purged or spell stolen before he casts {spell:36819}."
			},
			{
				id = 36819,
				name = "Pyroblast (Heroic)",
				description = "On Heroic difficulty, Selin begins casting Pyroblast after activating {spell:46165}. Inflicts 45,000 to 55,000 Fire damage to a single player. Must be prevented by removing Shock Barrier."
			}
		}
	},
	{
		name = "Vexallus",
		defeated = 0,
		encounterID = 24744,
		portrait = 607806,
		loot = {
			{ id = 34708, seasonFilter = "tbc" },
			{ id = 34705, seasonFilter = "tbc" },
			{ id = 34707, seasonFilter = "tbc" },
			{ id = 34704, seasonFilter = "tbc" },
			{ id = 34706, seasonFilter = "tbc" },
			{ id = 34703, seasonFilter = "tbc" },
			{ id = 34607, seasonFilter = "tbc" },
			{ id = 34605, seasonFilter = "tbc" },
			{ id = 34606, seasonFilter = "tbc" },
			{ id = 34608, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 24744 },
		overview = {
			"Vexallus is an arcane elemental bound within Magister's Terrace. This powerful being of pure arcane energy serves as the second boss encounter. The fight becomes progressively more dangerous as Vexallus loses health and spawns additional Pure Energy adds that empower the raid with a dangerous damage buff.",
			{ heading = "Overview" },
			"Vexallus spawns Pure Energy adds at 85%, 70%, 55%, 40%, 25%, and 10% health (one add on Normal, two on Heroic). These adds have only 1 health but cannot be damaged by AoE abilities and must be killed with single-target attacks. When a Pure Energy dies, all nearby players gain {spell:44335}, increasing damage dealt by 50% but also dealing 300 damage per second. This buff stacks up to 10 times. Around 20% health, Vexallus begins casting {spell:44353}, a devastating AoE that must be burned through quickly. All damage from Vexallus is Arcane and cannot be blocked or reflected.",
			{
				role = DAMAGE,
				"Kill Pure Energy adds immediately when they spawn using single-target abilities only.",
				"AoE abilities do not damage Pure Energy - use direct damage spells and abilities.",
				"Manage {spell:44335} stacks carefully - high stacks increase your damage but deal heavy damage over time.",
				"Below 20% health, burn Vexallus as quickly as possible during {spell:44353} phase.",
				"Use personal defensive cooldowns during {spell:44353} if stacks of {spell:44335} are high.",
				"Spread out to avoid multiple players being hit by {spell:44342}."
			},
			{
				role = HEALER,
				"Monitor {spell:44335} stacks on all raid members - high stacks require constant healing attention.",
				"As more Pure Energy adds die, healing requirements increase exponentially.",
				"Be prepared for massive raid-wide damage from {spell:44353} below 20% health.",
				"Dispel {spell:46381} from affected players on Heroic difficulty to reduce spike damage.",
				"Position to avoid being targeted by {spell:44342} while maintaining healing range.",
				"Consider using Arcane resistance buffs if available to reduce overall damage taken."
			},
			{
				role = TANK,
				"Tank Vexallus in the center of the room and maintain a consistent position.",
				"Vexallus is immune to Taunt - establish solid threat early and maintain it throughout.",
				"Be aware that all damage is Arcane type - Shield Block and spell reflection do not work.",
				"Use major defensive cooldowns during {spell:44353} phase below 20% health.",
				"Watch your own {spell:44335} stacks and communicate if you need additional healing.",
				"Do not move Vexallus unnecessarily as melee need to avoid {spell:44318} bounces."
			}
		},
		abilities = {
			{
				id = 44318,
				name = "Chain Lightning",
				description = "Strikes an enemy with a lightning bolt that bounces to additional nearby targets, dealing Nature damage. On Heroic difficulty ({spell:46380}), damage is increased. Keep spread to minimize chain bounces."
			},
			{
				id = 44322,
				name = "Summon Pure Energy",
				description = "Vexallus summons Pure Energy adds at every 15% health lost. Normal mode spawns 1 add, Heroic spawns 2 adds. These adds have 1 health but cannot be damaged by AoE abilities."
			},
			{
				id = 44342,
				name = "Energy Bolt",
				description = "An instant-cast bolt of arcane energy dealing approximately 3000 Arcane damage to a random target within 20 yards. Cast frequently throughout the encounter."
			},
			{
				id = 44335,
				name = "Energy Feedback",
				description = "Gained when a Pure Energy add dies. Increases all damage dealt by 50% but inflicts 300 Arcane damage per second. Stacks up to 10 times. This is both a powerful damage buff and a dangerous damage over time effect."
			},
			{
				id = 44319,
				name = "Arcane Shock",
				description = "Shocks an enemy with arcane force, dealing immediate damage and additional Arcane damage every 3 seconds for 12 seconds. On Heroic difficulty ({spell:46381}), damage values are increased."
			},
			{
				id = 44353,
				name = "Overload",
				description = "At approximately 20% health, Vexallus begins repeatedly casting this AoE Arcane attack, dealing 1000 damage to all group members. Combined with {spell:44335} stacks, this phase can be deadly. Burn phase - use all cooldowns."
			}
		}
	},
	{
		name = "Priestess Delrissa",
		defeated = 0,
		encounterID = 24560,
		portrait = 607742,
		loot = {
			{ id = 34792, seasonFilter = "tbc" },
			{ id = 34788, seasonFilter = "tbc" },
			{ id = 34791, seasonFilter = "tbc" },
			{ id = 34789, seasonFilter = "tbc" },
			{ id = 34790, seasonFilter = "tbc" },
			{ id = 34783, seasonFilter = "tbc" },
			{ id = 34473, seasonFilter = "tbc" },
			{ id = 34471, seasonFilter = "tbc" },
			{ id = 34470, seasonFilter = "tbc" },
			{ id = 34472, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 24560, 24553, 24554, 24555, 24556, 24557, 24558, 24559 },
		overview = {
			"Priestess Delrissa is the third boss encounter in Magister's Terrace. This encounter is unique as Delrissa is always accompanied by four randomly selected companions from a pool of eight possible allies. Each companion has distinct abilities and class roles, making every pull potentially different. All five enemies must be defeated to complete the encounter, creating a fight that resembles a PvP arena match more than a traditional dungeon boss.",
			{ heading = "Overview" },
			"This encounter revolves around crowd control, interrupts, and kill order priority. Four companions are randomly selected from: Apoko (Shaman), Eramas Brightblaze (Warrior), Ellrys Duskhallow (Warlock), Garaxxas (Hunter), Kagani Nightstrike (Rogue), Warlord Salaris (Warrior), Yazzai (Mage), and Zelfan (Engineer). Priestess Delrissa will constantly heal her allies with {spell:17843} and {spell:44174}, making her a high-priority interrupt target. Most companions cannot be traditionally tanked and will freely attack any group member. On Heroic difficulty, scout the companions before pulling to plan your strategy, as certain combinations are significantly more dangerous.",
			{
				role = DAMAGE,
				"Establish a kill order before engaging - typically: healers/casters first, then melee DPS.",
				"Interrupt Priestess Delrissa's {spell:17843} casts - she will outheal your damage if left unchecked.",
				"Use crowd control on companions that can be CC'd: Polymorph on Ellrys (Warlock), Banish on Garaxxas (Hunter).",
				"Focus fire on one target at a time - splitting damage allows Delrissa to heal multiple targets.",
				"Avoid standing near others during {spell:27610} to prevent chain fears.",
				"Dispel {spell:15654} from yourself and allies when possible.",
				"Be prepared to switch targets if Delrissa begins healing a near-death companion."
			},
			{
				role = HEALER,
				"This fight has unpredictable damage - maintain high health pools on all party members.",
				"Prioritize dispelling {spell:15654} from party members to reduce damage intake.",
				"Expect {spell:27609} to remove your buffs - rebuff important effects quickly.",
				"Watch for Kagani Nightstrike (Rogue) vanishing and attacking you - call for peels.",
				"If Warlord Salaris is present, be ready for heavy physical damage from {spell:30471}.",
				"Avoid {spell:27610} by maintaining distance from Delrissa when possible.",
				"Save mana for a potentially long fight - Delrissa's healing extends the encounter significantly."
			},
			{
				role = TANK,
				"This is not a traditional tank fight - focus on protecting your party rather than holding aggro.",
				"Interrupt or stun Priestess Delrissa's {spell:17843} casts whenever possible.",
				"Peel dangerous melee adds (Kagani, Eramas, Salaris) off your healers and casters.",
				"Use defensive cooldowns when multiple adds are attacking you simultaneously.",
				"Dispel beneficial buffs from companions when possible.",
				"Position to avoid {spell:27610} chain fearing your entire group.",
				"Be ready to pick up adds that break from crowd control.",
				"On Heroic, communicate which companions are present so your group can adapt strategy."
			}
		},
		abilities = {
			{
				id = 15654,
				name = "Shadow Word: Pain",
				description = "Priestess Delrissa inflicts Shadow damage to a player every 3 seconds for 15 seconds. On Heroic difficulty ({spell:14032}), damage is increased. Dispel when possible to reduce healing requirements."
			},
			{
				id = 44174,
				name = "Renew",
				description = "Priestess Delrissa renews an ally, healing them every 3 seconds for 15 seconds. On Heroic difficulty ({spell:46192}), healing is increased. High priority interrupt target."
			},
			{
				id = 44291,
				name = "Power Word: Shield",
				description = "Priestess Delrissa shields an ally, absorbing 1455 damage for 30 seconds. Once shielded, the target cannot be shielded again for 15 seconds. Purge or dispel this buff to maintain damage on targets."
			},
			{
				id = 17843,
				name = "Flash Heal",
				description = "Priestess Delrissa calls upon Holy magic to heal an ally. Fast cast time - highest priority interrupt. Delrissa will spam this ability on low-health companions."
			},
			{
				id = 27609,
				name = "Dispel Magic",
				description = "Priestess Delrissa dispels magic from a target, removing 2 harmful spells from an ally or 1 beneficial spell from a player. Rebuff important effects after they are dispelled."
			},
			{
				id = 27610,
				name = "Psychic Scream",
				description = "Priestess Delrissa lets out a psychic scream, causing 5 players within 8 yards to flee for 5 seconds. Spread out to minimize the number of players feared."
			},
			{
				id = 46227,
				name = "Medallion of Immunity",
				description = "Priestess Delrissa removes all movement impairing effects and all effects which cause loss of control from herself. Cannot be reliably crowd controlled."
			}
		}
	},
	{
		name = "Kael'thas Sunstrider",
		defeated = 0,
		encounterID = 24664,
		portrait = 607669,
		loot = {
			{ id = 34810, seasonFilter = "tbc" },
			{ id = 34808, seasonFilter = "tbc" },
			{ id = 34809, seasonFilter = "tbc" },
			{ id = 34799, seasonFilter = "tbc" },
			{ id = 34807, seasonFilter = "tbc" },
			{ id = 34625, seasonFilter = "tbc" },
			{ id = 34793, seasonFilter = "tbc" },
			{ id = 34796, seasonFilter = "tbc" },
			{ id = 34795, seasonFilter = "tbc" },
			{ id = 34798, seasonFilter = "tbc" },
			{ id = 34794, seasonFilter = "tbc" },
			{ id = 34797, seasonFilter = "tbc" },
			{ id = 35504, seasonFilter = "tbc" },
			{ id = 34610, seasonFilter = "tbc" },
			{ id = 34613, seasonFilter = "tbc" },
			{ id = 34614, seasonFilter = "tbc" },
			{ id = 34615, seasonFilter = "tbc" },
			{ id = 34612, seasonFilter = "tbc" },
			{ id = 34611, seasonFilter = "tbc" },
			{ id = 34609, seasonFilter = "tbc" },
			{ id = 34616, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {
			{ id = 35513, seasonFilter = "tbc" }
		},
		npcs = { 24664, 24674, 24675 },
		overview = {
			"Kael'thas Sunstrider, the once-proud prince of Quel'Thalas, serves as the final boss of Magister's Terrace. Though believed defeated in Tempest Keep, Kael'thas has been kept alive by a green fel crystal embedded in his chest. He now works to harness the power of the Sunwell for dark purposes. This two-phase encounter requires precise positioning, interrupt coordination, and careful management of Phoenix adds.",
			{ heading = "Overview" },
			"Phase 1 lasts from 100% to 50% health. Kael'thas uses {spell:44189}, {spell:46162}, and periodically summons Phoenix adds with {spell:44194}. When a Phoenix dies, it leaves behind a Phoenix Egg that must be killed within 15 seconds or it will hatch into a new Phoenix. On Heroic difficulty, Kael'thas gains {spell:46165} which absorbs 10,000 damage and prevents interrupts, followed by {spell:36819} which can one-shot players. At 50% health, Phase 2 begins with {spell:44224}, lifting all players into the air and spawning three Arcane Spheres that chase players. After 30 seconds, Kael'thas suffers from Power Feedback, becoming stunned and taking 50% additional damage for 10 seconds - this is the burn window.",
			{
				role = DAMAGE,
				"Phase 1: Focus down Phoenix adds immediately when they spawn using the eggs they leave behind.",
				"Kill Phoenix Eggs within 15 seconds to prevent new Phoenix spawns - this is critical.",
				"On Heroic difficulty, interrupt {spell:36819} by first removing {spell:46165} with spell steal or purge.",
				"Stay spread out to avoid overlapping {spell:46162} damage zones.",
				"Phase 2: During {spell:44224}, fly away from Arcane Spheres while maintaining damage on Kael'thas.",
				"Save all major DPS cooldowns for the Power Feedback stun window.",
				"Arcane Spheres deal heavy damage on contact - kite them effectively while airborne.",
				"Continue killing Phoenix Eggs even during Phase 2 to prevent additional adds."
			},
			{
				role = HEALER,
				"Phase 1: Heal through consistent {spell:44189} damage on the tank.",
				"Players standing in {spell:46162} will take heavy fire damage over time - move them out quickly.",
				"Phoenix adds inflict fire damage aura to nearby players - keep melee topped off.",
				"On Heroic, be ready for massive spike damage from {spell:36819} if interrupts fail.",
				"Phase 2: During {spell:44224}, learn to heal while flying - this takes practice.",
				"Maintain healing on players being chased by Arcane Spheres.",
				"The constant Arcane damage from {spell:44224} requires steady healing on all party members.",
				"Prepare for Power Feedback windows by topping everyone off before the stun ends."
			},
			{
				role = TANK,
				"Phase 1: Tank Kael'thas in the center of the room, facing him away from the group.",
				"Move out of {spell:46162} ground effects immediately to avoid unnecessary damage.",
				"Maintain threat when DPS switches to Phoenix adds and eggs.",
				"On Heroic, coordinate with dispellers to remove {spell:46165} before {spell:36819} casts.",
				"Phase 2: During {spell:44224}, you cannot actively tank - focus on avoiding Arcane Spheres.",
				"Use the Power Feedback stun window to rebuild threat if needed.",
				"Be prepared to pick up any Phoenix adds that spawn during the aerial phase.",
				"Position Kael'thas to allow ranged DPS clear access during burn phases."
			}
		},
		abilities = {
			{
				id = 44189,
				name = "Fireball",
				description = "Kael'thas inflicts moderate Fire damage to a player. On Heroic difficulty ({spell:46164}), damage is increased. Standard filler ability used throughout Phase 1."
			},
			{
				id = 46162,
				name = "Flame Strike",
				description = "Kael'thas calls down a pillar of flame at a targeted location, burning all players within 6 yards for heavy Fire damage every second for 8 seconds. Visible ground effect - move out immediately."
			},
			{
				id = 44194,
				name = "Phoenix",
				description = "Kael'thas summons a Phoenix to aid him. The Phoenix burns all players within 8 yards for Fire damage every 2 seconds. Each burn reduces the Phoenix's health by 5%. When killed, creates a Phoenix Egg."
			},
			{
				id = 44224,
				name = "Gravity Lapse",
				description = "At 50% health, Kael'thas casts Gravity Lapse, throwing all players into the air and granting flight. Inflicts continuous Arcane damage every second for the duration of Phase 2. Learn to move in 3D space during this phase."
			},
			{
				id = 44251,
				name = "Arcane Sphere",
				description = "During {spell:44224}, Kael'thas summons 3 Arcane Spheres that pursue players in the air. Contact with a sphere inflicts heavy Arcane damage every second. Kite these while airborne and maintain distance."
			},
			{
				id = 44233,
				name = "Power Feedback",
				description = "After 30 seconds of Gravity Lapse, Kael'thas becomes stunned and takes 50% additional damage for 10 seconds. This is your primary burn window. Use all DPS cooldowns during this phase."
			},
			{
				id = 44014,
				name = "Phoenix Egg",
				description = "When a Phoenix dies, it creates an egg. If not destroyed within 15 seconds, a new Phoenix hatches. Multiple uncontrolled Phoenixes can quickly overwhelm your group. Always prioritize eggs."
			},
			{
				id = 46165,
				name = "Shock Barrier (Heroic)",
				description = "Heroic only. Kael'thas surrounds himself with a barrier absorbing 10,000 damage and granting immunity to interrupts. Immediately purge or spell steal this buff to prevent {spell:36819}."
			},
			{
				id = 36819,
				name = "Pyroblast (Heroic)",
				description = "Heroic only. Cast after {spell:46165}. Inflicts 45,000 to 55,000 Fire damage - typically fatal. Must be prevented by removing Shock Barrier before the cast completes."
			}
		}
	}
})
