--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Alcaz Prison",
	icon = 527422,
	splash = 527422,
	mapID = 2994,
	seasonFilter = "forever",
	overview = "Beneath the old tower on Alcaz Island, off the coast of Dustwallow Marsh, the Defias Brotherhood kept a jail for nobles worth a ransom -- and rumour has long put a king among them. The cells are open now, the Defias jailers are at war with the Strashaz naga who have pushed in from the sea, and both Horde and Alliance have sent people down to learn who was really held there.",
	{
		name = "Overseer Wrex",
		defeated = 0,
		encounterID = 3403,
		portrait = 521744,
		loot = {
			{ id = 263992, filter = "forever" }, -- Overseer's Keyring
			{ id = 276732, filter = "forever" }, -- Alcaz Willcrusher
			{ id = 276733, filter = "forever" }, -- Grips of Control
			{ id = 276734, filter = "forever" }, -- Wrex's Pinky Ring
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 255391 },
		overview = {
			"The Defias overseer who runs the cell block, and the man carrying the keys to the rest of the prison.",
			{ heading = "Overview" },
			"Wrex walks a circuit of a round room lined with cells, and pulling him brings every jailer and bounty hunter within reach along with him. Clear the side cells first, wait for his patrol to carry him clear, and fight him on his own. His keyring opens the way deeper in.",
			{
				role = DAMAGE,
				"Clear the jailers in the side cells before the pull, and crowd-control anything that joins the fight anyway.",
			},
			{
				role = HEALER,
				"The fight is only heavy if extra jailers come with him; if they do, expect damage across the group rather than just on the tank.",
			},
			{
				role = TANK,
				"Wait for his patrol to take him away from the cells and pull him back into the corridor, not into the next room.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Tidemistress Ca'zass",
		defeated = 0,
		encounterID = 3410,
		portrait = 521744,
		loot = {
			{ id = 273883, filter = "forever" }, -- Ca'zass's Head
			{ id = 276735, filter = "forever" }, -- Tidesong Wand
			{ id = 276736, filter = "forever" }, -- Seascale Bracers
			{ id = 276737, filter = "forever" }, -- Cloak of the Tidemistress
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 255997 },
		overview = {
			"A Strashaz sea witch leading the naga push into the prison from below, holding the end of the main corridor against the Defias.",
			{ heading = "Overview" },
			"Ca'zass fights alongside two Strashaz Enchantresses, and all three throw frost volleys and polymorph people out of the fight. Kill or lock down the enchantresses first and interrupt whatever is being cast. Her blizzard leaves a frozen patch on the floor; step out of it.",
			{
				role = DAMAGE,
				"Take the two enchantresses down before Ca'zass, interrupting their casts, and move out of the blizzard as soon as it lands.",
			},
			{
				role = HEALER,
				"Frost volleys hit the whole group and polymorph can take a healer out at the wrong moment; keep everyone topped up rather than reacting late.",
			},
			{
				role = TANK,
				"Gather all three casters where the group can reach them, and keep the boss out of her own blizzard patches.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Katerina the Cleaner",
		defeated = 0,
		encounterID = 3418,
		portrait = 521744,
		loot = {
			{ id = 276738, filter = "forever" }, -- Katerina's Shanker
			{ id = 276739, filter = "forever" }, -- Cutthroat Chestguard
			{ id = 276740, filter = "forever" }, -- Sentimental Locket
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 257016 },
		overview = {
			"The Defias assassin sent to tidy up prisoners who are no longer worth keeping, working a room with a chained Kor'kron commander in it.",
			{ heading = "Overview" },
			"Katerina comes with two Alcaz Chaplains, and those go first. She vanishes from the tank and reappears behind someone else to stab them, so damage turns up all over the group. Leave the chained prisoners in the room alone until she is dead.",
			{
				role = DAMAGE,
				"Kill the two chaplains first. Do not free any prisoner mid-fight.",
			},
			{
				role = HEALER,
				"Go in at full mana. She jumps between targets, so whoever she lands behind will need healing, not just the tank.",
			},
			{
				role = TANK,
				"Pick her back up quickly each time she leaves you for someone else.",
			}
		},
		abilities = {
		}
	},
	{
		name = "The Questioner",
		defeated = 0,
		encounterID = 3415,
		portrait = 521744,
		loot = {
			{ id = 274029, filter = "forever" }, -- Ornate Shackle Key
			{ id = 276741, filter = "forever" }, -- Defias Enforcer's Shoulderpads
			{ id = 276742, filter = "forever" }, -- Girdle of Extracted Answers
			{ id = 276743, filter = "forever" }, -- Fingerbreaker Stamp
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 256236 },
		overview = {
			"The Defias interrogator who pries ransom terms and secrets out of the prisoners, and who holds the key to one of the cells that matters most.",
			{ heading = "Overview" },
			"He starts the fight with adds at his side; clear those before turning to him. The one cast worth watching is his life drain, which should be interrupted every time. He carries the key a prisoner further in needs.",
			{
				role = DAMAGE,
				"Kill his adds first, then keep an interrupt ready for the life drain.",
			},
			{
				role = HEALER,
				"Uninterrupted drains heal him and wear down whoever they hit; call it if the interrupts are being missed.",
			},
			{
				role = TANK,
				"Hold the adds together with him at the start so the group can clear them quickly.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Blazeroar",
		defeated = 0,
		encounterID = 3409,
		portrait = 521744,
		loot = {
			{ id = 276744, filter = "forever" }, -- Zarla's Snack Pouch
			{ id = 276745, filter = "forever" }, -- Beastbond Robe
			{ id = 276746, filter = "forever" }, -- Defias Enforcer's Legguards
			{ id = 276890, filter = "forever" }, -- Zarla's Journal
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 255702 },
		overview = {
			"Zarla Ober runs the prison's deepest room in a human guise, until the fight goes badly for her and she shows what she really is: a red dragon.",
			{ heading = "Overview" },
			"The fight opens against Zarla, who casts fireballs and drops flamestrikes on the group. At low health she becomes Blazeroar, breathing fire in a cone ahead of her and sending the party running with a roar. Fire does little or nothing to her, so fire casters should switch school before the pull.",
			{
				role = DAMAGE,
				"Stay out from in front of the dragon and out of the flamestrikes. Fire mages should plan to cast frost instead.",
			},
			{
				role = HEALER,
				"Expect group-wide fire damage in both forms, and a gap in healing while the fear is up; a Tremor Totem helps if there is a shaman.",
			},
			{
				role = TANK,
				"Turn Blazeroar away from the group the moment she transforms, so the breath only hits you.",
			}
		},
		abilities = {
		}
	},
})
