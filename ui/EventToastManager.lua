select(2, ...).SetupGlobalFacade()

local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetSpellTextureCompat = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture

local IS_ERA = select(4, GetBuildInfo()) < 20000

local function GetLevelUpSpells(level)
	if not IS_ERA or not SpellsByLevelService then return {} end
	if not (SettingsService and SettingsService.GetLevelUpSpellsEnabled
		and SettingsService.GetLevelUpSpellsEnabled()) then
		return {}
	end
	return SpellsByLevelService.GetNewSpells(level)
end

local SPELL_ICON_SIZE = 34
local SPELL_ICON_GAP = 6
local SPELL_MAX_PER_ROW = 6
local HOVER_GRACE = 2

AdventureGuideClassicEventToastManager = AdventureGuideClassicEventToastManager or {}

local function ApplyToastLayout(frame, toastType)
	if not SettingsService then return end
	frame:SetScale(SettingsService.GetToastScale(toastType))
	local pos = SettingsService.GetToastPosition(toastType)
	frame:ClearAllPoints()
	frame:SetPoint(pos.anchor, UIParent, pos.relativeAnchor, pos.x, pos.y)
end

local function ScheduleAutoHide(frame, showDuration, fadeDuration)
	local mgr = AdventureGuideClassicEventToastManager
	frame:SetScript("OnUpdate", nil)
	mgr.hoverPaused = false
	mgr.toastGen = (mgr.toastGen or 0) + 1
	local gen = mgr.toastGen
	C_Timer.After(showDuration, function()
		if mgr.previewMode then return end
		if mgr.toastGen ~= gen then return end
		UIFrameFadeOut(frame, fadeDuration, 1, 0)
		C_Timer.After(fadeDuration, function()
			if mgr.previewMode then return end
			if mgr.toastGen ~= gen then return end
			frame:Hide()
		end)
	end)
end

function AdventureGuideClassicEventToastManager:PauseHideForHover()
	local frame = self.frame
	if not frame then return end
	self.toastGen = (self.toastGen or 0) + 1
	UIFrameFadeRemoveFrame(frame)
	frame:SetAlpha(1)
	if self.previewMode or self.hoverPaused then return end
	self.hoverPaused = true
	local elapsed = 0
	frame:SetScript("OnUpdate", function(f, dt)
		elapsed = elapsed + dt
		if elapsed < 0.1 then return end
		elapsed = 0
		if f.spellTray and f.spellTray:IsShown() and f.spellTray:IsMouseOver() then return end
		f:SetScript("OnUpdate", nil)
		self.hoverPaused = false
		ScheduleAutoHide(f, HOVER_GRACE, 1)
	end)
end

