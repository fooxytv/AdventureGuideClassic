--[[
Generates AdventureGuideClassic's quest-chain data from Questie's database.

    lua tools/questie_import.lua              -- the default zone set
    lua tools/questie_import.lua 12 40        -- specific area ids
    lua tools/questie_import.lua --list       -- what a zone would produce, no files

Build-time only. The addon gains no runtime dependency on Questie: this reads its
database once and emits our own compact tables into data/Quests/.

Written in Lua rather than Python, unlike the other tools here, because Questie's
database IS a Lua table -- held in a long string and returned by a chunk. Loading it
is exact; regex-parsing nested Lua tables from Python would be guesswork that breaks
the first time the formatting shifts.

Questie is GPL-3.0, as is this addon, so the derived data is compatible. The generated
files carry attribution.

Only the fields needed to describe a chain are taken: identity, level gating, and the
prerequisite graph. Objectives text, spawn coordinates and drop tables are deliberately
left behind -- they are the bulk of Questie's 1MB, and the player already has Questie
or the quest log for those.
]]

local QUESTIE = "../Questie"
local OUT = "data/Quests"

-- Questie's field order, from the questKeys table at the top of its database file.
local KEY = {
	name = 1, requiredLevel = 4, questLevel = 5,
	requiredRaces = 6, requiredClasses = 7,
	preQuestGroup = 12, preQuestSingle = 13, childQuests = 14,
	exclusiveTo = 16, zoneOrSort = 17,
	nextQuestInChain = 22, parentQuest = 25,
	breadcrumbForQuestId = 27,
}

local SOURCES = {
	era = QUESTIE .. "/Database/Classic/classicQuestDB.lua",
	tbc = QUESTIE .. "/Database/TBC/tbcQuestDB.lua",
}

-- Zones to generate for, as AreaTable ids. Start small and deliberate: proving the
-- shape against one real chain matters more than bulk.
local DEFAULT_AREAS = { 12 }   -- Elwynn Forest (Northshire rolls into it)

-- Helpers ---------------------------------------------------------------------

local function ReadFile(path)
	local handle = io.open(path, "rb")
	if not handle then
		error(("cannot open %s -- is Questie checked out alongside this repo?"):format(path))
	end
	local contents = handle:read("*a")
	handle:close()
	return contents
end

