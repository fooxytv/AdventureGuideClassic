select(2, ...).SetupGlobalFacade()

AdventureGuideClassicEventToastManager = AdventureGuideClassicEventToastManager or {}

function AdventureGuideClassicEventToastManager:CreateToastFrame()
    if self.frame then return end
    local frame = CreateFrame("Frame", "EventToastFrame", UIParent)
    frame:SetSize(400, 80)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -120)
    frame:Hide()
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetSize(400, 80)
    frame.background:SetTexture(I.EventToastBossBannerBG)
    frame.background:SetPoint("CENTER", frame, "CENTER", 0, 11)
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
    frame.title = frame:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
    frame.title:SetPoint("CENTER", frame, "CENTER", 0, 11)
    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -35)
    self.frame = frame
end

function AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast(title, subtitle)
    if not self.frame then
        self:CreateToastFrame()
    end
    delay = delay or 0
    C_Timer.After(delay, function()
        local frame = self.frame
        frame.instanceBanner:Hide()
        frame.instanceBannerBottom:Hide()
        frame.bossDefeatBanner:Show()
        frame.bossDefeatBannerBottom:Show()
        frame.title:SetFontObject("Fancy22Font")
        frame.title:SetTextColor(0.8, 0.1, 0.1)
        frame.title:SetShadowOffset(1, -1)
        frame.title:SetShadowColor(0, 0, 0, 0.8)
        frame.title:SetText(title)
        frame.subtitle:SetTextColor(0.8, 0.1, 0.1)
        frame.subtitle:SetShadowOffset(1, -1)
        frame.subtitle:SetShadowColor(0, 0, 0, 0.8)
        frame.subtitle:SetText(subtitle)
        frame:SetAlpha(0)
        frame:Show()
        UIFrameFadeIn(frame, 1, 0, 1)
        -- C_Timer.After(3, function()
        --     UIFrameFadeOut(frame, 1, 1, 0)
        --     C_Timer.After(1, function()
        --         frame:Hide()
        --     end)
        -- end)
    end)
end

function AdventureGuideClassicEventToastManager:ShowInstanceToast(title, subtitle)
    if not self.frame then
        self:CreateToastFrame()
    end

    local frame = self.frame

    -- Hide unused banners
    frame.bossDefeatBanner:Hide()
    frame.bossDefeatBannerBottom:Hide()
    frame.instanceBanner:Hide()
    frame.instanceBannerBottom:Hide()
    frame.topBanner:Hide()
    frame.bottomBanner:Hide()

    -- Reset and reapply background
    if frame.background then frame.background:Hide() end
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetSize(400, 120)
    frame.background:SetTexture(I.EventToastBossBannerBG)
    frame.background:SetPoint("CENTER", frame, "CENTER", 0, -300)
    frame.background:SetAlpha(0.5)

    -- "You've Reached"
    frame.title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    frame.title:SetTextColor(1, 1, 1)
    frame.title:SetShadowOffset(1, -1)
    frame.title:SetShadowColor(0, 0, 0, 1)
    frame.title:ClearAllPoints()
    frame.title:SetPoint("CENTER", frame, "CENTER", 0, -280)
    frame.title:SetText(title)

    -- "Level X"
    frame.subtitle:SetFont("Fonts\\FRIZQT__.TTF", 24)
    frame.subtitle:SetTextColor(1, 0.82, 0)
    frame.subtitle:SetShadowOffset(1, -1)
    frame.subtitle:SetShadowColor(0, 0, 0, 1)
    frame.subtitle:ClearAllPoints()
    frame.subtitle:SetPoint("CENTER", frame, "CENTER", 0, -310)
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




AdventureGuideClassicEventToastManager:CreateToastFrame()
local levelUpFrame = CreateFrame("Frame")
levelUpFrame:RegisterEvent("PLAYER_LEVEL_UP")
levelUpFrame:SetScript("OnEvent", function(_, event, level)
    AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. level)
end)

-- local eventFrame = CreateFrame("Frame")
-- eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- eventFrame:SetScript("OnEvent", function(self, event, ...)
--     local playerLevel = UnitLevel("player")

--     -- AdventureGuideClassicEventToastManager:ShowEncounterDefeatedToast("The Longest Dungeon Name in the World", "You got to defeat 'em all!")
--     AdventureGuideClassicEventToastManager:ShowInstanceToast("You've Reached", "Level " .. playerLevel)
-- end)