function AdventureGuideClassicEventToastManager:CreateToastFrame()
	if self.frame then return end
	local frame = CreateFrame("Frame", "EventToastFrame", UIParent)
	frame:SetSize(400, 80)
	frame:SetPoint("TOP", UIParent, "TOP", 0, -120)
	frame:Hide()
	frame.background = frame:CreateTexture(nil, "BACKGROUND")
	frame.background:SetSize(400, 120)
	frame.background:SetTexture(I.EventToastBossBannerBG)
	frame.background:SetPoint("CENTER", frame, "CENTER", 0, 6)
	frame.topBanner = frame:CreateTexture(nil, "ARTWORK")
	frame.topBanner:SetSize(400, 20)
	frame.topBanner:SetPoint("TOP", frame, "TOP", 0, 4)
	frame.topBanner:SetTexture(I.EventToastBannerTop)
	frame.topBanner:SetDrawLayer("ARTWORK", 0)
	frame.bottomBanner = frame:CreateTexture(nil, "ARTWORK")
	frame.bottomBanner:SetSize(400, 20)
	frame.bottomBanner:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
	frame.bottomBanner:SetTexture(I.EventToastBannerBottom)
	frame.instanceBanner = frame:CreateTexture(nil, "OVERLAY")
	frame.instanceBanner:SetSize(256, 64)
	frame.instanceBanner:SetPoint("CENTER", frame, "CENTER", 0, 52)
	frame.instanceBanner:SetTexture(I.EventToastInstanceBanner)
	frame.instanceBanner:SetDrawLayer("OVERLAY", 5)
	frame.instanceBannerBottom = frame:CreateTexture(nil, "OVERLAY")
	frame.instanceBannerBottom:SetSize(256, 64)
	frame.instanceBannerBottom:SetPoint("BOTTOM", frame.instanceBanner, "BOTTOM", 0, -80)
	frame.instanceBannerBottom:SetTexture(I.EventToastInstanceBanner)
	frame.instanceBannerBottom:SetTexCoord(0, 1, 1, 0)
	frame.bossDefeatBanner = frame:CreateTexture(nil, "OVERLAY")
	frame.bossDefeatBanner:SetSize(256, 128)
	frame.bossDefeatBanner:SetPoint("CENTER", frame, "CENTER", 0, 55)
	frame.bossDefeatBanner:SetTexture(I.EventToastBossBanner)
	frame.bossDefeatBanner:SetDrawLayer("OVERLAY", 1)
	frame.bossDefeatBannerBottom = frame:CreateTexture(nil, "OVERLAY")
	frame.bossDefeatBannerBottom:SetSize(64, 24)
	frame.bossDefeatBannerBottom:SetPoint("BOTTOM", frame.bossDefeatBanner, "BOTTOM", 0, -15)
	frame.bossDefeatBannerBottom:SetTexture(I.EventToastBossBannerBottomSmall)
	frame.wishlistGlow = frame:CreateTexture(nil, "BACKGROUND")
	frame.wishlistGlow:SetSize(420, 100)
	frame.wishlistGlow:SetPoint("CENTER", frame, "CENTER", 0, 5)
	frame.wishlistGlow:SetTexture("Interface\\GLUES\\Models\\UI_MainMenu\\swordglow")
	frame.wishlistGlow:SetBlendMode("ADD")
	frame.wishlistGlow:SetVertexColor(1, 0.82, 0, 0.6)
	frame.wishlistStarLeft = frame:CreateTexture(nil, "OVERLAY")
	frame.wishlistStarLeft:SetSize(32, 32)
	frame.wishlistStarLeft:SetPoint("LEFT", frame, "LEFT", 30, 5)
	frame.wishlistStarLeft:SetTexture("Interface\\COMMON\\ReputationStar")
	frame.wishlistStarLeft:SetTexCoord(0, 0.5, 0, 0.5)
	frame.wishlistStarRight = frame:CreateTexture(nil, "OVERLAY")
	frame.wishlistStarRight:SetSize(32, 32)
	frame.wishlistStarRight:SetPoint("RIGHT", frame, "RIGHT", -30, 5)
	frame.wishlistStarRight:SetTexture("Interface\\COMMON\\ReputationStar")
	frame.wishlistStarRight:SetTexCoord(0, 0.5, 0, 0.5)
	frame.wishlistIconLeft = frame:CreateTexture(nil, "ARTWORK")
	frame.wishlistIconLeft:SetSize(40, 40)
	frame.wishlistIconLeft:SetPoint("LEFT", frame, "LEFT", 60, 5)
	frame.wishlistIconLeft:SetTexture("Interface\\Icons\\INV_Misc_Bag_10_Blue")
	frame.wishlistIconRight = frame:CreateTexture(nil, "ARTWORK")
	frame.wishlistIconRight:SetSize(40, 40)
	frame.wishlistIconRight:SetPoint("RIGHT", frame, "RIGHT", -60, 5)
	frame.wishlistIconRight:SetTexture("Interface\\Icons\\INV_Misc_Bag_10_Blue")
	frame.wishlistBorderLeft = frame:CreateTexture(nil, "OVERLAY")
	frame.wishlistBorderLeft:SetSize(48, 48)
	frame.wishlistBorderLeft:SetPoint("CENTER", frame.wishlistIconLeft, "CENTER", 0, 0)
	frame.wishlistBorderLeft:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	frame.wishlistBorderLeft:SetBlendMode("ADD")
	frame.wishlistBorderLeft:SetVertexColor(1, 0.82, 0)
	frame.wishlistBorderRight = frame:CreateTexture(nil, "OVERLAY")
	frame.wishlistBorderRight:SetSize(48, 48)
	frame.wishlistBorderRight:SetPoint("CENTER", frame.wishlistIconRight, "CENTER", 0, 0)
	frame.wishlistBorderRight:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	frame.wishlistBorderRight:SetBlendMode("ADD")
	frame.wishlistBorderRight:SetVertexColor(1, 0.82, 0)
	frame.title = frame:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 11)
	frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -35)
	frame.spellTray = CreateFrame("Frame", nil, frame)
	frame.spellTray:SetPoint("TOP", frame, "CENTER", 0, -46)
	frame.spellTray:SetSize(400, 60)
	frame.spellTray:SetFrameLevel(frame:GetFrameLevel() + 10)
	frame.spellTray:Hide()
	frame.spellTray.header = frame.spellTray:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.spellTray.header:SetPoint("TOP", frame.spellTray, "TOP", 0, -6)
	frame.spellTray.header:SetTextColor(1, 0.82, 0)
	frame.spellTray.icons = {}
	self.frame = frame
