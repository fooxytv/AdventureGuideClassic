--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
One window showing all three talent trees side by side, instead of Blizzard's
single panel with a tab per specialisation.

The trees are NOT drawn here. TalentFrame_Update (Blizzard_FrameXML, always
loaded -- it is Blizzard_TalentUI that is load-on-demand, not the renderer)
takes the frame to draw as a parameter and resolves that frame's children by
global name. So it already knows how to draw backgrounds, buttons, ranks,
prerequisite branches, arrows, tier gating and desaturation, and all this file
does is build three frames that satisfy its naming contract and call it once
per tree with a different selectedTab.

Blizzard's own InspectTalentFrame reuses the renderer the same way, so this is
a supported pattern rather than a trick. Reimplementing the layout would mean
owning the branch and arrow maths -- the part most likely to be subtly wrong.

The contract, for a frame named N:

    N.."BackgroundTopLeft"/"TopRight"/"BottomLeft"/"BottomRight"  textures
    N.."ScrollChildFrame"      buttons and branches parent to this
    N.."ArrowFrame"            arrows parent to this
    N.."ScrollFrame"           must inherit UIPanelScrollFrameTemplate
    N.."Talent"1..MAX_NUM_TALENTS
    N.."Branch"1..MAX_NUM_BRANCH_TEXTURES
    N.."Arrow"1..MAX_NUM_ARROW_TEXTURES
    N.."TalentPointsText"      FontString

The ScrollFrame is load-bearing even though nothing here scrolls horizontally:
TalentFrame_UpdateTalentPoints does an *unguarded*

    _G[name.."ScrollFrameScrollBarScrollDownButton"]:SetScript(...)

so a tree frame without one throws on every update.
]]

TalentWindow = { }

local WINDOW_NAME = "AdventureGuideClassicTalentWindow"
local TREE_PREFIX = "AdventureGuideClassicTalentTree"

-- 287 = INITIAL_TALENT_OFFSET_X (35) + 4 columns * 63 pitch, so a tree's
-- content is 287 wide however deep the class tree happens to be.
local TREE_WIDTH = 300
-- Era's deepest tier is 7 and TBC's is 9, which is 430 and 556 pixels of tree.
-- Rather than size to the taller and overflow a 1080p screen, the viewport is
-- fixed and the ScrollFrame -- which has to exist anyway, see above -- takes
-- up the difference.
local TREE_HEIGHT = 460
local TREE_GAP = 12
local HEADER_HEIGHT = 54
local FOOTER_HEIGHT = 30

local window
local trees = { }

-- CreateFrame registers a named frame in _G by itself, and templates register
-- their own $parent children, but CreateTexture and CreateFontString do not.
-- The renderer looks every one of these up through _G, so the ones we create
-- by hand are published explicitly.
local function Publish(name, object)
	_G[name] = object
	return object
end

