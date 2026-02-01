-- Break Timer Lite - Options.lua
-- No chat options: this addon never sends group/raid chat messages.
-- Layout:
--  - Two columns so the panel doesn't run off-screen (no scrolling needed)

local ADDON, ns = ...
local PANEL_NAME = "Break Timer Lite"

local function GetDB()
  local d = (ns and ns.GetDB and ns.GetDB()) or BreakTimerDB
  if not d then
    BreakTimerDB = BreakTimerDB or {}
    d = BreakTimerDB
  end
  return d
end

local _categoryID

local function OpenBlizzOptionsToMe()
  if Settings and Settings.OpenToCategory and _categoryID then
    Settings.OpenToCategory(_categoryID)
  elseif InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(PANEL_NAME)
    InterfaceOptionsFrame_OpenToCategory(PANEL_NAME)
  end
end

ns.OpenOptions = OpenBlizzOptionsToMe

-- ------------------------------------------------------------
-- UI helpers
-- ------------------------------------------------------------
local function MakeTitle(parent, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  fs:SetPoint("TOPLEFT", 16, -16)
  fs:SetText(text)
  return fs
end

local function MakeSubText(parent, anchor, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
  fs:SetWidth(680)
  fs:SetJustifyH("LEFT")
  fs:SetText(text)
  return fs
end

local function MakeHeader(parent, anchor, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -14)
  fs:SetText(text)
  return fs
end

local function MakeCheck(name, parent, anchor, label, tooltip, getter, setter)
  local cb = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
  cb.Text:SetText(label)
  cb.tooltipText = tooltip

  cb:SetScript("OnShow", function(self) self:SetChecked(getter()) end)
  cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
  return cb
end

local function MakeSlider(name, parent, anchor, label, tooltip, minv, maxv, step, getter, setter, width)
  local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -22)
  s:SetWidth(width or 300)
  s:SetMinMaxValues(minv, maxv)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  s.tooltipText = tooltip

  local n = s:GetName()
  _G[n .. "Text"]:SetText(label)
  _G[n .. "Low"]:SetText(tostring(minv))
  _G[n .. "High"]:SetText(tostring(maxv))

  s:SetScript("OnShow", function(self)
    local v = getter()
    if v == nil then v = minv end
    self:SetValue(v)
  end)

  s:SetScript("OnValueChanged", function(self, value)
    value = math.floor((value / step) + 0.5) * step
    setter(value)
  end)

  return s
end

-- ------------------------------------------------------------
-- Panel + columns
-- ------------------------------------------------------------
local panel = CreateFrame("Frame", "BreakTimerLiteOptionsPanel", UIParent)
panel.name = PANEL_NAME

local title = MakeTitle(panel, PANEL_NAME)
local sub = MakeSubText(panel, title,
  "Synced break timer replacement.\n" ..
  "• Only leader/raid assist can start/extend/stop while grouped.\n" ..
  "• This addon sends NO group/raid chat messages.\n" ..
  "Tip: Hold ALT and drag the bar or big timer to reposition."
)

-- Column anchors
local LEFT_X = 16
local RIGHT_X = 380
local COL_TOP_Y = -110

local colLeft = CreateFrame("Frame", nil, panel)
colLeft:SetPoint("TOPLEFT", panel, "TOPLEFT", LEFT_X, COL_TOP_Y)
colLeft:SetSize(340, 520)

local colRight = CreateFrame("Frame", nil, panel)
colRight:SetPoint("TOPLEFT", panel, "TOPLEFT", RIGHT_X, COL_TOP_Y)
colRight:SetSize(340, 520)

-- ------------------------------------------------------------
-- LEFT column: General + Bar
-- ------------------------------------------------------------
local headerGeneral = colLeft:CreateFontString(nil, "ARTWORK", "GameFontNormal")
headerGeneral:SetPoint("TOPLEFT", 0, 0)
headerGeneral:SetText("General")

local cbRaidWarn = MakeCheck("BreakTimerLiteOptRaidWarn", colLeft, headerGeneral,
  "Show local Raid Warning messages",
  "Shows messages in the Raid Warning frame on your screen (local only; not chat).",
  function() return GetDB().raidWarning end,
  function(v) GetDB().raidWarning = v end
)

local cbSound = MakeCheck("BreakTimerLiteOptSound", colLeft, cbRaidWarn,
  "Enable warning sounds",
  "Plays warning sounds at 10 seconds remaining and when the timer ends.",
  function() return GetDB().sound end,
  function(v) GetDB().sound = v end
)

local cbBeeps = MakeCheck("BreakTimerLiteOptBeeps", colLeft, cbSound,
  "Enable short beeps",
  "Plays short beeps at 3 and 1 seconds remaining.",
  function() return GetDB().beeps end,
  function(v) GetDB().beeps = v end
)

local cbReady = MakeCheck("BreakTimerLiteOptReady", colLeft, cbBeeps,
  "Ready check when break ends (leader/assist only)",
  "Starts a ready check when the break ends (requires leader/assist).",
  function() return GetDB().readyCheckOnEnd end,
  function(v) GetDB().readyCheckOnEnd = v end
)

local headerBar = MakeHeader(colLeft, cbReady, "Timer Bar")

local sWidth = MakeSlider("BreakTimerLiteOptWidth", colLeft, headerBar,
  "Bar width",
  "Adjust the timer bar width.",
  180, 520, 10,
  function() return GetDB().width end,
  function(v)
    GetDB().width = v
    if ns.SetBarSize then ns.SetBarSize() end
  end,
  300
)

local sHeight = MakeSlider("BreakTimerLiteOptHeight", colLeft, sWidth,
  "Bar height",
  "Adjust the timer bar height.",
  14, 40, 1,
  function() return GetDB().height end,
  function(v)
    GetDB().height = v
    if ns.SetBarSize then ns.SetBarSize() end
  end,
  300
)

local cbEdgePulse = MakeCheck("BreakTimerLiteOptEdgePulse", colLeft, sHeight,
  "Screen-edge pulse during last 10 seconds",
  "Shows a subtle red pulse at screen edges during the last 10 seconds.",
  function() return GetDB().edgePulse end,
  function(v) GetDB().edgePulse = v end
)

-- ------------------------------------------------------------
-- RIGHT column: Big + Banners + Defaults
-- ------------------------------------------------------------
local headerBig = colRight:CreateFontString(nil, "ARTWORK", "GameFontNormal")
headerBig:SetPoint("TOPLEFT", 0, 0)
headerBig:SetText("Big Countdown")

local cbBigEnabled = MakeCheck("BreakTimerLiteOptBigEnabled", colRight, headerBig,
  "Enable big countdown",
  "Shows a large countdown timer near the center of your screen.",
  function() return GetDB().big.enabled end,
  function(v) GetDB().big.enabled = v end
)

local sBigScale = MakeSlider("BreakTimerLiteOptBigScale", colRight, cbBigEnabled,
  "Big countdown scale",
  "Adjust the size of the big countdown.",
  1.0, 2.5, 0.1,
  function() return GetDB().big.scale end,
  function(v)
    GetDB().big.scale = v
    if ns.SetBigScale then ns.SetBigScale() end
  end,
  300
)

local cbBigPulse = MakeCheck("BreakTimerLiteOptBigPulse", colRight, sBigScale,
  "Pulse during last 10 seconds",
  "Adds a subtle pulse effect during the last 10 seconds.",
  function() return GetDB().big.pulseLast10 end,
  function(v) GetDB().big.pulseLast10 = v end
)

local cbBigShake = MakeCheck("BreakTimerLiteOptBigShake", colRight, cbBigPulse,
  "Shake during last 5 seconds",
  "Adds a subtle shake effect during the last 5 seconds.",
  function() return GetDB().big.shakeLast5 end,
  function(v) GetDB().big.shakeLast5 = v end
)

local cbBigFlash = MakeCheck("BreakTimerLiteOptBigFlash", colRight, cbBigShake,
  "Flash during last 5 seconds",
  "Adds a subtle flash effect during the last 5 seconds.",
  function() return GetDB().big.flashLast5 end,
  function(v) GetDB().big.flashLast5 = v end
)

local headerBanner = MakeHeader(colRight, cbBigFlash, "Banners")

local cbBanner = MakeCheck("BreakTimerLiteOptBanner", colRight, headerBanner,
  "Enable banners",
  "Shows large banners on start/extend/end/cancel (local only).",
  function() return GetDB().banner.enabled end,
  function(v) GetDB().banner.enabled = v end
)

local headerDefaults = MakeHeader(colRight, cbBanner, "Defaults")

local sDefault = MakeSlider("BreakTimerLiteOptDefaultMin", colRight, headerDefaults,
  "Default /break minutes",
  "When you type /break with no arguments, this is the default duration (in minutes).",
  1, 30, 1,
  function() return tonumber(GetDB().defaultMinutes) or 5 end,
  function(v) GetDB().defaultMinutes = v end,
  300
)

-- Refresh on show
panel:SetScript("OnShow", function()
  cbRaidWarn:GetScript("OnShow")(cbRaidWarn)
  cbSound:GetScript("OnShow")(cbSound)
  cbBeeps:GetScript("OnShow")(cbBeeps)
  cbReady:GetScript("OnShow")(cbReady)
  sWidth:GetScript("OnShow")(sWidth)
  sHeight:GetScript("OnShow")(sHeight)
  cbEdgePulse:GetScript("OnShow")(cbEdgePulse)

  cbBigEnabled:GetScript("OnShow")(cbBigEnabled)
  sBigScale:GetScript("OnShow")(sBigScale)
  cbBigPulse:GetScript("OnShow")(cbBigPulse)
  cbBigShake:GetScript("OnShow")(cbBigShake)
  cbBigFlash:GetScript("OnShow")(cbBigFlash)

  cbBanner:GetScript("OnShow")(cbBanner)
  sDefault:GetScript("OnShow")(sDefault)
end)

-- Register in modern Settings (preferred) or legacy Interface Options
if Settings and Settings.RegisterCanvasLayoutCategory then
  local category = Settings.RegisterCanvasLayoutCategory(panel, PANEL_NAME)
  Settings.RegisterAddOnCategory(category)

  if category and category.GetID then
    _categoryID = category:GetID()
  elseif category and category.ID then
    _categoryID = category.ID
  end
else
  InterfaceOptions_AddCategory(panel)
end
