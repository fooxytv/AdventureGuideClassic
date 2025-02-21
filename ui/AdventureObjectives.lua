select(2, ...).SetupGlobalFacade()

AdventureObjectives = AdventureObjectives or {}

function AdventureObjectives:CreateFrame(dungeonName)
    self.frame = CreateFrame("Frame", "AdventureObjectivesFrame", UIParent, "BackdropTemplate")
    self.frame:SetSize(300, 250)
    self.frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -70, -360)
    self.frame:SetBackdrop({
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.frame:SetClampedToScreen(true)
    self.headerTitleFrame = CreateFrame("Frame", "AdventureHeaderTitleFrame", self.frame, "BackdropTemplate")
    self.headerTitleFrame:SetSize(280, 30)
    self.headerTitleFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    self.headerTitleFrame:SetBackdrop({
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    self.headerTitleFrame:SetBackdropColor(0, 0, 0, 1)
    self.headerTitleFrame.text = self.headerTitleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.headerTitleFrame.text:SetPoint("LEFT", self.headerTitleFrame, "LEFT", 10, 0)
    self.headerTitleFrame.text:SetText("Dungeon")
    self.instanceTitleFrame = CreateFrame("Frame", "AdventureInstanceTitleFrame", self.frame, "BackdropTemplate")
    self.instanceTitleFrame:SetSize(280, 90)
    self.instanceTitleFrame:SetPoint("TOP", self.headerTitleFrame, "BOTTOM", 0, -5)
    self.instanceTitleFrame:SetBackdrop({
        bgFile = "Interface\\Glues\\Common\\Glue-Tooltip-Background",
        edgeFile = "Interface\\Glues\\Common\\Glue-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 10, right = 5, top = 4, bottom = 9 },
    })
    self.instanceTitleFrame:SetBackdropColor(0.09, 0.09, 0.09, 1.0) -- Dark background
    self.instanceTitleFrame:SetBackdropBorderColor(1.0, 0.84, 0) -- Gold border
    self.instanceTitleFrame.text = self.instanceTitleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.instanceTitleFrame.text:SetPoint("LEFT", self.instanceTitleFrame, "LEFT", 20, 0)
    self.instanceTitleFrame.text:SetTextColor(1.0, 1.0, 0.6)
    self.instanceTitleFrame.text:SetWidth(240)
    self.instanceTitleFrame.text:SetWordWrap(true)
    self.instanceTitleFrame.text:SetJustifyH("LEFT")
    self.instanceTitleFrame.text:SetText(dungeonName)
    self.instanceTitleFrame:EnableMouse(true)
    self.instanceTitleFrame:SetScript("OnMouseDown", function ()
        if self.isCollapsed then
            self:ExpandEncounters()
        else
            self:CollapseEncounters()
        end
    end)
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
    end)
end

function AdventureObjectives:CollapseEncounters()
    if not self.encounterFrames then return end
    for _, frame in ipairs(self.encounterFrames) do
        frame:Hide()
    end
    self.isCollapsed = true
end

function AdventureObjectives:ExpandEncounters()
    if not self.encounterFrames then return end
    for _, frame in ipairs(self.encounterFrames) do
        frame:Show()
    end
    self.isCollapsed = false
end

function AdventureObjectives:CreateEncounterHeader(index, encounterData)
    local encounterName = encounterData.name
    local defeated = encounterData.defeated
    local encounterFrame = CreateFrame("Frame", "AdventureEncounterFrame"..index, self.frame, "BackdropTemplate")
    encounterFrame:SetSize(280, 25)
    encounterFrame:SetPoint("TOP", self.lastEncounterFrame or self.instanceTitleFrame, "BOTTOM", 0, -5)
    encounterFrame:SetBackdrop({
        tile = true,
        tileEdge = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 10, right = 5, top = 4, bottom = 9 },
    })
    encounterFrame:SetBackdropColor(0.09, 0.09, 0.09, 1.0) -- Dark background
    encounterFrame:SetBackdropBorderColor(1.0, 0.84, 0) -- Gold border
    encounterFrame.bullet = encounterFrame:CreateTexture(nil, "OVERLAY")
    encounterFrame.bullet:SetTexture("Interface\\COMMON\\Indicator-Yellow")
    encounterFrame.bullet:SetSize(16, 16)
    encounterFrame.bullet:SetPoint("LEFT", encounterFrame, "LEFT", 10, 0)
    encounterFrame.text = encounterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    encounterFrame.text:SetPoint("LEFT", encounterFrame.bullet, "RIGHT", 10, 0)
    encounterFrame.text:SetText(encounterName)
    encounterFrame.tick = encounterFrame:CreateTexture(nil, "OVERLAY")
    encounterFrame.tick:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
    encounterFrame.tick:SetSize(16, 16)
    encounterFrame.tick:SetPoint("LEFT", encounterFrame, "LEFT", 10, 0)
    encounterFrame.tick:Hide()
    if defeated == 1 then
        encounterFrame.bullet:Hide()
        encounterFrame.tick:Show()
        encounterFrame.text:SetAlpha(0.5)
    else
        encounterFrame.bullet:Show()
        encounterFrame.tick:Hide()
        encounterFrame.text:SetAlpha(1.0)
    end
    self.lastEncounterFrame = encounterFrame
    return encounterFrame
end

function AdventureObjectives:LoadEncounters(dungeonName, updatedEncounters)
    if self.encounterFrames then
        for _, frame in ipairs(self.encounterFrames) do
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    local encounters = updatedEncounters
    if not encounters then
        local dungeons = ObjectiveService.GetDungeons()
        for _, dungeon in ipairs(dungeons) do
            if dungeon.name == dungeonName then
                encounters = dungeon.encounters
                break
            end
        end
    end
    if not encounters then
        return
    end
    self.lastEncounterFrame = self.instanceTitleFrame
    self.encounterFrames = {}
    for i, encounterData in ipairs(encounters) do
        local frame = self:CreateEncounterHeader(i, encounterData)
        table.insert(self.encounterFrames, frame)
    end
end

function AdventureObjectives:UpdateVisibility()
    local inInstance = IsInInstance()
    if inInstance then
        local dungeonName = GetInstanceInfo()
        if not self.frame then
            self:CreateFrame(dungeonName)
        end
        self:LoadEncounters(dungeonName)
        self.frame:Show()
    else
        if self.frame then
            self.frame:Hide()
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "ZONE_CHANGED_NEW_AREA" then
        AdventureObjectives:UpdateVisibility()
    end
end)