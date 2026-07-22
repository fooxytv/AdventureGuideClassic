--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

LootFilterService = {}

-- Item class/subclass ids. Spelled out rather than read from Enum.ItemClass,
-- which is not present on every client the addon supports.
local ITEM_CLASS_WEAPON = 2
local ITEM_CLASS_ARMOR = 4

local ARMOR_MISC, ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE = 0, 1, 2, 3, 4
local ARMOR_SHIELD, ARMOR_LIBRAM, ARMOR_IDOL, ARMOR_TOTEM = 6, 7, 8, 9

local AXE1H, AXE2H, BOW, GUN, MACE1H, MACE2H = 0, 1, 2, 3, 4, 5
local POLEARM, SWORD1H, SWORD2H, STAFF = 6, 7, 8, 10
local FIST, DAGGER, THROWN, CROSSBOW, WAND = 13, 15, 16, 18, 19

local function Set(...)
	local t = {}
	for _, v in ipairs({ ... }) do t[v] = true end
	return t
end

--[[
	The armour tier a class actually wants, matching the retail journal: a Paladin
	sees plate, not the leather and cloth it could also technically equip. Filtering
	on "can equip" instead would show a Warrior every cloth drop in the instance,
	which makes the filter close to useless.
]]
local CLASS_ARMOR = {
	WARRIOR = ARMOR_PLATE, PALADIN = ARMOR_PLATE, DEATHKNIGHT = ARMOR_PLATE,
	HUNTER = ARMOR_MAIL, SHAMAN = ARMOR_MAIL,
	ROGUE = ARMOR_LEATHER, DRUID = ARMOR_LEATHER,
	PRIEST = ARMOR_CLOTH, MAGE = ARMOR_CLOTH, WARLOCK = ARMOR_CLOTH,
}

local CLASS_RELIC = { PALADIN = ARMOR_LIBRAM, DRUID = ARMOR_IDOL, SHAMAN = ARMOR_TOTEM }
local RELIC_SUBCLASSES = Set(ARMOR_LIBRAM, ARMOR_IDOL, ARMOR_TOTEM)
local SHIELD_CLASSES = Set("WARRIOR", "PALADIN", "SHAMAN")

local CLASS_WEAPONS = {
	WARRIOR = Set(AXE1H, AXE2H, MACE1H, MACE2H, SWORD1H, SWORD2H, POLEARM, STAFF,
		DAGGER, FIST, BOW, GUN, CROSSBOW, THROWN),
	PALADIN = Set(AXE1H, AXE2H, MACE1H, MACE2H, SWORD1H, SWORD2H, POLEARM),
	HUNTER = Set(AXE1H, AXE2H, SWORD1H, SWORD2H, POLEARM, STAFF, DAGGER, FIST,
		BOW, GUN, CROSSBOW, THROWN),
	ROGUE = Set(DAGGER, SWORD1H, MACE1H, FIST, BOW, GUN, CROSSBOW, THROWN),
	PRIEST = Set(MACE1H, DAGGER, STAFF, WAND),
	SHAMAN = Set(AXE1H, AXE2H, MACE1H, MACE2H, STAFF, DAGGER, FIST),
	MAGE = Set(SWORD1H, DAGGER, STAFF, WAND),
	WARLOCK = Set(SWORD1H, DAGGER, STAFF, WAND),
	DRUID = Set(MACE1H, MACE2H, STAFF, DAGGER, FIST, POLEARM),
	DEATHKNIGHT = Set(AXE1H, AXE2H, MACE1H, MACE2H, SWORD1H, SWORD2H, POLEARM),
}

--[[
	Slots every class can use whatever its armour proficiency. Cloaks are the
	reason this exists: they carry the Cloth subclass, so without an explicit pass
	a plate wearer would never be shown one.
]]
local ALL_CLASS_SLOTS = Set(
	"INVTYPE_CLOAK", "INVTYPE_FINGER", "INVTYPE_NECK", "INVTYPE_TRINKET",
	"INVTYPE_BODY", "INVTYPE_TABARD", "INVTYPE_HOLDABLE"
)

