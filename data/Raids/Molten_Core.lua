--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Molten Core",
	instanceID = 741,
	thumbnail = 1396586,
	icon = 136346,
	splash = 1396505,
	mapID = 409,
	season = false,
	overview = "",
	{
		name = "Lucifron",
		encounterID = 12118,
		portrait = 1378993,
		loot = { 16800, 16829, 16837, 16859, 16805, 16863, 17109, 16665 },
		sharedLoot = { 17077, 18861, 18879, 18870, 18872, 19147, 19145, 18875, 18878, 19146 },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Among the ranks of the flamewakers, overseers and their guards constantly jockey for higher status among the hierarchy of elementals in hopes of gaining favor with Ragnaros. Lucifron is no exception. He has clashed with Gehennas on several occasions, particularly during their incarceration within the Elemental Plane. This rivalry has now extended to the Molten Core where Lucifron quietly waits for his opportunity to capitalize on any weakness shown by the other flamewakers.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Magmadar",
		encounterID = 11982,
		portrait = 1378995,
		loot = { 16835, 16847, 16796, 16855, 16814, 16822, 16843, 16810, 16867, 17073, 18203, 17065, 17069, 18260 },
		sharedLoot = { 18823, 18829, 19142, 19143, 18861, 18824, 19136, 18822, 18821, 19144, 18820 },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"A terrifying behemoth composed of igneous rock and roiling magma, Magmadar serves as the origin of the core hounds that roam the earthen halls of Molten Core. Favourred among Ragnaros's pets, Magmadar is protected by the flamewakers Lucifron and surrounded by vicious packs of ravenous hounds. It is said that while Ragnaros was imprisoned in the Elemental Plane, the Firelord would feed the remains of his captured enemies to Magmadar, who would then consume them in a fiery blaze.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Gehennas",
		encounterID = 12259,
		portrait = 1378976,
		loot = { 16849, 16860, 16812, 16826, 16839, 16862 },
		sharedLoot = { 17077, 18861, 18879, 18870, 18872, 19147, 19145, 18875, 18878, 19146 },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Gehennas and his fellow flamewakers were extricated from the Elemental Plane by Ragnaros shortly after Thaurissan accidentally summoned the Firelord. Unlike the fire elementals, who are beings of pure flame, the flamewakers are elementals composed of flesh and blood. Gehennas resides near the bottom of the Firelord's elemental hierarchy and covets the power and station of his superiors.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Garr",
		encounterID = 12057,
		portrait = 1378975,
		loot = { 16834, 16846, 16795, 16854, 16813, 16821, 16842, 16808, 16866, 17105, 18832, 17066, 17071},
		sharedLoot = { 18823, 18829, 19142, 19143, 18861, 18824, 19136, 18822, 18821, 19144, 18820 },
		rareLoot = { 18564 },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Garr is described as one of the lieutenants of Ragnaros who carried out the betrayal of Lord Thunderaan, the Prince of Air and otherwise referred to as the Windseeker. During the Elemental Sundering, Ragnaros sought to consume Thunderaan, and did so by having his two lieutenants, Baron Geddon and Gar perpetrate him. Thunderaan, caught off guard, was utterly destroyed. Ragnaros almost completely consumed Thunderaan's essence, and stored the rest within a talisman of elemental binding.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Shazzrah",
		encounterID = 12264,
		portrait = 1379013,
		loot = { 16831, 16852, 16801, 16811, 16824, 16803 },
		sharedLoot = { 17077, 18861, 18879, 18870, 18872, 19147, 19145, 18875, 18878, 19146 },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Shazzrah is the most talented in the realm of the arcane. Shazzrah is aware that his colleague Baron Geddon suspects the elemental Garr of treachery. The conflict between Baron Geddon and Garr suits Shazzrah well, for in fact it is Shazzrah who seeks to posses both halves of the Talisman of Elemental Binding so that he might find a way to siphon its energes for his own use.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Baron Geddon",
		encounterID = 12056,
		portrait = 1378966,
		loot = { 16836, 16797, 16856, 16844, 16807, 17110 },
		sharedLoot = { 18823, 18829, 19142, 19143, 18861, 18824, 19136, 18822, 18821, 19144, 18820 },
		rareLoot = { 18563 },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Baron Geddon is one of the eldest of all fire elementals, and Baron Geddon served as Ragnaros' right hand during the beginning of the war against the titans. During one of the first battles against the then-unknown titan attacks, Geddon was defeated and forced into humiliating retreat. Ragnaros immediately demoted his commander, thinking that Geddon had been defeated by an inferior foe, since the Old Gods and their lieutenants had never yet met a challenge.",
			{ heading = "Overview" },
			"",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Golemagg the Incinerator",
		encounterID = 11988,
		portrait = 1378978,
		loot = { 16833, 16845, 16798, 16853, 16815, 16820, 16841, 16809, 16865, 17203, 17103, 17072, 18842 },
		sharedLoot = { 18823, 18829, 19142, 19143, 18861, 18824, 19136, 18822, 18821, 19144, 18820 },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Golemagg the Incinerator is unrivaled for his sheer brutality and savage efficiency. So absolute is the molten behemoth's power that he has cowed two core ragers, offspring of the colossal beast Magmadar, which he now uses as pets. For this affront, he has earned Magmadar's eternal and unwavering ire, although the fearsome creature has yet to act on his savage impulses.",
			{ heading = "Overview" },
			"",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Sulfuron Harbinger",
		encounterID = 12098,
		portrait = 1379015,
		loot = { 16848, 16816, 16823, 16868, 17074 },
		sharedLoot = { 17077, 18861, 18879, 18870, 18872, 19147, 19145, 18875, 18878, 19146 },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Sulfuron Harbinger is the terrifying herald of Ragnaros himself. From the internal depths of the Molten Core, the Harbinger commands Ambassador Flamelash and the other lesser flamewakers in the outside world. Sulfuron answers only to Executus and guards the rune of Koro, one of several runes that empower the Firelord's servants. Sulfuron keeps Shazzrah in particular under close watch, believing that Shazzrah seeks to betray Ragnaros.",
			{ heading = "Overview" },
			"",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Majordomo Executus",
		encounterID = 12018,
		portrait = 1378998,
		loot = { 18703, 18646, 19140, 18806, 18805, 18803, 19139, 18811, 18808, 18809, 18810, 18812 },
		sharedLoot = { },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"At the top of the elemental hierarchy, just beneath Ragnaros himself, resides Majordomo Executus. This flamewaker gained his exalted status by proving to be nearly invincible in the battles that raged within the elemental plane. Rumor has it that Executus supplanted Baron Geddon, and the two have been rivals ever since. Although this rumor has yet to be confirmed, there is certainly no doubt that Ragnaros does not tolerate failure.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
	{
		name = "Ragnaros",
		encounterID = 11502,
		portrait = 522261,
		loot = { 16915, 16901, 16946, 16954, 16930, 16962, 16938, 16922, 16909, 18816, 19138, 18817, 17063, 17107, 18815, 18814, 17102, 17106, 19137, 17082, 17104, 17076, 17204 },
		sharedLoot = { },
		rareLoot = { },
		veryRareLoot = { },
		extremelyRareLoot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Ragnaros the Firelord, one of the Elemental Lords, revels in destruction, often clashing with Therazane the Stonemother. He has a tenuous alliance with Al’Akir the Windlord and is the mortal enemy of Neptulon the Tidehunter. Summoned during the War of the Three Hammers by Dark Iron king Thaurisan, Ragnaros shattered the Redridge Mountains and created the Blackrock volcano. Now residing within the volcano, he enslaves the Dark Iron dwarves and seeks to ravage the world.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
		}
	},
})
