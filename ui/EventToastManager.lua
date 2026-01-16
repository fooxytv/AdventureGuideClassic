select(2, ...).SetupGlobalFacade()

AdventureGuideClassicEventToastManager = AdventureGuideClassicEventToastManager or {}

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

	-- Wishlist-specific elements
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
	self.frame = frame
end

-- Helper to hide all wishlist elements
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
	-- Check if boss defeated toasts are enabled (unless bypassed for testing)
	if not bypassSettings and SettingsService and not SettingsService.GetToastEnabled("BossDefeated") then
		return
	end

	if not self.frame then
		self:CreateToastFrame()
	end
	local frame = self.frame

	-- Hide instance banners, show boss defeat banners
	frame.instanceBanner:Hide()
	frame.instanceBannerBottom:Hide()
	frame.bossDefeatBanner:Show()
	frame.bossDefeatBannerBottom:Show()
	frame.topBanner:Show()
	frame.bottomBanner:Show()
	HideWishlistElements(frame)

	-- Show dark transparent background
	frame.background:Show()
	frame.background:SetAlpha(0.7)

	-- Boss name - large and prominent (MORPHEUS font like modern WoW)
	frame.title:SetFont("Fonts\\MORPHEUS.TTF", 26, "")
	frame.title:SetTextColor(0.8, 0.1, 0.1)
	frame.title:SetShadowOffset(0, 0)
	frame.title:SetShadowColor(0, 0, 0, 0)
	frame.title:ClearAllPoints()
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 11)
	frame.title:SetText(title)

	-- "has been defeated" - smaller text below, moved down to avoid texture overlap
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
	C_Timer.After(5, function()
		UIFrameFadeOut(frame, 1, 1, 0)
		C_Timer.After(1, function()
			frame:Hide()
		end)
	end)
end

function AdventureGuideClassicEventToastManager:ShowInstanceToast(title, subtitle, bypassSettings)
	-- Check if level up toasts are enabled (unless bypassed for testing)
	if not bypassSettings and SettingsService and not SettingsService.GetToastEnabled("LevelUp") then
		return
	end

	if not self.frame then
		self:CreateToastFrame()
	end

	local frame = self.frame

	-- Hide all decorative banners for simple look
	frame.bossDefeatBanner:Hide()
	frame.bossDefeatBannerBottom:Hide()
	frame.instanceBanner:Hide()
	frame.instanceBannerBottom:Hide()
	frame.topBanner:Hide()
	frame.bottomBanner:Hide()
	HideWishlistElements(frame)

	-- Show dark transparent background
	frame.background:Show()
	frame.background:SetAlpha(0.7)

	-- Simple text styling - "You've Reached" - moved up
	frame.title:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
	frame.title:SetTextColor(1, 1, 1)
	frame.title:SetShadowOffset(1, -1)
	frame.title:SetShadowColor(0, 0, 0, 1)
	frame.title:ClearAllPoints()
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 20)
	frame.title:SetText(title)

	-- "Level X" - larger golden text
	frame.subtitle:SetFont("Fonts\\FRIZQT__.TTF", 28, "")
	frame.subtitle:SetTextColor(1, 0.82, 0)
	frame.subtitle:SetShadowOffset(0, 0)
	frame.subtitle:SetShadowColor(0, 0, 0, 0)
	frame.subtitle:ClearAllPoints()
	frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -8)
	frame.subtitle:SetText(subtitle)

	frame:SetAlpha(0)
	frame:Show()
	UIFrameFadeIn(frame, 1, 0, 1)
	C_Timer.After(6, function()
		UIFrameFadeOut(frame, 1, 1, 0)
		C_Timer.After(1, function()
			frame:Hide()
		end)
	end)
end

function AdventureGuideClassicEventToastManager:ShowWishlistToast(title, subtitle, itemID, bypassSettings)
	-- Check if wishlist toasts are enabled (unless bypassed for testing)
	if not bypassSettings and SettingsService and not SettingsService.GetToastEnabled("WishlistItem") then
		return
	end

	if not self.frame then
		self:CreateToastFrame()
	end
	local frame = self.frame

	-- Hide all decorative elements for a clean, subtle look
	frame.instanceBanner:Hide()
	frame.instanceBannerBottom:Hide()
	frame.bossDefeatBanner:Hide()
	frame.bossDefeatBannerBottom:Hide()
	frame.topBanner:Hide()
	frame.bottomBanner:Hide()
	HideWishlistElements(frame)

	-- Show subtle golden glow only
	frame.wishlistGlow:Show()
	frame.wishlistGlow:SetAlpha(0.4)

	-- Show dark transparent background
	frame.background:Show()
	frame.background:SetAlpha(0.8)

	-- Title - "Wishlist Item Found!" in gold, centered
	frame.title:SetFont("Fonts\\FRIZQT__.TTF", 18, "")
	frame.title:SetTextColor(1, 0.82, 0) -- Gold
	frame.title:SetShadowOffset(1, -1)
	frame.title:SetShadowColor(0, 0, 0, 1)
	frame.title:ClearAllPoints()
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 12)
	frame.title:SetText(title)

	-- Item name - subtle white text below
	frame.subtitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
	frame.subtitle:SetTextColor(0.9, 0.9, 0.9) -- Light gray/white
	frame.subtitle:SetShadowOffset(1, -1)
	frame.subtitle:SetShadowColor(0, 0, 0, 1)
	frame.subtitle:ClearAllPoints()
	frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -10)
	frame.subtitle:SetText(subtitle)

	frame:SetAlpha(0)
	frame:Show()
	UIFrameFadeIn(frame, 0.5, 0, 1)
	C_Timer.After(3, function()
		UIFrameFadeOut(frame, 0.5, 1, 0)
		C_Timer.After(0.5, function()
			frame:Hide()
		end)
	end)
end

AdventureGuideClassicEventToastManager:CreateToastFrame()
local levelUpFrame = CreateFrame("Frame")
levelUpFrame:RegisterEvent("PLAYER_LEVEL_UP")
levelUpFrame:SetScript("OnEvent", function(_, event, level)
	AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. level)
end)

-- Test functions for in-game testing (global scope)
-- These bypass settings checks so they always work for testing

-- Usage in chat: /run TestLevelUpToast()
_G.TestLevelUpToast = function()
	local playerLevel = UnitLevel("player")
	AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. playerLevel, true)
	print("Testing level-up toast for Level " .. playerLevel)
end

-- Usage in chat: /run TestBossDefeatedToast()
_G.TestBossDefeatedToast = function()
	AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast("Test Boss Name", "has been defeated!", true)
	print("Testing boss defeat toast")
end

-- Usage in chat: /run TestBossDefeatedToastCustom("Custom Boss Name")
_G.TestBossDefeatedToastCustom = function(bossName)
	bossName = bossName or "Test Boss"
	AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast(bossName, "has been defeated!", true)
	print("Testing boss defeat toast: " .. bossName)
end

-- Usage in chat: /run TestWishlistToast()
_G.TestWishlistToast = function()
	AdventureGuideClassicEventToastManager:ShowWishlistToast("Wishlist Item Found!", "Hearthstone", 6948, true)
	print("Testing wishlist toast")
end

-- Usage in chat: /run TestWishlistToastCustom(itemID)
_G.TestWishlistToastCustom = function(itemID)
	itemID = itemID or 6948
	local itemName = C_Item.GetItemInfo(itemID) or GetItemInfo(itemID) or "Unknown Item"
	AdventureGuideClassicEventToastManager:ShowWishlistToast("Wishlist Item Found!", itemName, itemID, true)
	print("Testing wishlist toast for item: " .. itemName)
end
