select(2, ...).SetupGlobalFacade()

_G.DungeonMap = DungeonMap or {}
_G.MapNavBar = MapNavBar or {}
local DungeonLayerDropdownMenu = nil

local function GetInstanceNameFromNavBar()
    local navBar = DungeonMapFrame.navBar
    if not navBar or not navBar.navList then return nil end
    local lastButton = navBar.navList[#navBar.navList]
    if lastButton and lastButton:GetText() then
        return lastButton:GetText()
    end
    return nil
end

function MapNavBar.Init(parentFrame)
    if parentFrame.navBar then return end
    local navBar = CreateFrame("Frame", parentFrame:GetName() .. "NavBar", parentFrame, "NavBarTemplate")
    parentFrame.navBar = navBar
    navBar:SetSize(650, 34)
    navBar:SetPoint("TOPLEFT", 61, -22)
    local insetBotLeftCorner = navBar:CreateTexture(nil, "BORDER", "UI-Frame-InnerBotLeftCorner")
    insetBotLeftCorner:ClearAllPoints()
    insetBotLeftCorner:SetPoint("BOTTOMLEFT", -3, -3)
    local insetBotRightCorner = navBar:CreateTexture(nil, "BORDER", "UI-Frame-InnerBotRight")
    insetBotRightCorner:ClearAllPoints()
    insetBotRightCorner:SetPoint("BOTTOMRIGHT", 3, -3)
    local insetBottomBorder = navBar:CreateTexture(nil, "BORDER", "_UI-Frame-InnerBotTile")
    insetBottomBorder:ClearAllPoints()
    insetBottomBorder:SetPoint("BOTTOMLEFT", insetBotLeftCorner, "BOTTOMRIGHT")
    insetBottomBorder:SetPoint("BOTTOMRIGHT", insetBotRightCorner, "BOTTOMLEFT")
    local insetLeftBorder = navBar:CreateTexture(nil, "BORDER", "!UI-Frame-InnerLeftTile")
    insetLeftBorder:ClearAllPoints()
    insetLeftBorder:SetPoint("TOPLEFT", -3, 0)
    insetLeftBorder:SetPoint("BOTTOMLEFT", insetBotLeftCorner, "TOPLEFT")
    local insetRightBorder = navBar:CreateTexture(nil, "BORDER", "!UI-Frame-InnerRightTile")
    insetRightBorder:ClearAllPoints()
    insetRightBorder:SetPoint("TOPRIGHT", 3, 0)
    insetRightBorder:SetPoint("BOTTOMRIGHT", insetBotRightCorner, "TOPRIGHT")
    navBar.home = CreateFrame("Button", navBar:GetName() .. "Button1", navBar, "NavButtonTemplate")
    local homeData = {
        name = "Home",
        OnClick = function()
        end,
    }
    NavBar_Initialize(navBar, "NavButtonTemplate", homeData, navBar.home, navBar.overflow)
end

local function LayerDropdown_OnClick(self)
    local selectedLayerIndex = tonumber(self.value)
    local instanceName = GetInstanceNameFromNavBar()
    local dungeonMap = DungeonMapService.GetDungeonMapByInstanceName(instanceName)
    if dungeonMap and type(dungeonMap.layers) == "table" then
        local selectedLayer = dungeonMap.layers[selectedLayerIndex]
        if not selectedLayer then
            return
        end
        local selectedMapID = rawget(selectedLayer, "mapID") or selectedLayer.mapID
        if not selectedMapID then
            return
        end
        DungeonMapFrame.selectedLayer = selectedLayerIndex
        DungeonMap:LoadTiledMap(selectedMapID)
        UIDropDownMenu_SetSelectedValue(DungeonLayerDropdownMenu, self.value)
        UIDropDownMenu_SetText(DungeonLayerDropdownMenu, selectedLayer.title)
    else
        print("ERROR: No valid layers found for instanceName ->", instanceName)
    end
end

local function InitializeLayerDropdown(self, level)
    if not level then return end
    local instanceName = GetInstanceNameFromNavBar()
    if not instanceName then return end
    local dungeonMap = DungeonMapService.GetDungeonMapByInstanceName(instanceName)
    if dungeonMap and dungeonMap.layers then
        for layerIndex, layerInfo in ipairs(dungeonMap.layers) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = layerInfo.title ~= "" and layerInfo.title or "Layer " .. layerIndex
            info.value = layerIndex
            info.func = LayerDropdown_OnClick
            -- info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
        end
    else
        print("Error: No layers found for dungeon: " .. instanceName)
    end
end

local function CreateDropdownMenu(parent)
    local dropdown = CreateFrame("Frame", "DungeonLayerDropdownMenu", parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent.navBar, "BOTTOMLEFT", -70, -5)
    dropdown:SetFrameLevel(50)
    dropdown:SetFrameStrata("HIGH")
    UIDropDownMenu_SetWidth(dropdown, 140)
    local function SetDefaultLayer()
        local instanceName = GetInstanceNameFromNavBar()
        local dungeonMap = DungeonMapService.GetDungeonMapByInstanceName(instanceName)
        if dungeonMap and dungeonMap.layers and #dungeonMap.layers > 0 then
            local firstLayer = dungeonMap.layers[1]
            DungeonMapFrame.selectedLayer = 1
            UIDropDownMenu_SetText(dropdown, firstLayer.title)
        else
            UIDropDownMenu_SetText(dropdown, "No Layers Available")
        end
    end
    UIDropDownMenu_Initialize(dropdown, InitializeLayerDropdown)
    dropdown:SetScript("OnShow", function(self)
        SetDefaultLayer()
    end)
    return dropdown
end

function DungeonMap:CreateDungeonMapFrame()
    if DungeonMapFrame then return end
    DungeonMapFrame = CreateFrame("Frame", "DungeonMapFrame", UIParent, "PortraitFrameTemplate")
    DungeonMapFrame:SetSize(720, 540)
    DungeonMapFrame:EnableMouse(true)
    DungeonMapFrame:SetToplevel(true)
    DungeonMapFrame.title = _G["DungeonMapFrameTitleText"]
    DungeonMapFrame.title:SetText("Dungeon Map")
    DungeonMapFrame.portrait = _G["DungeonMapFramePortrait"]
    DungeonMapFrame.portrait:SetTexture("Interface\\EncounterJournal\\UI-EJ-PortraitIcon")
    local mask = DungeonMapFrame:CreateMaskTexture()
    mask:SetAllPoints(DungeonMapFrame.portrait)
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    if SavedVariables.DungeonMapLocation then
        DungeonMapFrame:ClearAllPoints()
        DungeonMapFrame:SetPoint(unpack(SavedVariables.DungeonMapLocation))
    else
        DungeonMapFrame:SetPoint("CENTER")
    end
    DungeonMapFrame:RegisterForDrag("LeftButton")
    DungeonMapFrame:SetClampedToScreen(true)
    DungeonMapFrame:SetScript("OnDragStart", function(self)
        self:SetMovable(true)
        if not self.isLocked then
            self:StartMoving()
        end
    end)
    DungeonMapFrame:SetScript("OnDragStop", function(self)
        self:SetMovable(false)
        self:StopMovingOrSizing()
        SavedVariables.DungeonMapLocation = { self:GetPoint() }
    end)
    DungeonMapFrame:SetScript("OnShow", function()
        PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
    end)
    DungeonMapFrame:SetScript("OnHide", function()
        PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
    end)
    DungeonMapFrame.mapContainer = CreateFrame("Frame", "DungeonMapContainer", DungeonMapFrame, "BackdropTemplate")
    DungeonMapFrame.mapContainer:SetSize(720, 540)
    DungeonMapFrame.mapContainer:SetPoint("TOP", DungeonMapFrame, "TOP", 0, -80)
    DungeonMapFrame.playerMarker = DungeonMapFrame.mapContainer:CreateTexture(nil, "OVERLAY")
    DungeonMapFrame.playerMarker:SetSize(24, 24)
    DungeonMapFrame.playerMarker:SetTexture("Interface\\Minimap\\WorldmapArrow")
    DungeonMapFrame.playerMarker:SetDrawLayer("OVERLAY", 7)
    DungeonMapFrame.playerMarker:Show()
    DungeonMapFrame.inset = CreateFrame("Frame", "DungeonMapInset", DungeonMapFrame, "InsetFrameTemplate")
    DungeonMapFrame.inset:SetPoint("TOPRIGHT", -4, -60)
    DungeonMapFrame.inset:SetPoint("BOTTOMLEFT", 4, 5)
    MapNavBar.Init(DungeonMapFrame)
    DungeonLayerDropdownMenu = CreateDropdownMenu(DungeonMapFrame)
    DungeonMapFrame:SetShown(false)
    table.insert(UISpecialFrames, DungeonMapFrame:GetName())
end

function DungeonMap:LoadTiledMap(mapID)
    local maps = DungeonMapService.GetAllDungeonMaps()
    for _, mapData in ipairs(maps) do
        if type(mapData.layers) == "table" then
            for _, layer in ipairs(mapData.layers) do
                if layer.mapID == mapID then
                    local selectedLayer = layer
                    local texturePath = selectedLayer.texturePath
                    local originalTileSize = 256
                    local totalWidth = mapData.cols * originalTileSize
                    local totalHeight = mapData.rows * originalTileSize
                    local availableWidth = DungeonMapFrame:GetWidth()
                    local availableHeight = DungeonMapFrame:GetHeight()
                    local scaleFactor = math.min(availableWidth / totalWidth, availableHeight / totalHeight)
                    local tileSize = originalTileSize * scaleFactor
                    local scaledWidth = mapData.cols * tileSize
                    local scaledHeight = mapData.rows * tileSize
                    if DungeonMapFrame.mapContainer.tiles then
                        for _, tile in ipairs(DungeonMapFrame.mapContainer.tiles) do
                            tile:SetTexture(nil)
                            tile:Hide()
                        end
                    else
                        DungeonMapFrame.mapContainer.tiles = {}
                    end
                    DungeonMapFrame.mapContainer:SetSize(scaledWidth, scaledHeight)
                    DungeonMapFrame.mapContainer:ClearAllPoints()
                    DungeonMapFrame.mapContainer:SetPoint("TOPLEFT", DungeonMapFrame, "TOPLEFT", 10, -64)
                    for row = 1, mapData.rows do
                        for col = 1, mapData.cols do
                            local tileIndex = ((row - 1) * mapData.cols) + col
                            local tileTexture = DungeonMapFrame.mapContainer.tiles[tileIndex]
                            if not tileTexture then
                                tileTexture = DungeonMapFrame.mapContainer:CreateTexture(nil, "ARTWORK")
                                DungeonMapFrame.mapContainer.tiles[tileIndex] = tileTexture
                            end
                            tileTexture:SetSize(tileSize, tileSize)
                            tileTexture:SetPoint("TOPLEFT", DungeonMapFrame.mapContainer, "TOPLEFT", (col - 1) * tileSize, -((row - 1) * tileSize))
                            tileTexture:SetTexture(texturePath .. tileIndex)
                            tileTexture:SetDrawLayer("ARTWORK", 2)
                            tileTexture:Show()
                        end
                    end
                    DungeonMapFrame.playerMarker:ClearAllPoints()
                    DungeonMapFrame.playerMarker:SetPoint("CENTER", DungeonMapFrame.mapContainer, "CENTER", mapData.defaultX * totalWidth, -mapData.defaultY * totalHeight)
                    DungeonMap:RenderBossMarkers(mapID, scaledWidth, scaledHeight)
                    return
                end
            end
        else
            print("ERROR: No layers found for map ->", mapData.instanceName)
        end
    end
    print("ERROR: No valid map found for MapID ->", mapID)
end

local SKULL_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
local MARKER_SIZE = 22

local function CreateBossMarker(parent)
    local marker = CreateFrame("Button", nil, parent)
    marker:SetSize(MARKER_SIZE, MARKER_SIZE)
    marker.icon = marker:CreateTexture(nil, "OVERLAY")
    marker.icon:SetTexture(SKULL_TEXTURE)
    marker.icon:SetAllPoints()
    marker:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.bossName, 1, 1, 1)
        if self.bossLevel then
            GameTooltip:AddLine("Level " .. tostring(self.bossLevel), 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    marker:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return marker
end

function DungeonMap:RenderBossMarkers(mapID, scaledWidth, scaledHeight)
    local container = DungeonMapFrame.mapContainer
    container.bossMarkers = container.bossMarkers or {}
    for _, m in ipairs(container.bossMarkers) do m:Hide() end
    local instanceName = DungeonMapFrame.currentDungeon
    if not instanceName or not InstanceService.GetInstanceByName then return end
    local instance = InstanceService.GetInstanceByName(instanceName)
    if not instance then return end
    local visibleIndex = 0
    for _, boss in ipairs(instance) do
        local pos = boss.mapPosition
        if pos and pos.mapID == mapID then
            visibleIndex = visibleIndex + 1
            local marker = container.bossMarkers[visibleIndex]
            if not marker then
                marker = CreateBossMarker(container)
                container.bossMarkers[visibleIndex] = marker
            end
            marker.bossName = boss.name
            marker.bossLevel = boss.level
            marker:ClearAllPoints()
            marker:SetPoint("CENTER", container, "TOPLEFT", pos.x * scaledWidth, -pos.y * scaledHeight)
            marker:SetFrameLevel(container:GetFrameLevel() + 5)
            marker:Show()
        end
    end
end

function MapNavBar.SetDungeonInfo(instanceName, location)
    local navBar = DungeonMapFrame.navBar
    if not navBar then return end
    NavBar_Reset(navBar)
    DungeonMapFrame.currentDungeon = instanceName
    UIDropDownMenu_SetText(DungeonLayerDropdownMenu)
    NavBar_AddButton(navBar, { name = location })
    NavBar_AddButton(navBar, { name = instanceName })
end

return DungeonMap