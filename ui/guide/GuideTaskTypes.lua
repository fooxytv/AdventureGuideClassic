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

Icons are deliberately drawn from Interface\GossipFrame and the raid target set, which
ship with every client, rather than guessed Interface\Icons paths -- a wrong icon path
renders as a blank square with no error.
]]

GuideTaskTypes = { }

local types = { }

local GOSSIP = "Interface/GossipFrame/%sGossipIcon"
local FALLBACK_ICON = "Interface/Icons/INV_Misc_QuestionMark"

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
	icon = "Interface/TargetingFrame/UI-RaidTargetingIcon_8",
	Format = function(task)
		if task.count then
			return ("Kill %d x %s"):format(task.count, Quote(task.target))
		end
		return ("Kill %s"):format(Quote(task.target))
	end,
})

Register("collect", {
	icon = "Interface/Minimap/Tracking/Banker",
	Format = function(task)
		if task.count then
			return ("Collect %d x %s"):format(task.count, Quote(task.item))
		end
		return ("Collect %s"):format(Quote(task.item))
	end,
})

Register("goto", {
	icon = "Interface/Minimap/Tracking/Target",
	Format = function(task)
		return ("Travel to %s"):format(Quote(task.place))
	end,
})

Register("sethearth", {
	icon = ("%s"):format(GOSSIP:format("Binder")),
	Format = function(task)
		return ("Set your hearthstone at %s"):format(Quote(task.place))
	end,
})

Register("hearth", {
	icon = ("%s"):format(GOSSIP:format("Binder")),
	Format = function(task)
		return ("Hearth to %s"):format(Quote(task.place))
	end,
})

Register("taxi", {
	icon = ("%s"):format(GOSSIP:format("Taxi")),
	Format = function(task)
		return ("Fly to %s"):format(Quote(task.place))
	end,
})

Register("vendor", {
	icon = ("%s"):format(GOSSIP:format("Vendor")),
	Format = function(task)
		return task.place and ("Sell and repair at %s"):format(Quote(task.place))
			or "Sell junk and repair"
	end,
})

Register("train", {
	icon = ("%s"):format(GOSSIP:format("Trainer")),
	Format = function(task)
		return task.place and ("Train your new spells at %s"):format(Quote(task.place))
			or "Train your new spells"
	end,
})

Register("level", {
	icon = "Interface/Minimap/Tracking/Class",
	Format = function(task)
		return ("Reach level %s before moving on"):format(Quote(task.level))
	end,
})

Register("note", {
	icon = "Interface/GossipFrame/GossipGossipIcon",
	Format = function(task)
		return tostring(task.text or "")
	end,
})

function GuideTaskTypes.Get(task)
	if not task then return nil end
	return types[task[1]]
end

function GuideTaskTypes.GetIcon(task)
	local definition = GuideTaskTypes.Get(task)
	return (definition and definition.icon) or FALLBACK_ICON
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

function GuideTaskTypes.GetTypeNames()
	local names = { }
	for name in pairs(types) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end