--[==[
Pulls the quest table out of the database file.

Questie holds it as a long string assigned to questData, whose contents are a chunk
returning the table. Extract the string, load it, call it.

Note the [==[ delimiters on this comment: the text below describes long-bracket syntax,
and a plain --[[ comment would be closed early by it.
]==]
local function LoadQuests(path)
	local source = ReadFile(path)
	local payload = source:match("questData%s*=%s*%[%[(.-)%]%]")
	if not payload then
		error(("no questData block found in %s"):format(path))
	end
	local chunk, err = load(payload, "questData", "t", {})
	if not chunk then error("failed to load questData: " .. tostring(err)) end
	return chunk()
end

-- These two files are plain int -> int maps; a line match is enough and avoids having
-- to stand up Questie's module loader.
local function LoadIntMap(path)
	local map = {}
	for line in ReadFile(path):gmatch("[^\r\n]+") do
		local key, value = line:match("^%s*%[(%d+)%]%s*=%s*(%d+)")
		if key then map[tonumber(key)] = tonumber(value) end
	end
	return map
end

local function LoadZoneNames(path)
	local names = {}
	for line in ReadFile(path):gmatch("[^\r\n]+") do
		local key, name = line:match("^%s*%[(%d+)%]%s*=%s*%d+,%s*%-%-%s*(.-)%s*$")
		if key then names[tonumber(key)] = name end
	end
	return names
end

-- Emitting --------------------------------------------------------------------

local function QuoteString(text)
	return ('"%s"'):format(tostring(text):gsub('\\', '\\\\'):gsub('"', '\\"'))
end

local function FormatList(list)
	local parts = {}
	for _, value in ipairs(list) do parts[#parts + 1] = tostring(value) end
	return "{ " .. table.concat(parts, ", ") .. " }"
end

--[[
One quest as a single line. Fields are omitted when absent rather than written as nil:
across a full zone that is most of the file, and a sparse table reads better besides.
]]
local function FormatQuest(quest)
	local parts = {
		("id = %d"):format(quest.id),
		("name = %s"):format(QuoteString(quest.name)),
	}
	if quest.level then parts[#parts + 1] = ("level = %d"):format(quest.level) end
	if quest.req and quest.req > 0 then parts[#parts + 1] = ("req = %d"):format(quest.req) end
	if quest.races then parts[#parts + 1] = ("races = %d"):format(quest.races) end
	if quest.classes then parts[#parts + 1] = ("classes = %d"):format(quest.classes) end
	if quest.pre then parts[#parts + 1] = ("pre = %s"):format(FormatList(quest.pre)) end
	if quest.preAll then parts[#parts + 1] = ("preAll = %s"):format(FormatList(quest.preAll)) end
	if quest.nextInChain then parts[#parts + 1] = ("nextInChain = %d"):format(quest.nextInChain) end
	if quest.parent then parts[#parts + 1] = ("parent = %d"):format(quest.parent) end
	if quest.children then parts[#parts + 1] = ("children = %s"):format(FormatList(quest.children)) end
	if quest.exclusive then parts[#parts + 1] = ("exclusive = %s"):format(FormatList(quest.exclusive)) end
	if quest.breadcrumbFor then
		parts[#parts + 1] = ("breadcrumbFor = %d"):format(quest.breadcrumbFor)
	end
	return "\t{ " .. table.concat(parts, ", ") .. " },"
end

local HEADER = [[
--[==[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

AUTO-GENERATED -- DO NOT EDIT.
    lua tools/questie_import.lua %d

Derived from the Questie quest database (https://github.com/Questie/Questie),
licensed GPL-3.0, as is this addon. Only chain-shaping fields are carried across:
identity, level gating and the prerequisite graph.

Zone: %s (area %d, uiMapID %s)
Quests: %d
]==]
select(2, ...).SetupGlobalFacade()

QuestChainService.AddQuests(%s, %s, {
]]

-- Main ------------------------------------------------------------------------

local args = {}
for _, value in ipairs(arg or {}) do args[#args + 1] = value end
local listOnly = false
local areas = {}
for _, value in ipairs(args) do
	if value == "--list" then
		listOnly = true
	elseif tonumber(value) then
		areas[#areas + 1] = tonumber(value)
	end
end
if #areas == 0 then areas = DEFAULT_AREAS end

local subToParent = LoadIntMap(QUESTIE .. "/Database/Zones/data/subZoneToParentZone.lua")
local areaToUiMap = LoadIntMap(QUESTIE .. "/Database/Zones/data/areaIdToUiMapId.lua")
local areaNames = LoadZoneNames(QUESTIE .. "/Database/Zones/data/areaIdToUiMapId.lua")

local function ParentArea(areaId)
	return subToParent[areaId] or areaId
end

for expansion, path in pairs(SOURCES) do
	local quests = LoadQuests(path)

	-- Group by the zone a quest belongs to, rolling subzones into their parent so
	-- Northshire's quests sit with Elwynn's rather than in a zone of their own.
	local byArea = {}
	for id, row in pairs(quests) do
		local zone = row[KEY.zoneOrSort]
		if type(zone) == "number" and zone > 0 then
			local area = ParentArea(zone)
			byArea[area] = byArea[area] or {}
			table.insert(byArea[area], {
				id = id,
				name = row[KEY.name],
				level = row[KEY.questLevel],
				req = row[KEY.requiredLevel],
				races = row[KEY.requiredRaces],
				classes = row[KEY.requiredClasses],
				pre = row[KEY.preQuestSingle],
				preAll = row[KEY.preQuestGroup],
				nextInChain = row[KEY.nextQuestInChain],
				parent = row[KEY.parentQuest],
				children = row[KEY.childQuests],
				exclusive = row[KEY.exclusiveTo],
				breadcrumbFor = row[KEY.breadcrumbForQuestId],
			})
		end
	end

	for _, area in ipairs(areas) do
		local list = byArea[area]
		if list then
			table.sort(list, function(a, b)
				local aLevel, bLevel = a.level or 0, b.level or 0
				if aLevel ~= bLevel then return aLevel < bLevel end
				return (a.name or "") < (b.name or "")
			end)

			local name = areaNames[area] or ("area " .. area)
			local uiMapId = areaToUiMap[area]
			print(("%s  area %d (%s)  uiMapID %s  ->  %d quests")
				:format(expansion, area, name, tostring(uiMapId), #list))

			if listOnly then
				for _, quest in ipairs(list) do
					local gate = quest.pre and (" <- " .. FormatList(quest.pre)) or ""
					print(("    [%d] %-42s lvl %-3s%s")
						:format(quest.id, quest.name, tostring(quest.level or "?"), gate))
				end
			else
				local dir = ("%s/%s"):format(OUT, expansion)
				os.execute(('mkdir "%s" 2>nul'):format(dir:gsub("/", "\\")))
				local fileName = ("%s/%s.lua"):format(dir,
					name:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", ""))
				local out = assert(io.open(fileName, "wb"))
				out:write(HEADER:format(area, name, area, tostring(uiMapId), #list,
					QuoteString(expansion), tostring(uiMapId)))
				for _, quest in ipairs(list) do
					out:write(FormatQuest(quest), "\n")
				end
				out:write("})\n")
				out:close()
				print(("    wrote %s"):format(fileName))
			end
		else
			print(("%s  area %d -- no quests"):format(expansion, area))
		end
	end
end