local CLASS_ORDER = {
	"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
	"SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

local ARMOR_ORDER = { ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE }
local ARMOR_FALLBACK_NAMES = {
	[ARMOR_CLOTH] = "Cloth", [ARMOR_LEATHER] = "Leather",
	[ARMOR_MAIL] = "Mail", [ARMOR_PLATE] = "Plate",
}

-- Mirrors state into SavedVariables when it exists. Services load before
-- ADDON_LOADED sets it up, so the in-memory copy is the source of truth.
local state = { class = nil, armor = nil }

local function Store()
	if not SavedVariables then return nil end
	SavedVariables.Settings = SavedVariables.Settings or {}
	SavedVariables.Settings.LootFilter = SavedVariables.Settings.LootFilter or {}
	return SavedVariables.Settings.LootFilter
end

local function Load()
	local store = Store()
	if store and not state.loaded then
		state.class = store.class
		state.armor = store.armor
		state.loaded = true
	end
end

function LootFilterService.GetClassFilter()
	Load()
	return state.class
end

function LootFilterService.SetClassFilter(class)
	Load()
	state.class = class
	local store = Store()
	if store then store.class = class end
end

function LootFilterService.GetArmorFilter()
	Load()
	return state.armor
end

function LootFilterService.SetArmorFilter(armorSubclass)
	Load()
	state.armor = armorSubclass
	local store = Store()
	if store then store.armor = armorSubclass end
end

function LootFilterService.IsFiltered()
	Load()
	return state.class ~= nil or state.armor ~= nil
end

function LootFilterService.ClearFilters()
	LootFilterService.SetClassFilter(nil)
	LootFilterService.SetArmorFilter(nil)
end

function LootFilterService.GetClasses()
	local result = {}
	for _, token in ipairs(CLASS_ORDER) do
		local names = _G.LOCALIZED_CLASS_NAMES_MALE
		local color = _G.RAID_CLASS_COLORS and _G.RAID_CLASS_COLORS[token]
		table.insert(result, {
			token = token,
			label = (names and names[token]) or token,
			colorCode = color and color.colorStr and ("|c" .. color.colorStr) or nil,
		})
	end
	return result
end

function LootFilterService.GetArmorTypes()
	local result = {}
	for _, subclass in ipairs(ARMOR_ORDER) do
		local label
		if _G.GetItemSubClassInfo then
			label = _G.GetItemSubClassInfo(ITEM_CLASS_ARMOR, subclass)
		end
		table.insert(result, {
			subclass = subclass,
			label = label or ARMOR_FALLBACK_NAMES[subclass],
		})
	end
	return result
end

local function PassesClass(item, class)
	if not class then return true end

	-- A token has no armour type or weapon subclass of its own; its eligibility is
	-- whichever classes trade it for a set piece.
	if item.itemId and TierTokenService and TierTokenService.IsToken(item.itemId) then
		return TierTokenService.HasClass(item.itemId, class)
	end

	if item.classID == ITEM_CLASS_ARMOR then
		local subclass = item.subclassID
		if subclass == ARMOR_MISC then return true end          -- rings, necks, trinkets
		if ALL_CLASS_SLOTS[item.equipLoc] then return true end
		if subclass == ARMOR_SHIELD then return SHIELD_CLASSES[class] == true end
		if RELIC_SUBCLASSES[subclass] then return CLASS_RELIC[class] == subclass end
		return CLASS_ARMOR[class] == subclass
	end

	if item.classID == ITEM_CLASS_WEAPON then
		local allowed = CLASS_WEAPONS[class]
		return (allowed ~= nil and allowed[item.subclassID]) == true
	end

	return true     -- mounts and anything else are not class-restricted
end

local function PassesArmor(item, armorSubclass)
	if not armorSubclass then return true end

	if item.itemId and TierTokenService and TierTokenService.IsToken(item.itemId) then
		return TierTokenService.HasArmorType(item.itemId, armorSubclass,
			LootFilterService.GetClassFilter())
	end

	return item.classID == ITEM_CLASS_ARMOR and item.subclassID == armorSubclass
end

function LootFilterService.PassesFilter(lootItem)
	if not lootItem or lootItem.isHeader then return true end
	return PassesClass(lootItem, LootFilterService.GetClassFilter())
		and PassesArmor(lootItem, LootFilterService.GetArmorFilter())
end
