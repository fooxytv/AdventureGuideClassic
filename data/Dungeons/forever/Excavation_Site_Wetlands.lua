--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

Boss names only. Abilities, loot and tactics are deliberately absent rather than
guessed at, as they were before -- there is still nothing to draw them from.

The names are as the 1.60.1 beta records them, by way of the Aegis Forever Instance
Journal, and cross-checked against the community guides. They are facts about the
client rather than anyone's writing, which is the only part taken.

Treat the count as provisional. Forever's beta caps at level 30, so an instance
reaching past it is only partly walkable: sources agree on Hall of Thanes and
Excavation Site, and disagree on Ruins of Lordaeron (six or seven) and City of
Dalaran (seven or nine), both of which run to 33. No encounterID either -- the
client's own journal is the place to get those, and it reads cold so far. Defeat
tracking does not need them: BuildNpcLookup keys every encounter by name as well.
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Excavation Site: Wetlands",
	thumbnail = I.UIEJDungeonButtonExcavationSiteWetlands,
	icon = 527422,
	splash = 527422,
	seasonFilter = "forever",
	overview = "The bosses known from Forever's beta are listed here. Their abilities, loot and tactics are not yet recorded, and will be added as the content is documented.",
	{
		name = "Saltspine",
		defeated = 0,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		abilities = {},
	},
	{
		name = "Shadetooth",
		defeated = 0,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		abilities = {},
	},
	{
		name = "Relic Guardian",
		defeated = 0,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		abilities = {},
	},
})
