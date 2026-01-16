--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

SearchService = {}

-- Cache for item names (populated as items are queried)
local itemNameCache = {}
local pendingItemLoads = {}
local searchCallback = nil
local lastSearchText = ""

-- Register for item data load events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
eventFrame:SetScript("OnEvent", function(self, event, itemId, success)
	if success and pendingItemLoads[itemId] then
		local itemName = C_Item.GetItemInfo(itemId)
		if itemName then
			itemNameCache[itemId] = itemName
		end
		pendingItemLoads[itemId] = nil

		-- If we have a pending search callback and no more pending loads, re-run search
		if searchCallback and next(pendingItemLoads) == nil then
			searchCallback(lastSearchText)
		end
	end
end)

-- Search instances by name (synchronous)
function SearchService.SearchInstances(searchText)
	local results = {}
	local searchLower = searchText:lower()

	-- Search dungeons
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

	-- Search raids
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

-- Search loot items by name (async-aware)
function SearchService.SearchLoot(searchText, callback)
	local results = {}
	local searchLower = searchText:lower()
	lastSearchText = searchText
	searchCallback = callback

	local function SearchInstanceLoot(instanceList, isRaid)
		for _, inst in ipairs(instanceList) do
			-- Iterate encounters (instance is array-like with encounters)
			for i, encounter in ipairs(inst) do
				if type(encounter) == "table" and encounter.name then
					-- Search all loot tables
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
									local itemName = itemNameCache[item.id] or C_Item.GetItemInfo(item.id)

									if itemName then
										itemNameCache[item.id] = itemName
										if itemName:lower():find(searchLower, 1, true) then
											-- Check if we already have this item in results
											local found = false
											for _, r in ipairs(results) do
												if r.itemId == item.id then
													found = true
													break
												end
											end

											if not found then
												local _, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(item.id)
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
										-- Item not cached, request load
										if not pendingItemLoads[item.id] then
											pendingItemLoads[item.id] = true
											C_Item.RequestLoadItemDataByID(item.id)
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

	-- Search dungeons and raids
	SearchInstanceLoot(InstanceService.GetDungeons(), false)
	SearchInstanceLoot(InstanceService.GetRaids(), true)

	return results
end

-- Combined search function
function SearchService.Search(searchText, callback)
	if not searchText or searchText == "" or #searchText < 2 then
		return {}, {}
	end

	local instanceResults = SearchService.SearchInstances(searchText)
	local lootResults = SearchService.SearchLoot(searchText, callback)

	return instanceResults, lootResults
end

-- Clear search state
function SearchService.ClearSearch()
	searchCallback = nil
	lastSearchText = ""
	wipe(pendingItemLoads)
end

-- Get cached item name (or nil if not cached)
function SearchService.GetCachedItemName(itemId)
	return itemNameCache[itemId]
end
