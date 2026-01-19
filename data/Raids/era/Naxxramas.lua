--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Naxxramas",
	instanceID = 746,
	thumbnail = 1396587,
	icon = 136347,
	splash = 1396506,
	mapID = 533,
	season = false,
	overview = "Naxxramas is the dread citadel of the lich Kel'Thuzad, floating above the plagued lands of the Eastern Kingdoms. Once a member of the Kirin Tor, Kel'Thuzad betrayed his people to serve the Lich King and now commands the Scourge's most powerful forces from within this necropolis. Divided into four wings - the Arachnid Quarter, Plague Quarter, Military Quarter, and Construct Quarter - Naxxramas represents the pinnacle of undead might and the greatest challenge heroes will face in their war against the Scourge.",
	{
		name = "Anub'Rekhan",
		encounterID = 15956,
		portrait = 1378964,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15956 },
		overview = {
			"Anub'Rekhan is the first boss in the Spider Wing of Naxxramas. Once a powerful Nerubian king, he now serves the Lich King in undeath.",
			{ heading = "Overview" },
			"This is generally one of the easier encounters in Naxxramas. The raid must spread in an arc to avoid multiple players being hit by Impale, and run away during Locust Swarm to avoid the 30-yard snare and silence aura.",
			{
				role = DAMAGE,
				"Spread out in an arc formation around the boss to minimize Impale casualties. When Locust Swarm begins, assist in killing the spawned Crypt Guard adds quickly.",
			},
			{
				role = HEALER,
				"Position carefully - if multiple healers are hit by Impale simultaneously, it can be deadly. Be prepared for spike damage from Impale and the Nature DoT from Crypt Guard's Acid Spit.",
			},
			{
				role = TANK,
				"When Anub'Rekhan casts Locust Swarm, immediately run away maintaining 30+ yards distance for 20 seconds. Pick up Crypt Guard adds that spawn. Watch for their Cleave ability.",
			}
		},
		abilities = {
			{ spell = 28783, category = FILTER_AOE },
			{ spell = 28785, category = FILTER_AOE },
			{ spell = 20569, category = FILTER_TANK },
		}
	},
	{
		name = "Grand Widow Faerlina",
		encounterID = 15953,
		portrait = 1378980,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15953 },
		overview = {
			"Grand Widow Faerlina is the second boss of the Arachnid Quarter in Naxxramas, commanding her worshippers to enhance her deadly abilities.",
			{ heading = "Overview" },
			"This fight revolves around managing Faerlina's Frenzy by using Widow's Embrace from mind-controlled Worshippers. Every minute she will Frenzy, increasing damage by 150% and attack speed by 50%.",
			{
				role = DAMAGE,
				"Only the 10 closest players will be hit by Poison Bolt Volley - ranged DPS should stay beyond this range. Avoid standing in Rain of Fire. Focus down Worshippers as needed for the strategy.",
			},
			{
				role = HEALER,
				"Dispel Poison Bolt Volley quickly - it deals heavy Nature damage over time. The 10 closest players will take significant damage. Be ready for increased tank damage during Frenzy if a Worshipper isn't available.",
			},
			{
				role = TANK,
				"Priests must mind control Worshippers and use Widow's Embrace AFTER Faerlina Frenzies to silence her for 60 seconds. Using it before only delays Frenzy by 30 seconds. Requires excellent timing.",
			}
		},
		abilities = {
			{ spell = 28794, category = FILTER_AOE },
			{ spell = 28796, category = FILTER_AOE },
			{ spell = 28798, category = FILTER_TANK },
		}
	},
	{
		name = "Maexxna",
		encounterID = 15952,
		portrait = 1378994,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15952 },
		overview = {
			"Maexxna is the third and final boss of the Spider Wing in Naxxramas. This massive spider presents a multi-mechanic encounter with web wraps, raid-wide stuns, and deadly poison.",
			{ heading = "Overview" },
			"This fight requires managing Web Wrapped players, dispelling Necrotic Poison immediately, and dealing with spawned spiderlings. At 30% health, Maexxna Frenzies, increasing damage output significantly.",
			{
				role = DAMAGE,
				"Free Web Wrapped players quickly by DPSing the web cocoons on the walls. Kill Maexxna Spiderlings as they spawn. Never stand in front of the boss to avoid Poison Shock. At 30%, burn through the Frenzy phase.",
			},
			{
				role = HEALER,
				"Dispel Necrotic Poison IMMEDIATELY - it reduces healing received by 90%. Spiderlings apply a weaker 75% version. Prepare for Web Spray - a 6-second raid-wide stun with heavy Nature damage.",
			},
			{
				role = TANK,
				"Keep Maexxna facing away from the raid to prevent Poison Shock splash damage. Tank spiderlings separately. Be ready for significantly increased damage after 30% from Frenzy.",
			}
		},
		abilities = {
			{ spell = 28622, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 29484, category = FILTER_AOE },
			{ spell = 28776, category = FILTER_HEALER },
			{ spell = 28741, category = FILTER_TANK },
			{ spell = 19451, category = FILTER_TANK },
		}
	},
	{
		name = "Noth the Plaguebringer",
		encounterID = 15954,
		portrait = 1379004,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15954 },
		overview = {
			"Noth the Plaguebringer is the first boss of the Plague Wing of Naxxramas. Now more undead than Human, he is an extremely powerful Necromancer.",
			{ heading = "Overview" },
			"This is a two-phase encounter where Noth teleports to a balcony, becoming unreachable while waves of adds spawn. After 90 seconds he returns. Quick decursing and add management are essential.",
			{
				role = DAMAGE,
				"Focus on killing Plagued Champions quickly during Noth's teleport phases. Avoid getting hit by Curse of the Plaguebringer as it will infect you and nearby allies with Wrath of the Plaguebringer.",
			},
			{
				role = HEALER,
				"Druids and Mages must decurse Curse of the Plaguebringer immediately, prioritizing melee DPS. If not dispelled, it spreads Wrath of the Plaguebringer dealing heavy Nature damage over time to the target and nearby allies.",
			},
			{
				role = TANK,
				"Noth blinks periodically causing a complete aggro wipe. Be ready to re-establish threat quickly. Tank adds during teleport phases. Cripple reduces attack speed, movement speed, and Strength by 50%.",
			}
		},
		abilities = {
			{ spell = 29212, category = FILTER_TANK },
			{ spell = 29213, category = FILTER_HEALER },
			{ spell = 29214, category = FILTER_AOE },
		}
	},
	{
		name = "Heigan the Unclean",
		encounterID = 15936,
		portrait = 1378984,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15936 },
		overview = {
			"Heigan the Unclean, now more undead than Human, is an extremely powerful Necromancer with a various array of deadly spells and curses.",
			{ heading = "Overview" },
			"This encounter is famous for the 'dance' mechanic where players must move through safe zones while avoiding deadly eruptions. Master the dance pattern, and you master the fight.",
			{
				role = DAMAGE,
				"Stay spread out during Phase 1 to avoid multiple players being hit by Decrepit Fever. During the dance phase, focus on survival first - DPS is secondary to staying alive.",
			},
			{
				role = HEALER,
				"Dispel Decrepit Fever immediately - it deals massive damage and reduces max health by 50% to all players within 20 yards. During Phase 2, focus on healing while moving through safe zones.",
			},
			{
				role = TANK,
				"Tank Heigan near the edge of the platform, slowly moving him through safe zones during eruptions. Be aware of the Spell Disruption aura that increases cast times by 300% within 20 yards.",
			}
		},
		abilities = {
			{ spell = 29310, category = FILTER_DAMAGE_DEALER },
			{ spell = 29998, category = FILTER_HEALER },
			{ spell = 17731, category = FILTER_AOE },
		}
	},
	{
		name = "Loatheb",
		encounterID = 16011,
		portrait = 1378991,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16011 },
		overview = {
			"Loatheb is the third and final boss of the Plague Quarter. The name 'Loatheb' is an anagram for 'healbot,' which is fitting given his healing prevention mechanics.",
			{ heading = "Overview" },
			"This is a DPS race with severe healing restrictions. Loatheb places a cooldown on all healing spells, allowing healing only for brief 3-second windows every 20 seconds. Players must rely heavily on consumables.",
			{
				role = DAMAGE,
				"Kill Fungal Spores quickly to gain massive critical strike and threat reduction buffs. This is a pure DPS race - use all cooldowns and consumables. After 2 minutes, Inevitable Doom begins ticking for heavy raid-wide shadow damage.",
			},
			{
				role = HEALER,
				"You can only heal during brief 3-second windows. Focus all healing on tanks during these windows. Healers should use Shadow Protection Potions to survive Inevitable Doom. Coordination is critical.",
			},
			{
				role = TANK,
				"Use consumables heavily to stay alive between healing windows. The Poison Aura deals constant Nature damage in melee range. Ensure you have full buffs and resist gear.",
			}
		},
		abilities = {
			{ spell = 29204, category = FILTER_AOE },
			{ spell = 29234, category = FILTER_DAMAGE_DEALER },
			{ spell = 29865, category = FILTER_TANK },
		}
	},
	{
		name = "Instructor Razuvious",
		encounterID = 16061,
		portrait = 1378988,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16061 },
		overview = {
			"Instructor Razuvious is the first boss in the Deathknight Wing of Naxxramas. He trains the death knights and his power is too great for normal tanks to withstand.",
			{ heading = "Overview" },
			"This fight requires at least two Priests to mind control Deathknight Understudies, as they are the only units capable of tanking Razuvious. Coordination between priests is critical to prevent tank deaths and raid wipes.",
			{
				role = DAMAGE,
				"Everyone must break line of sight when Disrupting Shout is cast or be hit for 6,200-8,500 damage plus mana burn. Position behind pillars. Focus damage on Razuvious while priests handle the tank swaps.",
			},
			{
				role = HEALER,
				"Priests must mind control Deathknight Understudies to tank. Use their Shield Wall before taunting. Swap tanks when Unbalancing Strike is cast (reduces defense by 100). All other healers break LoS for Disrupting Shout.",
			},
			{
				role = TANK,
				"Warriors cannot tank this boss - Unbalancing Strike deals 350% weapon damage and reduces defense by 100. Only mind-controlled Understudies can survive. All tanks should break LoS during Disrupting Shout.",
			}
		},
		abilities = {
			{ spell = 26613, category = FILTER_TANK },
			{ spell = 29107, category = FILTER_AOE },
			{ spell = 29125, category = FILTER_OTHER },
		}
	},
	{
		name = "Gothik the Harvester",
		encounterID = 16060,
		portrait = 1378979,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16060 },
		overview = {
			"Gothik the Harvester is the second boss in the Deathknight Wing of Naxxramas. He commands the undead from his platform while a gate divides the raid between living and dead sides.",
			{ heading = "Overview" },
			"Phase 1 lasts 4 minutes and 34 seconds. A gate divides the room - adds spawn on the living side and resurrect on the undead side when killed. At 4:34, the gate opens and Gothik becomes attackable. Coordinate add management between both sides.",
			{
				role = DAMAGE,
				"Split between living and undead sides. Living side kills adds quickly; undead side handles spectral versions. Watch for Death Plague disease from Trainees, Shadow Mark from Death Knights, and AoE from spectral adds.",
			},
			{
				role = HEALER,
				"Dispel Death Plague disease immediately - it stacks infinitely and deals 170 Nature damage every 3 seconds. Phase 2: Harvest Soul reduces all raid stats by 10% every 15 seconds, stacking 10 times. Heal through constant Shadow Bolt damage.",
			},
			{
				role = TANK,
				"Living side: tank melee adds. Undead side: handle spectral versions. Spectral Riders drain 12,000 life over 5 seconds. In Phase 2, Gothik is tauntable and keeps aggro through teleports. He chain-casts 1-second Shadow Bolts for 4,500-5,500 damage.",
			}
		},
		abilities = {
			{ spell = 28679, category = FILTER_AOE },
			{ spell = 29317, category = FILTER_TANK },
		}
	},
	{
		name = "The Four Horsemen",
		encounterID = 181366,
		portrait = 1385732,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16064, 16065, 16062, 16063 },
		overview = {
			"The Four Horsemen - Highlord Mograine, Thane Korth'azz, Lady Blaumeux, and Sir Zeliek - comprise one of the most challenging encounters in Classic. Four death knights must be fought simultaneously in their assigned corners.",
			{ heading = "Overview" },
			"This council encounter revolves around Marks - each Horseman casts their unique Mark with 70-yard range every few seconds. Marks last 75 seconds and stack, dealing exponentially increasing damage. Tanks must rotate between Horsemen before reaching deadly stack counts. At 20 minutes, the Horsemen enrage.",
			{
				role = DAMAGE,
				"Split DPS between Horsemen based on strategy. Common approach: kill Thane first, then Lady, then Mograine and Zeliek together. Watch your Mark stacks - rotate to different corners as directed. Horsemen use Shield Wall at 50% and 20%, reducing damage taken by 75% for 20 seconds.",
			},
			{
				role = HEALER,
				"Each Mark type deals different damage - rotate positions to manage stacks. Marks stack multiplicatively, so high stacks are deadly. Dispels and cleanses are critical. At death, Horsemen become spirits rooted in place, retaining all abilities.",
			},
			{
				role = TANK,
				"This encounter historically required 8 warrior tanks. Each Horseman must be tanked in their corner. Rotate tanks every 3-4 Mark stacks to prevent death. Thane Korth'azz casts Meteor (split damage AoE). Coordinate rotations precisely with your tank team.",
			}
		},
		abilities = {
			{ spell = 28832, category = FILTER_AOE },
			{ spell = 28884, category = FILTER_AOE },
		}
	},
	{
		name = "Patchwerk",
		encounterID = 16028,
		portrait = 1379005,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 16028 },
		overview = {
			"Patchwerk is the first boss of the Abomination Wing and serves as the ultimate gear check. This is a pure tank-and-spank encounter with a 7-minute enrage timer requiring approximately 9,500 raid DPS minimum.",
			{ heading = "Overview" },
			"Patchwerk has approximately 3,850,000 HP. He hits the main tank extremely hard and uses Hateful Strike every 1.2 seconds on the highest HP target among the 2nd, 3rd, and 4th on the threat table. This requires 3 off-tanks with high HP pools in melee range.",
			{
				role = DAMAGE,
				"Pure DPS race - use all cooldowns and consumables. You need 9,500+ raid DPS to beat the 7-minute enrage. At 5%, Patchwerk enters a secondary enrage increasing damage by 5x. Burn him down quickly.",
			},
			{
				role = HEALER,
				"This is one of the most healing-intensive fights in Classic. Main tank takes massive damage. Three off-tanks must also be kept alive from Hateful Strikes (22,100-29,900 physical damage every 1.2 seconds). Coordinate healing assignments carefully.",
			},
			{
				role = TANK,
				"Main tank: Hold aggro (easy fight for threat). Three off-tanks: Stand in melee as 2nd, 3rd, and 4th on threat with maximum HP to absorb Hateful Strikes. These cannot crit or be crushing blows but still hit extremely hard. Full consumables required.",
			}
		},
		abilities = {
			{ spell = 28308, category = FILTER_TANK },
			{ spell = 28131, category = FILTER_OTHER },
			{ spell = 26662, category = FILTER_OTHER },
		}
	},
	{
		name = "Grobbulus",
		encounterID = 15931,
		portrait = 1378981,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15931 },
		overview = {
			"Grobbulus is the second boss of the Abomination Wing, a massive flesh giant pieced together in Naxxramas' experimental laboratories. His poison-based abilities create permanent ground hazards.",
			{ heading = "Overview" },
			"This is a movement-intensive fight. Grobbulus leaves permanent Poison Clouds wherever he walks. Players injected with Mutating Injection must run to designated drop zones. At 30%, injection frequency increases dramatically, requiring excellent spatial awareness. Enrages at 12 minutes.",
			{
				role = DAMAGE,
				"Slime Spray spawns Fallout Slimes that must be killed. Kill these quickly as they deal 300 damage every 2 seconds in a 10-yard radius. Avoid all poison clouds. At 30%, space becomes limited - use it wisely from the start.",
			},
			{
				role = HEALER,
				"Players with Mutating Injection will explode after 10 seconds or when cleansed, dealing 4,500 physical damage in an AoE. Cleanse them at the edge of the room away from the raid. Slime Stream deals 4,500 Nature damage over 3 seconds.",
			},
			{
				role = TANK,
				"Slowly kite Grobbulus around the room's perimeter, hugging the outside wall. Move as slowly as possible to conserve safe space - his Poison Cloud is permanent. The room can fill up quickly if not managed properly.",
			}
		},
		abilities = {
			{ spell = 28157, category = FILTER_AOE },
			{ spell = 28169, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 28240, category = FILTER_AOE },
			{ spell = 28137, category = FILTER_AOE },
		}
	},
	{
		name = "Gluth",
		encounterID = 15932,
		portrait = 1378977,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15932 },
		overview = {
			"Gluth is the third boss in the Abomination Wing, a plague-dog construct with a voracious appetite for zombies. Managing adds and dispelling Frenzy are key to this encounter.",
			{ heading = "Overview" },
			"Zombie Chows spawn every 10 seconds from three grates and must be kited away from Gluth. Every 2 minutes, Decimate reduces all units (players and zombies) to 5% health. Gluth will try to eat zombies to heal 5% per zombie consumed. Prevent this at all costs.",
			{
				role = DAMAGE,
				"After Decimate, quickly AoE down all zombies while they're at 5% health. A hunter or rogue must dispel Gluth's Frenzy immediately with Tranquilizing Shot or Anesthetic Poison. Frenzy occurs approximately every 10 seconds.",
			},
			{
				role = HEALER,
				"Decimate hits the entire raid every 2 minutes, reducing everyone to 5% health. This is your warning - prepare to heal everyone back up rapidly. Zombies have Infected Wound which increases physical damage taken by 100, stacking repeatedly.",
			},
			{
				role = TANK,
				"Main tank holds Gluth. Off-tank kites Zombie Chows away from Gluth for 105 seconds until Decimate. Mortal Wound reduces healing by 10% per stack (stacks 10 times) - tank swap as needed. Prevent Gluth from reaching zombies.",
			}
		},
		abilities = {
			{ spell = 25646, category = FILTER_TANK },
			{ spell = 28371, category = FILTER_OTHER },
			{ spell = 26662, category = FILTER_OTHER },
		}
	},
	{
		name = "Thaddius",
		encounterID = 15928,
		portrait = 1379019,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15928, 15929, 15930 },
		overview = {
			"Thaddius is the fourth and final boss of the Abomination Wing. Pieced together from the flesh of women and children, this encounter begins by defeating Stalagg and Feugen simultaneously before engaging the main boss.",
			{ heading = "Overview" },
			"The signature mechanic is Polarity Shift - players receive Positive or Negative charges. Standing near players with the same charge grants 10% damage per person. Standing near opposite charges deals 4,500 damage after 5 seconds, multiplied by the number of opposite players nearby. Instant death if not sorted correctly.",
			{
				role = DAMAGE,
				"Phase 1: Kill Stalagg and Feugen within seconds of each other. Phase 2: Every Polarity Shift, instantly move to your assigned side (positive or negative). Each same-polarity player near you increases damage by 10%. Wrong positioning causes raid wipes. Chain Lightning hits 5 random players for ~7,000 Nature damage.",
			},
			{
				role = HEALER,
				"During Polarity Shift transitions, healing stops - everyone must move immediately. Missing the swap causes massive AoE damage from mismatched polarities. Chain Lightning hits multiple targets. If no one is in melee range, Ball Lightning deals 17,500-22,500 Nature damage to the tank.",
			},
			{
				role = TANK,
				"Phase 1: Tank Stalagg and Feugen on separate platforms. Kill them simultaneously. Phase 2: Stay in melee range always - if Thaddius has no melee target, he casts Ball Lightning for massive damage. During Polarity Shift, confirm your position quickly.",
			}
		},
		abilities = {
			{ spell = 28089, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 28167, category = FILTER_AOE },
			{ spell = 28299, category = FILTER_TANK },
		}
	},
	{
		name = "Sapphiron",
		encounterID = 15989,
		portrait = 1379010,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15989 },
		overview = {
			"Sapphiron is a gigantic undead frost wyrm who guards the entrance to Kel'Thuzad's inner sanctum. This two-phase encounter alternates between ground and air phases, requiring precise positioning and frost resistance.",
			{ heading = "Overview" },
			"Ground phase lasts 45 seconds. Air phase begins at 45 seconds and repeats every 67 seconds until Sapphiron reaches 10% health. During air phase, Sapphiron casts 5 Icebolts, freezing players in blocks. After 7 seconds, Frost Breath kills anyone not behind an ice block. Frost resistance is mandatory - 200+ recommended.",
			{
				role = DAMAGE,
			"Spread out at the start of air phase - Icebolt hits the target and anyone within 10 yards. After the 3rd Icebolt, move behind ice blocks for Frost Breath protection. Life Drain curse must be dispelled quickly or Sapphiron heals. Avoid moving Blizzards during ground phase. Immune to Frost spells.",
			},
			{
				role = HEALER,
				"Dispel Life Drain curse immediately - it damages the target while healing Sapphiron. Frost Aura deals 600 Frost damage every 2 seconds to the entire raid (resistible). At least 12 healers recommended with assigned positions spread throughout the raid. High frost resistance essential.",
			},
			{
				role = TANK,
				"200+ Frost Resistance required. Frost Aura hits everyone for 600 damage every 2 seconds. Sapphiron is immune to Taunt. Keep the boss positioned away from ice blocks so the raid can reach them. Avoid Blizzards. At 10%, permanently grounded.",
			}
		},
		abilities = {
			{ spell = 28531, category = FILTER_AOE },
			{ spell = 28542, category = FILTER_HEALER },
			{ spell = 28522, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 28524, category = FILTER_AOE },
			{ spell = 28560, category = FILTER_AOE },
		}
	},
	{
		name = "Kel'Thuzad",
		encounterID = 15990,
		portrait = 1378989,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 15990 },
		overview = {
			"Archlich Kel'Thuzad is the final boss of Naxxramas and the Lich King's most loyal servant. A necromancer of unmatched power, this two-phase encounter tests every aspect of raid coordination.",
			{ heading = "Overview" },
			"Phase 1 lasts 5 minutes with waves of adds: Unstoppable Abominations (apply stacking Mortal Wound), Soul Weavers (Wail of Souls knockback), and Soldiers of the Frozen Wastes (suicide Dark Blast). Phase 2: Kel'Thuzad becomes active with devastating abilities including mind control, mana detonation, and instant-death mechanics.",
			{
				role = DAMAGE,
				"Phase 1: Kill adds in order - prioritize Soul Weavers, then Soldiers. Soldiers cast Dark Blast (2,500-3,100 Shadow AoE) when reaching melee, killing themselves. Phase 2: Spread 10+ yards apart for Detonate Mana and Frost Blast. Move out of red Shadow Fissure circles immediately (3-second delay). Interrupt Frostbolt casts or the tank dies.",
			},
			{
				role = HEALER,
				"Phase 1: Mortal Wound stacks on tanks reduce healing by 10% per stack. Wail of Souls deals 6,375-8,625 Shadow damage plus 30-yard knockback to 3 players. Phase 2: Frostbolt Volley hits entire raid for 2,750-3,500 Frost damage every 15 seconds (resistible). Chains of Kel'Thuzad mind controls 5 players - CC them immediately.",
			},
			{
				role = TANK,
				"Phase 1: Tank Abominations away from raid. Manage Mortal Wound stacks with tank swaps. Phase 2: Interrupt Frostbolt (9,000-11,000 Frost damage, cast at random intervals) or it will likely kill you. Kel'Thuzad is tauntable and keeps aggro through teleports. Shadow Fissure and Frost Blast require constant movement.",
			}
		},
		abilities = {
			{ spell = 27808, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 27810, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 27819, category = FILTER_PERSONAL_RESPONSIBILITY },
			{ spell = 28408, category = FILTER_OTHER },
			{ spell = 28478, category = FILTER_TANK },
		}
	},
})
