--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Hall of Thanes",
	thumbnail = I.UIEJDungeonButtonTheHallOfThanes,
	icon = 527422,
	splash = 527422,
	mapID = 3065,
	seasonFilter = "forever",
	overview = "Old Ironforge lay sealed beneath the High Seat for generations, and the Dark Iron have broken it open. The hall runs in a single line through the tombs of the old thanes, and what the incursion has stirred up -- risen dwarves, bound fire and the stone guardians set to watch the dead -- is still down there with them.",
	{
		name = "Faldrim Anvilmar",
		defeated = 0,
		encounterID = 3493,
		portrait = 521744,
		loot = {
			{ id = 270227, filter = "forever" }, -- Ephemeral Choker
			{ id = 271096, filter = "forever" }, -- Aetherwisp Bracers
			{ id = 271097, filter = "forever" }, -- Spiritwraith Drape
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A dwarf of the Anvilmar line, risen from the tomb he was laid in and walking a slow circuit around it. He is the first thing the incursion disturbed, and the first thing to meet anyone following it in.",
			{ heading = "Overview" },
			"Faldrim patrols his own tomb, and the risen dwarves standing around it will come with him if the pull is careless. Clear the ground first and the fight itself is straightforward: {spell:26048} on whoever he is looking at, and {spell:1292602} to be healed through.",
			{
				role = DAMAGE,
				"Clear the undead dwarves around the tomb before the pull, then take Faldrim down in the space you have made.",
			},
			{
				role = HEALER,
				"Heal through {spell:1292602}, and watch for {spell:26048} landing on someone other than the tank.",
			},
			{
				role = TANK,
				"Pull him away from his tomb rather than into it, so the risen dwarves standing there are not dragged in as well.",
			}
		},
		abilities = {
			{ spell = 26048, heading = true }, -- Mind Blast
			{ spell = 1292602, heading = true }, -- Anvilmar's Curse
		}
	},
	{
		name = "Infurnus",
		defeated = 0,
		encounterID = 3495,
		portrait = 521744,
		loot = {
			{ id = 270230, filter = "forever" }, -- Kindlegem Girdle
			{ id = 270231, filter = "forever" }, -- Flamefist Grips
			{ id = 271095, filter = "forever" }, -- Fang of Magmatus
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Fire given shape and set loose in the deep hall. The Dark Iron summoner who called it up is still standing nearby, which says something about how much control anyone has over it.",
			{ heading = "Overview" },
			"The Dark Iron Summoner patrolling nearby is the real opening problem -- kill it before the boss. Once the fight is on, {spell:11970} goes off on everything standing close, so the group spreads and the boss gets dragged clear.",
			{
				role = DAMAGE,
				"Kill the patrolling Dark Iron Summoner before pulling the boss. Spread out so {spell:11970} catches as few of you as possible.",
			},
			{
				role = HEALER,
				"{spell:11970} hits the whole group at once and {spell:1293228} lands on someone at random, so expect damage in places other than the tank.",
			},
			{
				role = TANK,
				"Drag the boss away from the group while the rest of the party finishes the Dark Iron Summoner.",
			}
		},
		abilities = {
			{ spell = 11970, heading = true }, -- Fire Nova
			{ spell = 1293228, heading = true }, -- Combust
		}
	},
	{
		name = "Plunder",
		defeated = 0,
		encounterID = 3494,
		portrait = 521744,
		loot = {
			{ id = 270228, filter = "forever" }, -- Golemheart Stave
			{ id = 270229, filter = "forever" }, -- Treads of the Protector Golem
			{ id = 271098, filter = "forever" }, -- Golemguard Chest
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"One of the elemental guardians set to keep the hall, still walking its stretch of corridor long after the thanes it was watching over stopped needing it.",
			{ heading = "Overview" },
			"A one-ability fight that is only dangerous because of where it happens. {spell:10101} throws people backwards, and the hallway Plunder patrols has trash packs at either end of it.",
			{
				role = DAMAGE,
				"Stand where {spell:10101} will not throw you into another pack. The hallway is narrow and the packs at each end are still alive.",
			},
			{
				role = HEALER,
				"Little to manage beyond the tank's damage; the hazard here is positioning rather than throughput.",
			},
			{
				role = TANK,
				"Clear enough of the hallway to pull Plunder into a corner, away from whatever is left standing.",
			}
		},
		abilities = {
			{ spell = 10101, heading = true }, -- Knock Away
		}
	},
	{
		name = "Durgen Dirgehammer",
		defeated = 0,
		encounterID = 3496,
		portrait = 521744,
		loot = {
			{ id = 270256, filter = "forever" }, -- Durgen's Crescent Axe
			{ id = 270260, filter = "forever" }, -- Direhammer Leggings
			{ id = 270261, filter = "forever" }, -- Robes of the Disgraced Thane
			{ id = 274286, filter = "forever" }, -- Durgen Dirgehammer's Head
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"The dwarf behind the whole incursion, found at the end of the hall with two stone golems pulled off the tombs and a crew of looters working the rooms around him.",
			{ heading = "Overview" },
			"Durgen and his two Lesser Stone Golems together put more on the tank than any other fight in the hall. {spell:26070} is the reason to clear the Dark Iron Looters first -- feared into them, the pull chains and does not stop. {spell:12054} ticks on the tank throughout.",
			{
				role = DAMAGE,
				"Clear the Dark Iron Looters before the pull so {spell:26070} has nothing to fear you into. Burn Durgen down first, then the two Lesser Stone Golems.",
			},
			{
				role = HEALER,
				"{spell:12054} ticks for around 44 every three seconds on the tank, and the golems add their own damage while they are up.",
			},
			{
				role = TANK,
				"Hold Durgen and both Lesser Stone Golems; this is the heaviest incoming damage in the dungeon, and it does not let up until the golems are dead.",
			}
		},
		abilities = {
			{ spell = 26070, heading = true }, -- Fear
			{ spell = 12054, heading = true }, -- Rend
		}
	},
})