end

local function ResetToastBackground(frame)
	frame.background:SetSize(400, 120)
	frame.background:ClearAllPoints()
	frame.background:SetPoint("CENTER", frame, "CENTER", 0, 6)
end

local function CreateSpellIcon(parent)
	local icon = CreateFrame("Button", nil, parent)
	icon:SetSize(SPELL_ICON_SIZE, SPELL_ICON_SIZE)
	icon.edge = icon:CreateTexture(nil, "BACKGROUND")
	icon.edge:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
	icon.edge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
	icon.edge:SetColorTexture(0, 0, 0, 1)
	icon.texture = icon:CreateTexture(nil, "ARTWORK")
	icon.texture:SetAllPoints(icon)
	icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetScript("OnEnter", function(self)
		AdventureGuideClassicEventToastManager:PauseHideForHover()
		if not self.spellID then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(self.spellID)
		GameTooltip:Show()
	end)
	icon:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return icon
end

local function LayoutSpellTray(frame, spells)
	local tray = frame.spellTray
	for _, icon in ipairs(tray.icons) do icon:Hide() end

	local count = #spells
	if count == 0 then
		tray:Hide()
		ResetToastBackground(frame)
		return 0
	end

	tray.header:SetText(count == 1 and "New Ability" or "New Abilities")

	local topPad = 24
	local rows = math.ceil(count / SPELL_MAX_PER_ROW)
	for index, spell in ipairs(spells) do
		local icon = tray.icons[index]
		if not icon then
			icon = CreateSpellIcon(tray)
			tray.icons[index] = icon
		end
		local row = math.floor((index - 1) / SPELL_MAX_PER_ROW)
		local rowCount = math.min(SPELL_MAX_PER_ROW, count - row * SPELL_MAX_PER_ROW)
		local col = (index - 1) % SPELL_MAX_PER_ROW
		local rowWidth = rowCount * SPELL_ICON_SIZE + (rowCount - 1) * SPELL_ICON_GAP
		local x = -rowWidth / 2 + SPELL_ICON_SIZE / 2 + col * (SPELL_ICON_SIZE + SPELL_ICON_GAP)
		local y = topPad + SPELL_ICON_SIZE / 2 + row * (SPELL_ICON_SIZE + SPELL_ICON_GAP)
		icon:ClearAllPoints()
		icon:SetPoint("CENTER", tray, "TOP", x, -y)
		icon.spellID = spell.id
		icon.texture:SetTexture(GetSpellTextureCompat(spell.id) or "Interface\\Icons\\INV_Misc_QuestionMark")
		icon:Show()
	end

	local height = topPad + rows * SPELL_ICON_SIZE + (rows - 1) * SPELL_ICON_GAP + 10
	tray:SetHeight(height)
	local newHeight = 116 + height
	frame.background:SetSize(400, newHeight)
	frame.background:ClearAllPoints()
	frame.background:SetPoint("CENTER", frame, "CENTER", 0, (16 - height) / 2)
	tray:Show()
	return height
end

local function HideWishlistElements(frame)
	frame.wishlistGlow:Hide()
	frame.wishlistStarLeft:Hide()
	frame.wishlistStarRight:Hide()
	frame.wishlistIconLeft:Hide()
	frame.wishlistIconRight:Hide()
	frame.wishlistBorderLeft:Hide()
	frame.wishlistBorderRight:Hide()
end

function AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast(title, subtitle, bypassSettings)
	if not bypassSettings and SettingsService and not SettingsService.GetToastEnabled("BossDefeated") then
		return
	end
	if not self.frame then
		self:CreateToastFrame()
	end
	local frame = self.frame
	ApplyToastLayout(frame, "BossDefeated")
	frame.instanceBanner:Hide()
	frame.instanceBannerBottom:Hide()
	frame.bossDefeatBanner:Show()
	frame.bossDefeatBannerBottom:Show()
	frame.topBanner:Show()
	frame.bottomBanner:Show()
	HideWishlistElements(frame)
	frame.spellTray:Hide()
	ResetToastBackground(frame)
	frame.background:Show()
	frame.background:SetAlpha(0.7)
	frame.title:SetFont("Fonts\\MORPHEUS.TTF", 26, "")
	frame.title:SetTextColor(0.8, 0.1, 0.1)
	frame.title:SetShadowOffset(0, 0)
	frame.title:SetShadowColor(0, 0, 0, 0)
	frame.title:ClearAllPoints()
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 11)
	frame.title:SetText(title)
	frame.subtitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
	frame.subtitle:SetTextColor(0.8, 0.1, 0.1)
	frame.subtitle:SetShadowOffset(0, 0)
	frame.subtitle:SetShadowColor(0, 0, 0, 0)
	frame.subtitle:ClearAllPoints()
	frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -25)
	frame.subtitle:SetText(subtitle)
	frame:SetAlpha(0)
	frame:Show()
	UIFrameFadeIn(frame, 1, 0, 1)
	ScheduleAutoHide(frame, 5, 1)
end

function AdventureGuideClassicEventToastManager:ShowInstanceToast(title, subtitle, spells, bypassSettings)
	if not bypassSettings and SettingsService and not SettingsService.GetToastEnabled("LevelUp") then
		return
	end
	if not self.frame then
		self:CreateToastFrame()
	end
	local frame = self.frame
	ApplyToastLayout(frame, "LevelUp")
	frame.bossDefeatBanner:Hide()
	frame.bossDefeatBannerBottom:Hide()
	frame.instanceBanner:Hide()
	frame.instanceBannerBottom:Hide()
	frame.topBanner:Hide()
	frame.bottomBanner:Hide()
	HideWishlistElements(frame)
	frame.background:Show()
	frame.background:SetAlpha(0.7)
	frame.title:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
	frame.title:SetTextColor(1, 1, 1)
	frame.title:SetShadowOffset(1, -1)
	frame.title:SetShadowColor(0, 0, 0, 1)
	frame.title:ClearAllPoints()
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 20)
	frame.title:SetText(title)
	frame.subtitle:SetFont("Fonts\\FRIZQT__.TTF", 28, "")
	frame.subtitle:SetTextColor(1, 0.82, 0)
	frame.subtitle:SetShadowOffset(0, 0)
	frame.subtitle:SetShadowColor(0, 0, 0, 0)
	frame.subtitle:ClearAllPoints()
	frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -8)
	frame.subtitle:SetText(subtitle)
	local hasSpells = LayoutSpellTray(frame, spells or {}) > 0
	frame:SetAlpha(0)
	frame:Show()
	UIFrameFadeIn(frame, 1, 0, 1)
	ScheduleAutoHide(frame, hasSpells and 9 or 6, 1)
end

function AdventureGuideClassicEventToastManager:ShowWishlistToast(title, subtitle, itemID, bypassSettings)
	if not bypassSettings and SettingsService and not SettingsService.GetToastEnabled("WishlistItem") then
		return
	end
	if not self.frame then
		self:CreateToastFrame()
	end
	local frame = self.frame
	ApplyToastLayout(frame, "WishlistItem")
	frame.instanceBanner:Hide()
	frame.instanceBannerBottom:Hide()
	frame.bossDefeatBanner:Hide()
	frame.bossDefeatBannerBottom:Hide()
	frame.topBanner:Hide()
	frame.bottomBanner:Hide()
	HideWishlistElements(frame)
	frame.spellTray:Hide()
	ResetToastBackground(frame)
	frame.wishlistGlow:Show()
	frame.wishlistGlow:SetAlpha(0.4)
	frame.background:Show()
	frame.background:SetAlpha(0.8)
	frame.title:SetFont("Fonts\\FRIZQT__.TTF", 18, "")
	frame.title:SetTextColor(1, 0.82, 0) -- Gold
	frame.title:SetShadowOffset(1, -1)
	frame.title:SetShadowColor(0, 0, 0, 1)
	frame.title:ClearAllPoints()
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 12)
	frame.title:SetText(title)
	frame.subtitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
	frame.subtitle:SetTextColor(0.9, 0.9, 0.9)
	frame.subtitle:SetShadowOffset(1, -1)
	frame.subtitle:SetShadowColor(0, 0, 0, 1)
	frame.subtitle:ClearAllPoints()
	frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -10)
	frame.subtitle:SetText(subtitle)
	frame:SetAlpha(0)
	frame:Show()
	UIFrameFadeIn(frame, 0.5, 0, 1)
	ScheduleAutoHide(frame, 3, 0.5)
