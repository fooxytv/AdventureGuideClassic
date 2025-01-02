--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Wailing Caverns",
	instanceID = 240,
	thumbnail = 608229,
	icon = 136364,
	splash = 608313,
	mapID = 43,
	season = false,
	overview = "Years ago, the famed druid Naralex and his followers descended into the shadowy Wailing Caverns, named for the mournful cry one hears when steam bursts from the cave system's fissures. Naralex planned to use the underground springs to restore lushness to the arid Barrens. But upon entering the Emerald Dream, he saw his vision of regrowth turn into a waking nightmare, one that has plagued the caverns ever since.",
	{
		name = "Kresh",
		defeated = 0,
		encounterID = 3653,
		portrait = 607676,
		loot = { 13245 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Kresh is a massive and territorial snapping turtle that dwells deep within the Wailing Caverns. His presence in the caverns represents the diverse array of creatures that have taken refuge in this sprawling subterranean labyrinth. Kresh's imposing size and armored shell make him a formidable resident of the Wailing Caverns, challenging those who dare to venture into his territory.",
			{ heading = "Overview" },
			"Focus damage and healing on a single target. The tank should keep Kresh facing away from the group to avoid his frontal cone attack.",
			{
				role = DAMAGE,
				"Focus damage on Kresh, there will be no adds to deal with during this encounter.",
			},
			{
				role = HEALER,
				"Maintain healing on the tank and other party members as needed.",
			},
			{
				role = TANK,
				"Tank the Kresh facing away from the group.",
				"Use defensive abilities to mitigate the damage from Kresh's attacks.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Lady Anacondra",
		defeated = 0,
		encounterID = 3671,
		portrait = 607680,
		loot = { 10412 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Lady Anacondra is a formidable naga sorceress who has established herself as a resident of the Wailing Caverns. Her presence within the caverns adds a magical dimension to the already mysterious and perilous environment. Lady Anacondra's mastery of arcane magic and serpentine nature make her a unique and dangerous adversary.",
			{ heading = "Overview" },
			"Attempt to interrupt as many abilities as possible, especially {spell:9532}, {spell:5187} and {spell:700}. Tanks cannot be targeted by {spell:700}.",
			{
				role = DAMAGE,
				"Do as much damage as possible to Lady Anacondra while watching your threat.",
				"{spell:9532}, {spell:5187} and {spell:700} can be interrupted.",
				"{spell:8148} can not be purged.",
				"{spell:700} can not be casted on the tank.",
			},
			{
				role = HEALER,
				"Keep your party members alive, focus on your tank.",
			},
			{
				role = TANK,
				"Etablish and maintain threat on Lady Anacondra.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Lord Cobrahn",
		defeated = 0,
		encounterID = 3669,
		portrait = 607693,
		loot = { 6460, 10410, 6465 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Lord Cobrahn is a cunning and agile naga lord who has taken up residence within the Wailing Caverns. His presence adds an element of stealth and deception to the already complex ecosystem of the caverns. Lord Cobrahn's serpentine form and venomous attacks make him a dangerous inhabitant of this underground realm.",
			{ heading = "Overview" },
			"Lord Cobrahn can cast {spell:8040} on players, putting them to sleep for 8 seconds. This can be interrupted.",
			{
				role = DAMAGE,
				"Focus damage on Lord Cobrahn while watching your threat.",
				"{spell:9532} and {spell:5187} can be interrupted.",
				"Damage dealers are subjected to the {spell:8040} spell, effectively putting you under a sleep effect.",
				"Lord Cobrahn will cast {spell:7965} to transform into snake form under 50% health.",
				"Lord Cobrahn cast {spell:468475} while in snake form.",
			},
			{
				role = HEALER,
				"Focus your healing on the tank",
				"Lord Cobrahn will cast {spell:8040}, sleeping you for 8 seconds."
			},
			{
				role = TANK,
				"Focus on maintaining threat on Lord Cobrahn.",
				"Lord Cobrahn's {spell:9532} and {spell:5187} can be interrupted.",
				"If your healer is targeted by {spell:8040}, you will need to use a cooldown to survive the incoming damage."
			}
		},
		abilities = {
		}
	},
	{
		name = "Lord Pythas",
		defeated = 0,
		encounterID = 3670,
		portrait = 607696,
		loot = { 6473, 6472 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Lord Pythas is a powerful naga lord who has made the Wailing Caverns his domain. His presence adds a touch of arcane mystique to the already enigmatic caverns. Lord Pythas's formidable magical abilities and commanding presence make him a noteworthy adversary within the subterranean labyrinth.",
			{ heading = "Overview" },
			"Lord Pythas is accompanied by an add Druid of the Fang. Focus damage on the Druid of the Fang first, then switch to Lord Pythas.",
			{
				role = DAMAGE,
				"Lord Pythas is accompanied by an add Druid of the Fang.",
				"{spell:9532}, {spell:700} and {spell:5187} can be interrupted.",
			},
			{
				role = HEALER,
				"Focus healing on the tank, watch out for the {spell:700} ability if you are targeted.",
			},
			{
				role = TANK,
				"Establish and maintain threat on Lord Pythas, so the damage dealers can focus on the Druid of the Fang.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Skum",
		encounterID = 3674,
		portrait = 607775,
		loot = { 6449, 6448 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Skum is a monstrous murloc who resides in the watery depths of the Wailing Caverns. His presence within the caverns represents the wide array of creatures that have found refuge in its labyrinthine passages. Skum's ferocity and aquatic nature make him a formidable resident of this underground realm.",
			{ heading = "Overview" },
			"Skum casts {spell:6254}, spread out to avoid being hit.",
			{
				role = DAMAGE,
				"{spell:6254} can be interrupted, Skum is immune to nature damage.",
			},
			{
				role = HEALER,
				"Focus healing the tank while staying spread out to avoid being hit by {spell:6254}.",
			},
			{
				role = TANK,
				"Tank Skum facing away from the group.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Lord Serpentis",
		defeated = 0,
		encounterID = 3673,
		portrait = 607698,
		loot = { 10411, 6459, 5970, 6469 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Lord Serpentis is a cunning naga lord who has established himself as a resident of the Wailing Caverns. His presence within the caverns adds a touch of intrigue and danger to the underground labyrinth. Lord Serpentis's serpentine form and mastery of venomous attacks make him a dangerous adversary lurking in the shadows.",
			{ heading = "Overview" },
			"Lord Serpentis casts {spell:9532}, {spell:700} and {spell:5187}, if possible make sure to interrupt them.",
			{
				role = DAMAGE,
				"Lord Serpentis is not accompanied by an adds. {spell:9532}, {spell:700} and {spell:5187} can be interrupted.",
			},
			{
				role = HEALER,
				"Focus healing on the tank, also be aware if you're targeted by {spell:700}.",
			},
			{
				role = TANK,
				"Establish threat, and be prepared to interrupt {spell:9532} or {spell:700} if possible.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Verdan the Everliving",
		defeated = 0,
		encounterID = 5775,
		portrait = 607805,
		loot = { 6631, 6630, 6629 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Verdan the Everliving is an ancient and colossal serpent who has taken root within the Wailing Caverns. His presence in the caverns signifies the enduring power of nature and the intricate web of life within this underground ecosystem. Verdan's immense size and regenerative abilities make him a legendary inhabitant of the caverns, a living testament to the forces of nature.",
			{ heading = "Overview" },
			"Verdan the Everliving casts {spell:8142}, stunning and rooting the player for 10 seconds. This spell can not be interrupted.",
			{
				role = DAMAGE,
				"Verdan the Everliving casts {spell:}, stunning for 2 seconds and rooting the player for 10 seconds. This spell can not be interrupted",
				"Ranged damage dealers should stay 10 yards away to avoid being affected by {spell:}.",
			},
			{
				role = HEALER,
				"Stand at maximum distance to avoid being hit by {spell:8142}.",
				"Focus healing on the tank while they are knocked down by {spell:8142}, as they will not be able to defend themselves.",
			},
			{
				role = TANK,
				"Maintain threat on Verdan the Everliving, and be prepared to be knocked down by {spell:8142}.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Mutanus the Devourer",
		defeated = 0,
		encounterID = 3654,
		portrait = 607721,
		loot = { 6463, 6627, 6461 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Mutanus the Devourer is a monstrous hydra that lurks in the watery recesses of the Wailing Caverns. His presence within the caverns represents the primal and ferocious aspects of the underground ecosystem. Mutanus's multiple heads and insatiable appetite make him a terrifying resident of this labyrinthine realm.",
			{ heading = "Overview" },
			"Mutanus the Devourer casts {spell:7399} on players, causing them to fear for 4 seconds. This spell can not be interrupted.",
			{
				role = DAMAGE,
				"Mutanus the Devourer casts {spell:7399} on players, causing them to fear for 4 seconds. This spell can not be interrupted.",
				"{spell:7967} can be interrupted.",
				"Adds must be defeated first before Mutanus the Devourer emerges from the water nearby.",
			},
			{
				role = HEALER,
				"Focus on healing your tank, and be prepared to heal party members who are feared by {spell:7399}.",
				"Make sure to top off melee damage dealers after Mutanus the Devourer casts {spell:8150}.",
				"Stay maximum distance to avoid being hit by {spell:7399}.",
			},
			{
				role = TANK,
				"Tank Mutanus the Devourer away from the Disciple of Naralex to avoid him taking damage.",
				"Use defensive cooldowns to help your healers recover from {spell:8150}"
			}
		},
		abilities = {
		}
	},
})
