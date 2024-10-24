--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]

local playerLevel = UnitLevel("player")

function GetEquipRestrictions(playerLevel)
    return {
        ["Warrior"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = true,
            ["Bows"] = true,
            ["Daggers"] = false,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = true,
            ["One-Handed Maces"] = true,
            ["Polearms"] = true,
            ["Staves"] = false,
            ["Two-Handed Axes"] = true,
            ["Two-Handed Maces"] = true,
            ["Crossbows"] = true,
            ["Guns"] = true,
            ["Thrown"] = true,
            ["Wands"] = false,
            ["Plate"] = true,
            ["Mail"] = true,
            ["Leather"] = true,
            ["Cloth"] = true,
        },
        ["Mage"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = false,
            ["Bows"] = false,
            ["Daggers"] = true,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = false,
            ["One-Handed Maces"] = false,
            ["Polearms"] = false,
            ["Staves"] = true,
            ["Two-Handed Axes"] = false,
            ["Two-Handed Maces"] = false,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = false,
            ["Wands"] = true,
            ["Plate"] = false,
            ["Mail"] = false,
            ["Leather"] = false,
            ["Cloth"] = true,
        },
        ["Shaman"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = false,
            ["Bows"] = false,
            ["Daggers"] = true,
            ["Fist Weapons"] = true,
            ["One-Handed Axes"] = true,
            ["One-Handed Maces"] = true,
            ["Polearms"] = false,
            ["Staves"] = true,
            ["Two-Handed Axes"] = true,
            ["Two-Handed Maces"] = true,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = false,
            ["Wands"] = false,
            ["Plate"] = false,
            ["Mail"] = true,
            ["Leather"] = true,
            ["Cloth"] = true,
        },
        ["Rogue"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = false,
            ["Bows"] = false,
            ["Daggers"] = true,
            ["Fist Weapons"] = true,
            ["One-Handed Axes"] = true,
            ["One-Handed Maces"] = true,
            ["Polearms"] = false,
            ["Staves"] = false,
            ["Two-Handed Axes"] = false,
            ["Two-Handed Maces"] = false,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = true,
            ["Wands"] = false,
            ["Plate"] = false,
            ["Mail"] = false,
            ["Leather"] = true,
            ["Cloth"] = true,
        },
        ["Hunter"] = {
            ["One-Handed Swords"] = false,
            ["Two-Handed Swords"] = false,
            ["Bows"] = true,
            ["Daggers"] = false,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = false,
            ["One-Handed Maces"] = false,
            ["Polearms"] = false,
            ["Staves"] = false,
            ["Two-Handed Axes"] = false,
            ["Two-Handed Maces"] = false,
            ["Crossbows"] = true,
            ["Guns"] = true,
            ["Thrown"] = true,
            ["Wands"] = false,
            ["Plate"] = false,
            ["Mail"] = playerLevel >= 40,
            ["Leather"] = true,
            ["Cloth"] = true,

        },
        ["Priest"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = false,
            ["Bows"] = false,
            ["Daggers"] = true,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = false,
            ["One-Handed Maces"] = false,
            ["Polearms"] = false,
            ["Staves"] = true,
            ["Two-Handed Axes"] = false,
            ["Two-Handed Maces"] = false,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = false,
            ["Wands"] = true,
            ["Plate"] = false,
            ["Mail"] = false,
            ["Leather"] = false,
            ["Cloth"] = true,
        },
        ["Warlock"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = false,
            ["Bows"] = false,
            ["Daggers"] = true,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = false,
            ["One-Handed Maces"] = false,
            ["Polearms"] = false,
            ["Staves"] = true,
            ["Two-Handed Axes"] = false,
            ["Two-Handed Maces"] = false,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = false,
            ["Wands"] = true,
            ["Plate"] = false,
            ["Mail"] = false,
            ["Leather"] = false,
            ["Cloth"] = true,
        },
        ["Druid"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = false,
            ["Bows"] = false,
            ["Daggers"] = true,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = true,
            ["One-Handed Maces"] = true,
            ["Polearms"] = true,
            ["Staves"] = true,
            ["Two-Handed Axes"] = true,
            ["Two-Handed Maces"] = true,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = true,
            ["Wands"] = false,
            ["Plate"] = false,
            ["Mail"] = false,
            ["Leather"] = true,
            ["Cloth"] = true,
        },
        ["Paladin"] = {
            ["One-Handed Swords"] = true,
            ["Two-Handed Swords"] = true,
            ["Bows"] = false,
            ["Daggers"] = false,
            ["Fist Weapons"] = false,
            ["One-Handed Axes"] = true,
            ["One-Handed Maces"] = true,
            ["Polearms"] = true,
            ["Staves"] = false,
            ["Two-Handed Axes"] = true,
            ["Two-Handed Maces"] = true,
            ["Crossbows"] = false,
            ["Guns"] = false,
            ["Thrown"] = false,
            ["Wands"] = false,
            ["Plate"] = true,
            ["Mail"] = true,
            ["Leather"] = true,
            ["Cloth"] = true,
        },
    }
end