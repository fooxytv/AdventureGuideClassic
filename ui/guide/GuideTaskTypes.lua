--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
How each kind of guide step is drawn: its icon and the one-line instruction.

One registry rather than a file per type (as ui/widgets/ does) because these are pure
data with a formatter; there is no per-type behaviour to isolate yet. Split them out
if and when a type grows its own logic.

Only quest steps carry an icon -- the ! and ? that everyone already reads as "take
this" and "hand this in". Everything else has none.

An icon per task type was tried and dropped: a raid-target skull for kill, a banker
for collect, a class crest for level. Each borrowed a different visual language from
somewhere unrelated, and together a card of five steps looked like a toolbar. The verb
is the first word of every line anyway, so the icons were decorating text that did not
need it.

The two that remain come from Interface/GossipFrame, which ships with every client; a
guessed Interface/Icons path renders as a blank square with no error.
]]

GuideTaskTypes = { }

local types = { }

local GOSSIP = "Interface/GossipFrame/%sGossipIcon"
local FALLBACK_ICON = "Interface/Icons/INV_Misc_QuestionMark"

-- Names are picked out in gold against white body text. The reverse -- gold
-- throughout -- is what the step card used to do, and a paragraph of it is tiring to
-- read at this size.
local function Quote(text)
	return ("|cffffd100%s|r"):format(tostring(text or "?"))
end

-- You accept a quest FROM someone but hand it IN TO them, so the preposition is the
-- caller's to choose.
local function WithSource(text, task, preposition)
	local who = task.npc or task.object
	if who then
		return ("%s %s %s"):format(text, preposition or "from", Quote(who))
	end
	return text
end

local function Register(name, definition)
	definition.name = name
	types[name] = definition
end

Register("accept", {
	icon = "Interface/GossipFrame/AvailableQuestIcon",
	Format = function(task)
		return WithSource(("Accept %s"):format(Quote(task.quest)), task, "from")
	end,
})

Register("turnin", {
	icon = "Interface/GossipFrame/ActiveQuestIcon",
	Format = function(task)
		return WithSource(("Turn in %s"):format(Quote(task.quest)), task, "to")
	end,
})

Register("kill", {
	Format = function(task)
		if task.count then
			return ("Kill %d x %s"):format(task.count, Quote(task.target))
		end
		return ("Kill %s"):format(Quote(task.target))
	end,
})

Register("collect", {
	Format = function(task)
		if task.count then
			return ("Collect %d x %s"):format(task.count, Quote(task.item))
		end
		return ("Collect %s"):format(Quote(task.item))
	end,
})

Register("goto", {
	Format = function(task)
		return ("Travel to %s"):format(Quote(task.place))
	end,
})

Register("sethearth", {
	Format = function(task)
		return ("Set your hearthstone at %s"):format(Quote(task.place))
	end,
})

Register("hearth", {
	Format = function(task)
		return ("Hearth to %s"):format(Quote(task.place))
	end,
})

Register("taxi", {
	Format = function(task)
		return ("Fly to %s"):format(Quote(task.place))
	end,
})

Register("vendor", {
	Format = function(task)
		return task.place and ("Sell and repair at %s"):format(Quote(task.place))
			or "Sell junk and repair"
	end,
})

Register("train", {
	Format = function(task)
		return task.place and ("Train your new spells at %s"):format(Quote(task.place))
			or "Train your new spells"
	end,
})

Register("level", {
	Format = function(task)
		return ("Reach level %s before moving on"):format(Quote(task.level))
	end,
})

Register("note", {
	Format = function(task)
		return tostring(task.text or "")
	end,
})

function GuideTaskTypes.Get(task)
	if not task then return nil end
	return types[task[1]]
end

--[[
The icon for a step, or nil where the type has none. Callers must close the gap when
it is nil rather than substituting a placeholder -- a column of question marks would
be worse than no icon at all.
]]
function GuideTaskTypes.GetIcon(task)
	local definition = GuideTaskTypes.Get(task)
	if definition then return definition.icon end
	-- Unknown type: mark it, so a guide written against a newer addon looks visibly
	-- odd rather than silently blank.
	return FALLBACK_ICON
end

--[[
The instruction line for a step. An unknown task type degrades to its raw name rather
than erroring, so a guide written against a newer addon still renders something.
]]
function GuideTaskTypes.GetText(task)
	local definition = GuideTaskTypes.Get(task)
	local text
	if definition then
		local ok, formatted = pcall(definition.Format, task)
		text = ok and formatted or nil
	end
	if not text or text == "" then
		text = ("Unknown step (%s)"):format(tostring(task and task[1] or "?"))
	end
	if task.note and task.note ~= "" and (not definition or definition.name ~= "note") then
		text = ("%s\n|cff9d9d9d%s|r"):format(text, task.note)
	end
	return text
end

--[[
The instruction with colour codes and the trailing note stripped: one clean line, for
places that list steps rather than present them -- search results, tooltips, debug
output. The coloured multi-line form belongs on the step card alone.
]]
function GuideTaskTypes.GetPlainText(task)
	local text = GuideTaskTypes.GetText(task) or ""
	text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	-- Drop the note, which lives on its own line. string.char(10) rather than an
	-- escape: escape sequences do not survive every editing path intact.
	local newline = string.char(10)
	text = text:gsub(newline .. ".*", "")
	return text
end

function GuideTaskTypes.GetTypeNames()
	local names = { }
	for name in pairs(types) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end