local function BuildTree(index)
	local name = TREE_PREFIX .. index
	local tree = CreateFrame("Frame", name, window)
	tree:SetSize(TREE_WIDTH, TREE_HEIGHT)

	-- What TalentFrame_Update reads off the frame itself. selectedTab is set
	-- directly rather than through PanelTemplates_SetTab, because that also
	-- calls PanelTemplates_UpdateTabs, which expects a row of tab buttons this
	-- window deliberately does not have. PanelTemplates_GetSelectedTab is a
	-- one-line `return frame.selectedTab`, so this is the whole contract.
	tree.selectedTab = index
	tree.talentGroup = 1
	tree.inspect = nil
	tree.pet = nil

	-- Spec name and the points spent in this tree, above each column.
	tree.title = Publish(name .. "Title",
		tree:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"))
	tree.title:SetPoint("TOPLEFT", 8, -4)
	tree.title:SetJustifyH("LEFT")
	tree.title:SetTextColor(0.902, 0.788, 0.671)

	tree.pointsText = Publish(name .. "PointsText",
		tree:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
	tree.pointsText:SetPoint("TOPLEFT", tree.title, "BOTTOMLEFT", 0, -2)
	tree.pointsText:SetJustifyH("LEFT")

	-- TalentFrame_UpdateTalentPoints writes the player's unspent points into
	-- this for every tree it updates. Only the first is shown -- three copies
	-- of one number is noise -- but all three must exist or the update throws.
	tree.talentPointsText = Publish(name .. "TalentPointsText",
		tree:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
	tree.talentPointsText:SetPoint("BOTTOMLEFT", tree, "BOTTOMLEFT", 8, 4)
	tree.talentPointsText:SetJustifyH("LEFT")
	if (index > 1) then
		tree.talentPointsText:Hide()
	end

	local scrollFrame = CreateFrame("ScrollFrame", name .. "ScrollFrame", tree,
		"UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 0, -28)
	scrollFrame:SetSize(TREE_WIDTH - 22, TREE_HEIGHT - 28)

	local scrollChild = CreateFrame("Frame", name .. "ScrollChildFrame", scrollFrame)
	scrollChild:SetSize(TREE_WIDTH - 22, TREE_HEIGHT * 2)
	scrollFrame:SetScrollChild(scrollChild)

	-- The four quadrants of the class tree artwork. TalentFrame_Update points
	-- them at Interface\TalentFrame\<background>-<corner>, where <background>
	-- is return 8 of GetSpecializationInfo, so the file name is never our
	-- problem -- only the anchoring is.
	local corners = {
		BackgroundTopLeft = { "TOPLEFT", 0, 0 },
		BackgroundTopRight = { "TOPRIGHT", 0, 0 },
		BackgroundBottomLeft = { "BOTTOMLEFT", 0, 0 },
		BackgroundBottomRight = { "BOTTOMRIGHT", 0, 0 },
	}
	for suffix, anchor in pairs(corners) do
		local texture = Publish(name .. suffix,
			scrollChild:CreateTexture(nil, "BACKGROUND"))
		texture:SetSize(256, 256)
		texture:SetPoint(anchor[1], scrollChild, anchor[1], anchor[2], anchor[3])
	end

	-- Arrows sit above the buttons, so their parent is a frame layered over
	-- the scroll child rather than the scroll child itself.
	local arrowFrame = CreateFrame("Frame", name .. "ArrowFrame", scrollChild)
	arrowFrame:SetAllPoints(scrollChild)
	arrowFrame:SetFrameLevel(scrollChild:GetFrameLevel() + 2)

	for i = 1, MAX_NUM_BRANCH_TEXTURES do
		Publish(name .. "Branch" .. i,
			scrollChild:CreateTexture(nil, "ARTWORK", "TalentBranchTemplate"))
	end
	for i = 1, MAX_NUM_ARROW_TEXTURES do
		Publish(name .. "Arrow" .. i,
			arrowFrame:CreateTexture(nil, "OVERLAY", "TalentArrowTemplate"))
	end

	for i = 1, MAX_NUM_TALENTS do
		local button = CreateFrame("Button", name .. "Talent" .. i, scrollChild,
			"TalentButtonTemplate")
		-- The renderer reads button:GetID() as the talent index; Blizzard sets
		-- it in XML, so it has to be set here instead.
		button:SetID(i)
		button.treeIndex = index
		button:RegisterForClicks("LeftButtonUp")
		button:SetScript("OnClick", function(self)
			TalentWindow.OnTalentClick(self)
		end)
		button:SetScript("OnEnter", function(self)
			TalentWindow.OnTalentEnter(self)
		end)
		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		button:Hide()
	end

	return tree
end

function TalentWindow.OnTalentClick(button)
	if (InCombatLockdown()) then
		return
	end
	-- Blizzard calls LearnTalent straight out of its own OnClick with no
	-- secure path, and this is an OnClick too, so the hardware event this
	-- needs is the click that got us here.
	LearnTalent(button.treeIndex, button:GetID(), nil, 1)
end

function TalentWindow.OnTalentEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	local talentInfo = C_SpecializationInfo.GetTalentInfo({
		specializationIndex = button.treeIndex,
		talentIndex = button:GetID(),
		groupIndex = 1,
	})
	if (talentInfo and talentInfo.talentID) then
		GameTooltip:SetTalent(talentInfo.talentID, false, false, 1)
		GameTooltip:Show()
	end
end

function TalentWindow.Update()
	if (not window or not window:IsShown()) then
		return
	end

	local talentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false) or 1

	for index, tree in ipairs(trees) do
		tree.talentGroup = talentGroup

		local _, specName, _, _, _, _, pointsSpent, _, previewPointsSpent =
			C_SpecializationInfo.GetSpecializationInfo(index, false, false, nil, nil, talentGroup)

		tree.title:SetText(specName or "")
		tree.pointsText:SetText((pointsSpent or 0) + (previewPointsSpent or 0))

		-- Every tree is drawn by the same renderer that draws Blizzard's own
		-- panel; only selectedTab differs.
		TalentFrame_Update(tree)
	end
end

local function BuildWindow()
	window = CreateFrame("Frame", WINDOW_NAME, UIParent, "BackdropTemplate")
	window:SetSize(
		(TREE_WIDTH * 3) + (TREE_GAP * 4),
		TREE_HEIGHT + HEADER_HEIGHT + FOOTER_HEIGHT)
	window:SetPoint("CENTER")
	window:SetFrameStrata("HIGH")
	window:SetToplevel(true)
	window:EnableMouse(true)
	window:SetMovable(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	window:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})

	window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	window.title:SetPoint("TOP", 0, -16)
	--todo: Localize
	window.title:SetText("Talents")

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)

	for index = 1, MAX_TALENT_TABS do
		local tree = BuildTree(index)
		if (index == 1) then
			tree:SetPoint("TOPLEFT", TREE_GAP, -HEADER_HEIGHT)
		else
			tree:SetPoint("TOPLEFT", trees[index - 1], "TOPRIGHT", TREE_GAP, 0)
		end
		trees[index] = tree
	end

	-- Escape closes it, the way the stock panel does.
	table.insert(UISpecialFrames, WINDOW_NAME)

	window:SetScript("OnEvent", function()
		TalentWindow.Update()
	end)
	window:RegisterEvent("PLAYER_TALENT_UPDATE")
	window:RegisterEvent("CHARACTER_POINTS_CHANGED")
	window:RegisterEvent("SPELLS_CHANGED")
	window:SetScript("OnShow", function()
		TalentWindow.Update()
	end)

	return window
end

function TalentWindow.Toggle()
	-- Nothing is built until the window is first asked for: a player who never
	-- opens it pays nothing, and the 200-odd widgets below are not created
	-- during login.
	if (not window) then
		if (not GetNumTalentTabs or GetNumTalentTabs() == 0) then
			--todo: Localize
			print("|cffff5555[AGC]|r This client has no talent trees to show.")
			return
		end
		BuildWindow()
	end

	if (window:IsShown()) then
		window:Hide()
	else
		window:Show()
	end
end
