-- Builds ui/TalentWindow.lua against stubs and asserts that every global name
-- Blizzard's TalentFrame_Update resolves actually exists.
--
-- Run from the repo root:  lua ci/tests/talent_contract_test.lua
--
-- This is NOT a smoke test. It does not run the real renderer and it proves
-- nothing about how the window looks. It checks one thing: the naming
-- contract, which is invisible to both luacheck and to reading the file, and
-- which fails at runtime as a nil index rather than anything descriptive.
--
-- The case worth having it for is
-- <tree>ScrollFrameScrollBarScrollDownButton: TalentFrame_UpdateTalentPoints
-- looks it up unguarded, so a tree frame missing its ScrollFrame throws on
-- every single update. Deleting the ScrollFrame from TalentWindow.lua makes
-- this test fail, which is how it was checked for being vacuous.
--
-- The required-name list below is transcribed from
-- Blizzard_FrameXML/Vanilla/TalentFrameBase.lua. If that file changes, this
-- test goes stale silently -- it mirrors the contract, it does not read it.

local W = {}
W.__index = W
local function widget(name)
  local w = setmetatable({ _name = name, _id = 0, _shown = false, _scripts = {} }, W)
  if name then _G[name] = w end
  return w
end
local noop = function() end
for _, m in ipairs({"SetSize","SetPoint","SetAllPoints","SetJustifyH","SetTextColor",
  "SetText","SetFrameStrata","SetToplevel","EnableMouse","SetMovable","RegisterForDrag",
  "SetBackdrop","SetScrollChild","RegisterEvent","RegisterForClicks","SetVertexColor",
  "Show","Hide","StartMoving","StopMovingOrSizing","SetTexture","SetDesaturated",
  "SetFrameLevel","SetScale","SetWidth","SetHeight","ClearAllPoints","SetAlpha"}) do
  W[m] = noop
end
function W:SetScript(k, f) self._scripts[k] = f end
function W:GetScript(k) return self._scripts[k] end
function W:SetID(i) self._id = i end
function W:GetID() return self._id end
function W:IsShown() return self._shown end
function W:GetFrameLevel() return 1 end
function W:GetName() return self._name end
function W:CreateTexture(n, _, _) return widget(n) end
function W:CreateFontString(n) return widget(n) end

-- Templates register their own $parent children as globals; the stub has to
-- do the same or the contract check is meaningless.
local TEMPLATE_CHILDREN = {
  TalentButtonTemplate = { "Rank", "Slot", "RankBorder" },
  UIPanelScrollFrameTemplate = { "ScrollBar", "ScrollBarScrollUpButton", "ScrollBarScrollDownButton" },
  UIPanelCloseButton = {},
  BackdropTemplate = {},
}
function CreateFrame(_, name, _, template)
  local f = widget(name)
  if template and name then
    for _, suffix in ipairs(TEMPLATE_CHILDREN[template] or {}) do
      widget(name .. suffix)
    end
  end
  return f
end

MAX_TALENT_TABS, MAX_NUM_TALENTS = 3, 40
MAX_NUM_BRANCH_TEXTURES, MAX_NUM_ARROW_TEXTURES = 30, 30
UIParent, UISpecialFrames = widget("UIParent"), {}
GameTooltip = widget("GameTooltip")
InCombatLockdown = function() return false end
GetNumTalentTabs = function() return 3 end
C_SpecializationInfo = {
  GetActiveSpecGroup = function() return 1 end,
  GetSpecializationInfo = function(i) return i, "Spec"..i, "", "", "", "", 0, "MageFire", 0, true end,
  GetTalentInfo = function() return nil end,
}
TalentFrame_Update = noop
LearnTalent = noop
print_ = print

-- Stand in for the globalFacade: the file's first line is
-- select(2, ...).SetupGlobalFacade(), which setfenv's it into a table that
-- falls through to _G. Here the file just runs in _G directly.
local addonTable = { SetupGlobalFacade = function() end }
local chunk = assert(loadfile("ui/TalentWindow.lua"))
chunk("AdventureGuideClassic", addonTable)

TalentWindow.Toggle()

-- Now check what TalentFrame_Update would look up, per Blizzard's
-- TalentFrameBase.lua.
local missing, checked = {}, 0
for tree = 1, MAX_TALENT_TABS do
  local N = "AdventureGuideClassicTalentTree" .. tree
  local required = {
    N.."BackgroundTopLeft", N.."BackgroundTopRight",
    N.."BackgroundBottomLeft", N.."BackgroundBottomRight",
    N.."ScrollChildFrame", N.."ArrowFrame", N.."TalentPointsText",
    N.."ScrollFrameScrollBarScrollDownButton",
  }
  for i = 1, MAX_NUM_TALENTS do
    table.insert(required, N.."Talent"..i)
    table.insert(required, N.."Talent"..i.."Rank")
    table.insert(required, N.."Talent"..i.."Slot")
    table.insert(required, N.."Talent"..i.."RankBorder")
  end
  for i = 1, MAX_NUM_BRANCH_TEXTURES do table.insert(required, N.."Branch"..i) end
  for i = 1, MAX_NUM_ARROW_TEXTURES do table.insert(required, N.."Arrow"..i) end

  for _, name in ipairs(required) do
    checked = checked + 1
    if _G[name] == nil then table.insert(missing, name) end
  end
  -- selectedTab is the whole of PanelTemplates_GetSelectedTab
  if _G[N].selectedTab ~= tree then
    table.insert(missing, N..".selectedTab (got "..tostring(_G[N].selectedTab)..")")
  end
end

-- Talent buttons must carry their talent index as the frame ID.
local b = _G["AdventureGuideClassicTalentTree2Talent7"]
if b:GetID() ~= 7 then table.insert(missing, "Talent7:GetID() == "..b:GetID()) end

print(("contract: %d names checked across %d trees"):format(checked, MAX_TALENT_TABS))
if #missing == 0 then
  print("ALL PRESENT")
else
  print("MISSING (" .. #missing .. "):")
  for i = 1, math.min(#missing, 15) do print("   " .. missing[i]) end
  os.exit(1)
end
