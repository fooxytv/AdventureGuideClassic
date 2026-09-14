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

Only the fields needed to describe a chain are taken: identity, level gating, the
prerequisite graph, and the one-line objectives text. Spawn coordinates and drop tables
are deliberately left behind -- they are the bulk of Questie's 1MB, and the player
already has Questie or the quest log for those.

The objectives text is the exception to "graph data only", and it earns its place: a
quest name is a label, but "Bring 12 Red Burlap Bandanas to Deputy Willem outside the
Northshire Abbey" tells a player what the quest is and where to go. It costs about
3.4KB a zone, roughly 375KB for all of Era.
]]

local QUESTIE = "../Questie"
local OUT = "data/Quests"
local NPC_MODELS = "tools/npc_models.tsv"

-- Questie's field order, from the questKeys table at the top of its database file.
local KEY = {
	name = 1, startedBy = 2, finishedBy = 3,
	requiredLevel = 4, questLevel = 5,
	requiredRaces = 6, requiredClasses = 7, objectivesText = 8, objectives = 10,
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

--[[
The npc id -> creature display id map, from tools/extract_npc_models.py.

Questie says which npc gives a quest and which creature you have to kill for it, but
carries no display ids, and the Classic client ships Creature.db2 empty -- so this file
is the only thing that can turn "Marshal McBride" into a model the guide can show.
Missing is fine: quests then simply have no previewable npcs.
]]
local function LoadNpcModels(path)
	local models = {}
	local handle = io.open(path, "rb")
	if not handle then
		print(("  [note] %s not found -- npc models will be omitted"):format(path))
		return models
	end
	local contents = handle:read("*a")
	handle:close()
	for line in contents:gmatch("[^\r\n]+") do
		if line:sub(1, 1) ~= "#" then
			local id, display, name = line:match("^(%d+)\t(%d+)\t(.+)$")
			if id then models[tonumber(id)] = { name = name, display = tonumber(display) } end
		end
	end
	return models
end

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

--[[
Questie stores objectives text as a list; all but a handful of quests have exactly one
entry. Join them so a quest is always one sentence, and flatten any stray newline --
the addon draws this on a single wrapped font string.
]]
local function JoinObjectives(list)
	if type(list) ~= "table" then return nil end
	local parts = {}
	for _, line in ipairs(list) do
		if type(line) == "string" and line ~= "" then parts[#parts + 1] = line end
	end
	if #parts == 0 then return nil end
	return (table.concat(parts, " "):gsub("%s+", " "))
end

--[[
The npcs a quest's text will mention: who gives it, who you hand it to, and anything it
asks you to kill. Ordered longest name first, because the guide substitutes them into
the sentence one at a time and "Kobold Vermin" must not be matched inside "Kobold
Vermin Leader" once the shorter name has already been replaced.
]]
local function QuestNpcs(row, models)
	local seen, ids = {}, {}
	local function Add(id)
		if type(id) == "number" and models[id] and not seen[id] then
			seen[id] = true
			ids[#ids + 1] = id
		end
	end
	for _, key in ipairs({ KEY.startedBy, KEY.finishedBy }) do
		local group = row[key]
		if type(group) == "table" and type(group[1]) == "table" then
			for _, id in ipairs(group[1]) do Add(id) end
		end
	end
	local objectives = row[KEY.objectives]
	if type(objectives) == "table" and type(objectives[1]) == "table" then
		for _, entry in ipairs(objectives[1]) do
			if type(entry) == "table" then Add(entry[1]) else Add(entry) end
		end
	end
	table.sort(ids, function(a, b)
		local nameA, nameB = models[a].name, models[b].name
		if #nameA ~= #nameB then return #nameA > #nameB end
		return nameA < nameB
	end)
	return ids
end

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
	if quest.text then parts[#parts + 1] = ("text = %s"):format(QuoteString(quest.text)) end
	if quest.npcs and #quest.npcs > 0 then
		parts[#parts + 1] = ("npcs = %s"):format(FormatList(quest.npcs))
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
licensed GPL-3.0, as is this addon. Only what the guide needs is carried across:
identity, level gating, the prerequisite graph, and the one-line objectives text.

Creature display ids come from the CMaNGOS Classic 1.12.1 world database (GPL-2.0),
via tools/extract_npc_models.py.

Zone: %s (area %d, uiMapID %s)
Quests: %d
]==]
select(2, ...).SetupGlobalFacade()

QuestChainService.AddNpcs(%s, %s, {
%s})

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

local npcModels = LoadNpcModels(NPC_MODELS)

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
				text = JoinObjectives(row[KEY.objectivesText]),
				npcs = QuestNpcs(row, npcModels),
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
				-- One npc table per zone, referenced by id from the quests below, so a
				-- creature that turns up in six quests is named and numbered once.
				local used, npcLines = {}, {}
				for _, quest in ipairs(list) do
					for _, id in ipairs(quest.npcs or {}) do used[id] = true end
				end
				local usedIds = {}
				for id in pairs(used) do usedIds[#usedIds + 1] = id end
				table.sort(usedIds)
				for _, id in ipairs(usedIds) do
					npcLines[#npcLines + 1] = ("\t[%d] = { %s, %d },\n")
						:format(id, QuoteString(npcModels[id].name), npcModels[id].display)
				end

				local out = assert(io.open(fileName, "wb"))
				out:write(HEADER:format(area, name, area, tostring(uiMapId), #list,
					QuoteString(expansion), tostring(uiMapId), table.concat(npcLines),
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
