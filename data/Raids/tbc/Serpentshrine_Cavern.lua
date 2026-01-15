--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddRaid({
	name = "Serpentshrine Cavern",
	instanceID = 548,
	thumbnail = 608199,
	icon = 136356,
	splash = 608238,
	mapID = 332,
	seasonFilter = "tbc",
	overview = "Serpentshrine Cavern is Lady Vashj's stronghold deep beneath the waters of Zangarmarsh. From here, she commands the naga forces draining the marshlands to create a new ocean. As one of Illidan's most trusted lieutenants, she guards a vital artifact needed to enter the Black Temple.",
	{
		name = "Hydross the Unstable",
		defeated = 0,
		encounterID = 21216,
		portrait = 1385741,
		loot = {
			{ id = 30047, seasonFilter = "tbc" }, -- Luminescent Rod of the Naaru
			{ id = 30050, seasonFilter = "tbc" }, -- Robes of the Cleansing Flame
			{ id = 30055, seasonFilter = "tbc" }, -- Pauldrons of the Wardancer
			{ id = 30054, seasonFilter = "tbc" }, -- Ranger-General's Chestguard
			{ id = 30056, seasonFilter = "tbc" }, -- Robe of Hateful Echoes
			{ id = 30048, seasonFilter = "tbc" }, -- Blessed Totem of Pure Water
			{ id = 30049, seasonFilter = "tbc" }  -- Fathomstone
		},
		sharedLoot = {
			{ id = 30244, seasonFilter = "tbc" }, -- Helm of the Fallen Champion (Tier 5)
			{ id = 30249, seasonFilter = "tbc" }, -- Helm of the Fallen Defender (Tier 5)
			{ id = 30237, seasonFilter = "tbc" }  -- Helm of the Fallen Hero (Tier 5)
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 21216 },
		overview = {
			"Hydross the Unstable is a massive hydra torn between two natures - pure water and fel corruption. Exposed to both forces, Hydross violently shifts between pure and corrupt forms every 25% health. The cavern is divided into Pure and Corrupt sides, and the raid must move between them to avoid devastating damage from the wrong element.",
			{ heading = "Overview" },
			"This fight requires precise positioning and phase transitions. Start on the Pure (blue) side. At 75%, 50%, and 25%, Hydross transitions forms and the entire raid must move to the opposite side. Four tanks are required: two for Hydross (swapping on stacks) and two for adds. Kill transition adds quickly. Dispel {spell:38235} immediately.",
			{
				role = DAMAGE,
				"Stay on the correct side of the room matching Hydross's current form or take massive damage.",
				"Kill Corrupted/Purified Elemental adds immediately when they spawn during transitions.",
				"Watch your {spell:38246} (Vile Sludge) or {spell:38215} (Mark of Hydross) debuff stacks - too many means raid damage.",
				"Move as a coordinated group during transitions to prevent add spawns.",
				"Do not stand on the wrong side of the cavern or you'll spawn additional adds."
			},
			{
				role = HEALER,
				"Dispel {spell:38235} (Water Tomb) on players encased in water tombs - top priority.",
				"Heavy tank damage from stacking DoTs: {spell:38219} (Mark of Corruption) and {spell:38246} (Vile Sludge).",
				"During transitions, be ready for spike damage on the raid.",
				"Keep tanks topped during high stack counts before swaps.",
				"Position correctly during transitions or you'll be out of range."
			},
			{
				role = TANK,
				"Four tanks needed: two for Hydross, two for adds.",
				"Main tanks swap on Hydross every 3-4 stacks of {spell:38219} (Mark of Corruption) or {spell:38215} (Mark of Hydross).",
				"Add tanks pick up Corrupted/Purified Elementals during transitions.",
				"Lead the raid to the correct side during phase transitions.",
				"Call out your stack count for clean tank swaps."
			}
		},
		abilities = {}
	},
	{
		name = "The Lurker Below",
		defeated = 0,
		encounterID = 21217,
		portrait = 1385768,
		loot = {
			{ id = 30665, seasonFilter = "tbc" }, -- Fathomstone
			{ id = 30054, seasonFilter = "tbc" }, -- Cord of Screaming Terrors
			{ id = 30064, seasonFilter = "tbc" }, -- Mallet of the Tides
			{ id = 30062, seasonFilter = "tbc" }, -- Grove-Bands of Remulos
			{ id = 30060, seasonFilter = "tbc" }, -- Boots of Effortless Striking
			{ id = 30063, seasonFilter = "tbc" }, -- Libram of the Lightbringer
			{ id = 30065, seasonFilter = "tbc" }  -- Serpentshrine Shuriken
		},
		sharedLoot = {
			{ id = 30244, seasonFilter = "tbc" }, -- Helm of the Fallen Champion (Tier 5)
			{ id = 30249, seasonFilter = "tbc" }, -- Helm of the Fallen Defender (Tier 5)
			{ id = 30237, seasonFilter = "tbc" }  -- Helm of the Fallen Hero (Tier 5)
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 21217 },
		overview = {
			"The Lurker Below is an ancient coilfang beast dwelling in the deepest waters of Serpentshrine. The encounter alternates between surface and submerge phases. During the surface phase, the raid must avoid the deadly {spell:37433} (Spout) by jumping into the water or risk instant death. When submerged, waves of adds spawn on fishing platforms.",
			{ heading = "Overview" },
			"Spread around the platform edge in a circle. Watch the boss carefully during {spell:37433} (Spout) - it rotates and shoots water. Jump into the water to avoid the water stream or die instantly. Tank swap on {spell:37478} (Geyser) damage. During Submerge phase, kill all 9 adds (Ambushers and Guardians) before Lurker returns. Assign groups to specific platforms.",
			{
				role = DAMAGE,
				"Spread evenly around the platform edge to minimize {spell:37478} (Geyser) splash damage.",
				"Watch Lurker closely - when {spell:37433} (Spout) begins, jump into the water immediately.",
				"Getting hit by {spell:37433} (Spout) means instant death - this is not negotiable.",
				"During Submerge phase, burn all adds on your assigned platform quickly.",
				"Stay in melee range or boss will cast {spell:37138} (Water Bolt) which one-shots players."
			},
			{
				role = HEALER,
				"Position around the platform with good line of sight to the raid.",
				"Jump into water during {spell:37433} (Spout) - you cannot heal if you're dead.",
				"Moderate tank damage during surface phase from melee attacks.",
				"During Submerge phase, expect spike damage from adds on platforms.",
				"Watch for {spell:37478} (Geyser) damage on random raid members."
			},
			{
				role = TANK,
				"Main tank holds Lurker during surface phase.",
				"Stay in melee range at all times to prevent {spell:37138} (Water Bolt) casts.",
				"During {spell:37433} (Spout), jump into the water like everyone else.",
				"During Submerge phase, pick up adds on your assigned platform.",
				"Tank Ambushers away from casters and Guardians away from melee."
			}
		},
		abilities = {}
	},
	{
		name = "Leotheras the Blind",
		defeated = 0,
		encounterID = 21215,
		portrait = 1385751,
		loot = {
			{ id = 30056, seasonFilter = "tbc" }, -- Coral-Barbed Shoulderpads
			{ id = 30054, seasonFilter = "tbc" }, -- Tsunami Talisman
			{ id = 30051, seasonFilter = "tbc" }, -- Girdle of the Invulnerable
			{ id = 30057, seasonFilter = "tbc" }, -- Vestments of the Sea-Witch
			{ id = 30091, seasonFilter = "tbc" }, -- True-Aim Stalker Bands
			{ id = 30095, seasonFilter = "tbc" }, -- Ring of Sundered Souls
			{ id = 30096, seasonFilter = "tbc" }  -- Girdle of the Tidal Call
		},
		sharedLoot = {
			{ id = 30245, seasonFilter = "tbc" }, -- Gloves of the Fallen Champion (Tier 5)
			{ id = 30250, seasonFilter = "tbc" }, -- Gloves of the Fallen Defender (Tier 5)
			{ id = 30238, seasonFilter = "tbc" }  -- Gloves of the Fallen Hero (Tier 5)
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 21215, 21857 },
		overview = {
			"Leotheras the Blind is a night elf demon hunter consumed by his inner demons. He alternates every 45 seconds between Demon form (which must be kited during {spell:37640} Whirlwind) and Elf form (which is tankable). At 50% health, every raid member is banished to fight their own Inner Demon solo. At 15%, both forms merge for a final burn phase.",
			{ heading = "Overview" },
			"Demon form: Designated kiter (druid/hunter) kites during {spell:37640} (Whirlwind). Elf form: tanks pick up normally. At 50%, EVERYONE fights their own {spell:37676} (Inner Demon) solo - must win or be mind controlled. Use all personal cooldowns. At 15%, both forms merge - burn phase with all abilities active including {spell:37675} (Chaos Blast).",
			{
				role = DAMAGE,
				"Demon form: Burn boss while designated kiter keeps him moving during {spell:37640} (Whirlwind).",
				"Elf form: DPS normally while tanks hold him.",
				"Inner Demon phase at 50%: Solo burn your demon clone using all cooldowns. Everyone must win.",
				"Final phase at 15%: Maximum burn with both forms merged.",
				"In demon form, avoid stacking {spell:37675} (Chaos Blast) debuffs - spread out."
			},
			{
				role = HEALER,
				"Demon form: Heal the kiter heavily during {spell:37640} (Whirlwind).",
				"Elf form: Standard tank healing.",
				"Inner Demon phase: You're on your own - burn your demon fast using damage abilities.",
				"Watch for {spell:37749} (Consuming Madness) - anyone who fails becomes mind controlled.",
				"Final phase: Massive raid damage from both Whirlwind and Chaos Blast - use all cooldowns."
			},
			{
				role = TANK,
				"Main tank picks up Leotheras in Elf form only.",
				"During Demon form {spell:37640} (Whirlwind), do NOT tank - let designated kiter handle it.",
				"Inner Demon phase: Kill your demon like everyone else - must burn it down quickly.",
				"Final phase: Pick up merged boss and use all defensive cooldowns.",
				"Be ready to taunt if main tank becomes mind controlled from failing Inner Demon."
			}
		},
		abilities = {}
	},
	{
		name = "Fathom-Lord Karathress",
		defeated = 0,
		encounterID = 21214,
		portrait = 1385729,
		loot = {
			{ id = 30663, seasonFilter = "tbc" }, -- Fathom-Brooch of the Tidewalker
			{ id = 30665, seasonFilter = "tbc" }, -- Frayed Tether of the Drowned
			{ id = 30621, seasonFilter = "tbc" }, -- Tidewalker Greatstaff
			{ id = 30627, seasonFilter = "tbc" }, -- Tide-Stomper's Greaves
			{ id = 30100, seasonFilter = "tbc" }, -- Soul-Strider Boots
			{ id = 30101, seasonFilter = "tbc" }, -- Bloodsea Brigand's Vest
			{ id = 30090, seasonFilter = "tbc" }  -- World Breaker
		},
		sharedLoot = {
			{ id = 30245, seasonFilter = "tbc" }, -- Gloves of the Fallen Champion (Tier 5)
			{ id = 30250, seasonFilter = "tbc" }, -- Gloves of the Fallen Defender (Tier 5)
			{ id = 30238, seasonFilter = "tbc" }  -- Gloves of the Fallen Hero (Tier 5)
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 21214, 21966, 21965, 21964 },
		overview = {
			"Fathom-Lord Karathress commands three elite guards, each with unique abilities. This council fight requires four tanks to keep all bosses separated by 30+ yards. Kill order typically: Caribdis (healer) > Tidalvess (shaman) > Sharkkis (hunter) > Karathress. As each guard dies, Karathress gains their abilities.",
			{ heading = "Overview" },
			"Four-tank fight - keep all bosses 30+ yards apart. Kill order: Caribdis > Tidalvess > Sharkkis > Karathress. Interrupt Caribdis's healing. Kill Tidalvess's {spell:38236} (Spitfire Totem) immediately - cannot let them buff. Dispel or kite Sharkkis during {spell:38373} (The Beast Within). Watch for {spell:38441} (Cataclysmic Bolt) from Karathress.",
			{
				role = DAMAGE,
				"Focus fire on the kill target: Caribdis first, then Tidalvess, Sharkkis, finally Karathress.",
				"Interrupt Caribdis's healing - highest priority interrupt in the fight.",
				"Kill {spell:38236} (Spitfire Totem) from Tidalvess immediately - they buff damage massively.",
				"Kill totems from Tidalvess quickly to prevent buffs and damage.",
				"When Sharkkis uses {spell:38373} (The Beast Within), he must be kited or dispelled quickly."
			},
			{
				role = HEALER,
				"Four tanks need simultaneous healing - spread healers across all tanks.",
				"Dispel or interrupt Caribdis's healing if it gets through.",
				"Heavy tank damage throughout - all four tanks take boss hits.",
				"Watch for {spell:38441} (Cataclysmic Bolt) - deals 50% max health and stuns.",
				"After guards die, Karathress gains their abilities: {spell:38451}, {spell:38452}, {spell:38455}."
			},
			{
				role = TANK,
				"Four tanks required - one per boss.",
				"Keep bosses separated by 30+ yards at all times.",
				"Call out which boss you're tanking clearly.",
				"Tank assignments: MT on Karathress, OTs on the three guards.",
				"Watch for {spell:38445} (Sear Nova) - deals damage to all in melee range of Karathress."
			}
		},
		abilities = {}
	},
	{
		name = "Morogrim Tidewalker",
		defeated = 0,
		encounterID = 21213,
		portrait = 1385756,
		loot = {
			{ id = 30052, seasonFilter = "tbc" }, -- Pauldrons of the Argent Sentinel
			{ id = 30050, seasonFilter = "tbc" }, -- Girdle of the Tidewalker
			{ id = 30627, seasonFilter = "tbc" }, -- Tsunami Talisman
			{ id = 30085, seasonFilter = "tbc" }, -- Chain of the Twilight Owl
			{ id = 30081, seasonFilter = "tbc" }, -- Warboots of Obliteration
			{ id = 30068, seasonFilter = "tbc" }, -- Girdle of the Tidal Call
			{ id = 30084, seasonFilter = "tbc" }  -- Razor-Scale Battlecloak
		},
		sharedLoot = {
			{ id = 30246, seasonFilter = "tbc" }, -- Shoulders of the Fallen Champion (Tier 5)
			{ id = 30251, seasonFilter = "tbc" }, -- Shoulders of the Fallen Defender (Tier 5)
			{ id = 30239, seasonFilter = "tbc" }  -- Shoulders of the Fallen Hero (Tier 5)
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 21213 },
		overview = {
			"Morogrim Tidewalker is a massive sea giant who commands the tides to crush his enemies. Every 45 seconds, {spell:37730} (Tidal Wave) knocks back the entire raid, resets threat, and deals massive damage. The deadly {spell:38023} (Watery Grave) mechanic encases 4 random players in water globes, spawning murlocs underneath that must be killed immediately or the trapped players die.",
			{ heading = "Overview" },
			"Stack loosely as a raid for {spell:37730} (Tidal Wave) positioning. Multiple tanks to quickly pick up threat after each {spell:37730} threat reset. When {spell:38023} (Watery Grave) traps 4 players, assigned DPS groups must kill the murlocs under each grave immediately or trapped players die. At 25%, {spell:37854} (Summon Water Globule) spawns adds that fixate and explode.",
			{
				role = DAMAGE,
				"Assign into groups for {spell:38023} (Watery Grave) - each group kills murlocs under one grave.",
				"When someone is trapped in {spell:38023}, kill their murlocs IMMEDIATELY.",
				"If murlocs aren't killed fast, the trapped player dies when the grave expires.",
				"After each {spell:37730} (Tidal Wave), DPS must resume quickly despite the knockback.",
				"At 25%, kill {spell:37854} (Water Globules) before they reach targets or they explode."
			},
			{
				role = HEALER,
				"Heavy raid damage from {spell:37730} (Tidal Wave) every 45 seconds.",
				"Players trapped in {spell:38023} (Watery Grave) take damage and will die if murlocs aren't killed.",
				"Keep the raid topped before each {spell:37730} - predictable timing.",
				"Stay grouped with the raid for efficient healing after knockbacks.",
				"At 25%, adds from {spell:37854} spawn - easier than earlier phases."
			},
			{
				role = TANK,
				"Multiple tanks required to handle {spell:37730} (Tidal Wave) threat resets.",
				"After each {spell:37730}, all tanks rush in to pick up threat.",
				"Communicate who has aggro after each knockback.",
				"Position Morogrim so {spell:37730} doesn't knock raid into walls.",
				"Pick up murlocs during {spell:38023} phases quickly."
			}
		},
		abilities = {}
	},
	{
		name = "Lady Vashj",
		defeated = 0,
		encounterID = 21212,
		portrait = 1385750,
		loot = {
			{ id = 30082, seasonFilter = "tbc" }, -- Fang of Vashj
			{ id = 30107, seasonFilter = "tbc" }, -- Vestments of the Sea-Witch
			{ id = 30109, seasonFilter = "tbc" }, -- Coral Band of the Revived
			{ id = 30106, seasonFilter = "tbc" }, -- Krakken-Heart Breastplate
			{ id = 30102, seasonFilter = "tbc" }, -- Krakken-Heart Breastplate
			{ id = 30108, seasonFilter = "tbc" }, -- Lightfathom Scepter
			{ id = 30104, seasonFilter = "tbc" }  -- Cobra-Lash Boots
		},
		sharedLoot = {
			{ id = 30247, seasonFilter = "tbc" }, -- Leggings of the Fallen Champion (Tier 5)
			{ id = 30252, seasonFilter = "tbc" }, -- Leggings of the Fallen Defender (Tier 5)
			{ id = 30240, seasonFilter = "tbc" }  -- Leggings of the Fallen Hero (Tier 5)
		},
		rareLoot = {
			{ id = 30183, seasonFilter = "tbc" }  -- Vashj's Vial Remnant (Quest item for Black Temple attunement)
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 21212 },
		overview = {
			"Lady Vashj is one of Illidan's most loyal commanders, transformed from a night elf into a naga. This infamous three-phase encounter culminates in Phase 2's core mechanic, requiring perfect coordination. Phase 1 (100-70%): burn Vashj, kill striders, spread for {spell:38280} (Static Charge). Phase 2 (70-50%): disable 4 shield generators by collecting Tainted Cores from naga, while kiting elementals. Phase 3 (50-0%): final burn with toxic spore bats.",
			{ heading = "Overview" },
			"Phase 1: MT on Vashj, kill strider adds, spread for {spell:38280} (Static Charge). Phase 2: The infamous core phase - kite elementals continuously, kill naga for Tainted Cores, 4 players carry cores to generators. All 4 generators must be disabled. Phase 3: Burn phase, avoid toxic spore bat poison pools, CC {spell:38511} (Persuasion) targets.",
			{
				role = DAMAGE,
				"Phase 1: Kill Coilfang Strider adds immediately when they spawn - kite them, never melee.",
				"Phase 2: Kill Tainted Elementals to get Tainted Cores. Kite Enchanted Elementals - do NOT kill them.",
				"Phase 2: If assigned as core runner, carry core to generator and click it.",
				"Phase 3: Maximum burn. Avoid toxic spore bat poison pools on the ground.",
				"Phase 3: Kill Toxic Spore Bats quickly before poison pools cover the platform."
			},
			{
				role = HEALER,
				"Phase 1: Spread for {spell:38280} (Static Charge). If you get it, run away from raid.",
				"Phase 1: Heavy tank damage from {spell:38509} (Shock Blast). Heal through {spell:38280}.",
				"Phase 2: Core runners take massive DoT from cores - need heavy dedicated healing.",
				"Phase 3: Increasing poison pools from spore bats. {spell:38511} (Persuasion) mind controls.",
				"Use cooldowns in Phase 3 - this is the hardest healing phase."
			},
			{
				role = TANK,
				"Phase 1: MT on Vashj at edge. Watch for {spell:38316} (Entangle) roots.",
				"Phase 1: Position Vashj facing away for {spell:38509} (Shock Blast).",
				"Phase 2: Elementals cannot be tanked - hunters/warlocks kite them continuously.",
				"Phase 3: MT picks up Vashj again. Use defensive cooldowns.",
				"Phase 3: OTs ready to pick up {spell:38511} (Persuasion) mind-controlled players."
			}
		},
		abilities = {}
	}
})
