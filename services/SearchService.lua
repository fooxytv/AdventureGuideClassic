--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

SearchService = {}

local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo
local function RequestLoadItemDataCompat(itemId)
    if C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(itemId)
    else
        GetItemInfo(itemId)
    end
end

local itemNameCache = {}
local pendingItemLoads = {}
local searchCallback = nil
local lastSearchText = ""

local eventFrame = CreateFrame("Frame")
if C_Item and C_Item.RequestLoadItemDataByID then
    eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
else
    eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
eventFrame:SetScript("OnEvent", function(self, event, itemId, success)
    if event == "GET_ITEM_INFO_RECEIVED" then
        success = true
    end
    if success and pendingItemLoads[itemId] then
        local itemName = GetItemInfoCompat(itemId)
        if itemName then
            itemNameCache[itemId] = itemName
        end
        pendingItemLoads[itemId] = nil
        if searchCallback and next(pendingItemLoads) == nil then
            searchCallback(lastSearchText)
        end
    end
end)

function SearchService.SearchInstances(searchText)
	local results = {}
	local searchLower = searchText:lower()
	local dungeons = InstanceService.GetDungeons()
	for _, dungeon in ipairs(dungeons) do
		if dungeon.name and dungeon.name:lower():find(searchLower, 1, true) then
			table.insert(results, {
				type = "instance",
				name = dungeon.name,
				instance = dungeon,
				icon = dungeon.icon or dungeon.thumbnail,
				isRaid = false
			})
		end
	end

	local raids = InstanceService.GetRaids()
	for _, raid in ipairs(raids) do
		if raid.name and raid.name:lower():find(searchLower, 1, true) then
			table.insert(results, {
				type = "instance",
				name = raid.name,
				instance = raid,
				icon = raid.icon or raid.thumbnail,
				isRaid = true
			})
		end
	end

	return results
end

function SearchService.SearchLoot(searchText, callback)
	local results = {}
	local searchLower = searchText:lower()
	lastSearchText = searchText
	searchCallback = callback

	local function SearchInstanceLoot(instanceList, isRaid)
		for _, inst in ipairs(instanceList) do
			for i, encounter in ipairs(inst) do
				if type(encounter) == "table" and encounter.name then
					local lootTables = {
						encounter.loot,
						encounter.sharedLoot,
						encounter.rareLoot,
						encounter.veryRareLoot,
						encounter.extremelyRareLoot
					}

					for _, lootTable in ipairs(lootTables) do
						if lootTable then
							for _, item in ipairs(lootTable) do
								if item.id then
									local itemName = itemNameCache[item.id] or GetItemInfoCompat(item.id)

									if itemName then
										itemNameCache[item.id] = itemName
										if itemName:lower():find(searchLower, 1, true) then
											local found = false
											for _, r in ipairs(results) do
												if r.itemId == item.id then
													found = true
													break
												end
											end

											if not found then
												local _, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfoCompat(item.id)
												table.insert(results, {
													type = "loot",
													name = itemName,
													itemId = item.id,
													itemLink = itemLink,
													itemQuality = itemQuality or 1,
													itemIcon = itemIcon,
													encounter = encounter,
													instance = inst,
													sourceName = encounter.name .. " - " .. inst.name
												})
											end
										end
									else
										if not pendingItemLoads[item.id] then
											pendingItemLoads[item.id] = true
											RequestLoadItemDataCompat(item.id)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	SearchInstanceLoot(InstanceService.GetDungeons(), false)
	SearchInstanceLoot(InstanceService.GetRaids(), true)

	return results
end

function SearchService.Search(searchText, callback)
	if not searchText or searchText == "" or #searchText < 2 then
		return {}, {}
	end

	local instanceResults = SearchService.SearchInstances(searchText)
	local lootResults = SearchService.SearchLoot(searchText, callback)

	return instanceResults, lootResults
end

function SearchService.ClearSearch()
	searchCallback = nil
	lastSearchText = ""
	wipe(pendingItemLoads)
end

function SearchService.GetCachedItemName(itemId)
	return itemNameCache[itemId]
end