end

local PREVIEW_SAMPLES = {
	BossDefeated = function(self) self:ShowEncounterDefeatedToast("Preview Boss", "has been defeated!", true) end,
	LevelUp = function(self)
		local lvl = UnitLevel("player") or 1
		self:ShowInstanceToast("You've Reached", "Level " .. lvl, GetLevelUpSpells(lvl), true)
	end,
	WishlistItem = function(self) self:ShowWishlistToast("Wishlist Item Found!", "Preview Item", 6948, true) end,
}

local function EnsurePreviewHint(frame)
	if frame.previewHint then return frame.previewHint end
	local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	hint:SetPoint("BOTTOM", frame, "TOP", 0, 8)
	hint:SetText("Drag to position - click Lock in settings when done")
	hint:SetTextColor(1, 0.82, 0)
	frame.previewHint = hint
	return hint
end

function AdventureGuideClassicEventToastManager:StartPreview(toastType)
	if not PREVIEW_SAMPLES[toastType] then return end
	self.previewMode = true
	self.previewType = toastType
	local sample = PREVIEW_SAMPLES[toastType]
	sample(self)
	local frame = self.frame
	frame:SetAlpha(1)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
	frame:SetScript("OnDragStop", function(f)
		f:StopMovingOrSizing()
		local anchor, _, relAnchor, x, y = f:GetPoint()
		SettingsService.SetToastPosition(toastType, {
			anchor = anchor or "TOP",
			relativeAnchor = relAnchor or "TOP",
			x = x or 0,
			y = y or 0,
		})
	end)
	EnsurePreviewHint(frame):Show()
end

function AdventureGuideClassicEventToastManager:StopPreview()
	self.previewMode = false
	self.previewType = nil
	self.toastGen = (self.toastGen or 0) + 1
	local frame = self.frame
	if not frame then return end
	frame:EnableMouse(false)
	frame:SetMovable(false)
	frame:RegisterForDrag()
	frame:SetScript("OnDragStart", nil)
	frame:SetScript("OnDragStop", nil)
	if frame.previewHint then frame.previewHint:Hide() end
	frame:Hide()
end

function AdventureGuideClassicEventToastManager:IsPreviewing(toastType)
	if not self.previewMode then return false end
	if toastType then return self.previewType == toastType end
	return true
end

if SettingsService and SettingsService.RegisterToastListener then
	SettingsService.RegisterToastListener(function(toastType)
		local mgr = AdventureGuideClassicEventToastManager
		if mgr.previewMode and mgr.previewType == toastType and mgr.frame then
			ApplyToastLayout(mgr.frame, toastType)
		end
	end)
end

AdventureGuideClassicEventToastManager:CreateToastFrame()
local levelUpFrame = CreateFrame("Frame")
levelUpFrame:RegisterEvent("PLAYER_LEVEL_UP")
levelUpFrame:SetScript("OnEvent", function(_, event, level)
	AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. level, GetLevelUpSpells(level))
end)

_G.TestLevelUpToast = function()
	local playerLevel = UnitLevel("player")
	AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. playerLevel, GetLevelUpSpells(playerLevel), true)
	print("Testing level-up toast for Level " .. playerLevel)
end

_G.TestLevelUpToastAt = function(level)
	level = level or UnitLevel("player")
	local spells = GetLevelUpSpells(level)
	AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. level, spells, true)
	print("Testing level-up toast for Level " .. level .. " (" .. #spells .. " learnable spells)")
end

_G.TestBossDefeatedToast = function()
	AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast("Test Boss Name", "has been defeated!", true)
	print("Testing boss defeat toast")
end

_G.TestBossDefeatedToastCustom = function(bossName)
	bossName = bossName or "Test Boss"
	AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast(bossName, "has been defeated!", true)
	print("Testing boss defeat toast: " .. bossName)
end

_G.TestWishlistToast = function()
	AdventureGuideClassicEventToastManager:ShowWishlistToast("Wishlist Item Found!", "Hearthstone", 6948, true)
	print("Testing wishlist toast")
end

_G.TestWishlistToastCustom = function(itemID)
	itemID = itemID or 6948
	local itemName = GetItemInfoCompat(itemID) or "Unknown Item"
	AdventureGuideClassicEventToastManager:ShowWishlistToast("Wishlist Item Found!", itemName, itemID, true)
	print("Testing wishlist toast for item: " .. itemName)
end
