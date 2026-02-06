-- Options.lua
-- Break Timer Lite - Options.lua
-- Layout:
--  - Two columns (no scrolling)
--  - ALL SLIDERS are on the LEFT column (prevents slider going out of bounds)
--  - Pull timer options included

local ADDON, ns = ...
local PANEL_NAME = "Break Timer Lite"

local function GetDB()
  local d = (ns and ns.GetDB and ns.GetDB()) or BreakTimerDB
  if not d then
    BreakTimerDB = BreakTimerDB or {}
    d = BreakTimerDB
  end
  -- ensure tables (in case Options loads early)
  d.big = d.big or {}
  d.banner = d.banner or {}
  d.pull = d.pull or {}
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
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
  fs:SetText(text)
  return fs
end

local function MakeCheck(name, parent, anchor, label, tooltip, getter, setter)
  local cb = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
  cb.Text:SetText(label)
  cb.tooltipText = tooltip

  cb:SetScript("OnShow", function(self) self:SetChecked(getter() and true or false) end)
  cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
  return cb
end

local function MakeSlider(name, parent, anchor, label, tooltip, minv, maxv, step, getter, setter, width)
  local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -20)
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
  "• /pull starts a pull countdown (big on-screen numbers + sounds).\n" ..
  "Tip: Hold ALT and drag the bar, big timer, or pull numbers to reposition."
)

-- Column anchors
local LEFT_X  = 16
local RIGHT_X = 360
local COL_TOP_Y = -120

local colLeft = CreateFrame("Frame", nil, panel)
colLeft:SetPoint("TOPLEFT", panel, "TOPLEFT", LEFT_X, COL_TOP_Y)
colLeft:SetSize(330, 520)

local colRight = CreateFrame("Frame", nil, panel)
colRight:SetPoint("TOPLEFT", panel, "TOPLEFT", RIGHT_X, COL_TOP_Y)
colRight:SetSize(330, 520)

-- ------------------------------------------------------------
-- LEFT column: Sliders (always)
-- ------------------------------------------------------------
local headerBar = colLeft:CreateFontString(nil, "ARTWORK", "GameFontNormal")
headerBar:SetPoint("TOPLEFT", 0, 0)
headerBar:SetText("Timer Bar")

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

local headerBigScale = MakeHeader(colLeft, sHeight, "Big Break Countdown")

local sBigScale = MakeSlider("BreakTimerLiteOptBigScale", colLeft, headerBigScale,
  "Big countdown scale",
  "Adjust the size of the big break countdown.",
  1.0, 2.5, 0.1,
  function() return GetDB().big.scale end,
  function(v)
    GetDB().big.scale = v
    if ns.SetBigScale then ns.SetBigScale() end
  end,
  300
)

local headerPull = MakeHeader(colLeft, sBigScale, "Pull Timer")

local sPullScale = MakeSlider("BreakTimerLiteOptPullScale", colLeft, headerPull,
  "Pull number scale",
  "Adjust the size of the pull countdown numbers.",
  1.5, 5.0, 0.1,
  function() return GetDB().pull.scale end,
  function(v)
    GetDB().pull.scale = v
    if ns.SetPullScale then ns.SetPullScale() end
  end,
  300
)

local sPullDefault = MakeSlider("BreakTimerLiteOptPullDefault", colLeft, sPullScale,
  "Default /pull seconds",
  "When you type /pull with no arguments, this is the default duration (in seconds).",
  5, 30, 1,
  function() return tonumber(GetDB().pull.defaultSeconds) or 10 end,
  function(v) GetDB().pull.defaultSeconds = v end,
  300
)

local headerDefaults = MakeHeader(colLeft, sPullDefault, "Defaults")

local sDefault = MakeSlider("BreakTimerLiteOptDefaultMin", colLeft, headerDefaults,
  "Default /break minutes",
  "When you type /break with no arguments, this is the default duration (in minutes).",
  1, 30, 1,
  function() return tonumber(GetDB().defaultMinutes) or 5 end,
  function(v) GetDB().defaultMinutes = v end,
  300
)

-- ------------------------------------------------------------
-- RIGHT column: Checkboxes
-- ------------------------------------------------------------
local headerGeneral = colRight:CreateFontString(nil, "ARTWORK", "GameFontNormal")
headerGeneral:SetPoint("TOPLEFT", 0, 0)
headerGeneral:SetText("General")

local cbRaidWarn = MakeCheck("BreakTimerLiteOptRaidWarn", colRight, headerGeneral,
  "Show local Raid Warning messages",
  "Shows messages in the Raid Warning frame on your screen (local only; not chat).",
  function() return GetDB().raidWarning end,
  function(v) GetDB().raidWarning = v end
)

local cbSound = MakeCheck("BreakTimerLiteOptSound", colRight, cbRaidWarn,
  "Enable warning sounds",
  "Plays warning sounds at 10 seconds remaining and when timers end.",
  function() return GetDB().sound end,
  function(v) GetDB().sound = v end
)

local cbBeeps = MakeCheck("BreakTimerLiteOptBeeps", colRight, cbSound,
  "Enable short beeps (break timer)",
  "Plays short beeps at 3 and 1 seconds remaining on the break timer.",
  function() return GetDB().beeps end,
  function(v) GetDB().beeps = v end
)

local cbReady = MakeCheck("BreakTimerLiteOptReady", colRight, cbBeeps,
  "Ready check when break ends (leader/assist only)",
  "Starts a ready check when the break ends (requires leader/assist).",
  function() return GetDB().readyCheckOnEnd end,
  function(v) GetDB().readyCheckOnEnd = v end
)

local headerEffects = MakeHeader(colRight, cbReady, "Effects")

local cbEdgePulse = MakeCheck("BreakTimerLiteOptEdgePulse", colRight, headerEffects,
  "Screen-edge pulse during last 10 seconds (break timer)",
  "Shows a subtle red pulse at screen edges during the last 10 seconds of the break timer.",
  function() return GetDB().edgePulse end,
  function(v) GetDB().edgePulse = v end
)

local cbBigEnabled = MakeCheck("BreakTimerLiteOptBigEnabled", colRight, cbEdgePulse,
  "Enable big break countdown",
  "Shows a large break countdown timer near the center of your screen.",
  function() return GetDB().big.enabled end,
  function(v) GetDB().big.enabled = v end
)

local cbBigPulse = MakeCheck("BreakTimerLiteOptBigPulse", colRight, cbBigEnabled,
  "Pulse during last 10 seconds (break timer)",
  "Adds a subtle pulse effect during the last 10 seconds of the break timer.",
  function() return GetDB().big.pulseLast10 end,
  function(v) GetDB().big.pulseLast10 = v end
)

local cbBigShake = MakeCheck("BreakTimerLiteOptBigShake", colRight, cbBigPulse,
  "Shake during last 5 seconds (break timer)",
  "Adds a subtle shake effect during the last 5 seconds of the break timer.",
  function() return GetDB().big.shakeLast5 end,
  function(v) GetDB().big.shakeLast5 = v end
)

local cbBigFlash = MakeCheck("BreakTimerLiteOptBigFlash", colRight, cbBigShake,
  "Flash during last 5 seconds (break timer)",
  "Adds a subtle flash effect during the last 5 seconds of the break timer.",
  function() return GetDB().big.flashLast5 end,
  function(v) GetDB().big.flashLast5 = v end
)

local headerPullChecks = MakeHeader(colRight, cbBigFlash, "Pull Timer")

local cbPullEnabled = MakeCheck("BreakTimerLiteOptPullEnabled", colRight, headerPullChecks,
  "Enable pull timer overlay",
  "Shows large on-screen numbers for /pull (local only).",
  function() return GetDB().pull.enabled ~= false end,
  function(v) GetDB().pull.enabled = v end
)

local cbPullSound10 = MakeCheck("BreakTimerLiteOptPullSound10", colRight, cbPullEnabled,
  "Sound at 10 seconds (pull timer)",
  "Plays a sound when the pull countdown hits 10.",
  function() return GetDB().pull.soundAt10 ~= false end,
  function(v) GetDB().pull.soundAt10 = v end
)

local cbPullSoundLast = MakeCheck("BreakTimerLiteOptPullSoundLast", colRight, cbPullSound10,
  "Sound at 5 to 1 (pull timer)",
  "Plays a sound at 5, 4, 3, 2, 1 during the pull countdown.",
  function() return GetDB().pull.soundLast5 ~= false end,
  function(v) GetDB().pull.soundLast5 = v end
)

local headerBanners = MakeHeader(colRight, cbPullSoundLast, "Banners")

local cbBanner = MakeCheck("BreakTimerLiteOptBanner", colRight, headerBanners,
  "Enable banners",
  "Shows large banners on start/extend/end/cancel (local only).",
  function() return GetDB().banner.enabled end,
  function(v) GetDB().banner.enabled = v end
)

-- Refresh on show
panel:SetScript("OnShow", function()
  -- sliders
  sWidth:GetScript("OnShow")(sWidth)
  sHeight:GetScript("OnShow")(sHeight)
  sBigScale:GetScript("OnShow")(sBigScale)
  sPullScale:GetScript("OnShow")(sPullScale)
  sPullDefault:GetScript("OnShow")(sPullDefault)
  sDefault:GetScript("OnShow")(sDefault)

  -- checks
  cbRaidWarn:GetScript("OnShow")(cbRaidWarn)
  cbSound:GetScript("OnShow")(cbSound)
  cbBeeps:GetScript("OnShow")(cbBeeps)
  cbReady:GetScript("OnShow")(cbReady)
  cbEdgePulse:GetScript("OnShow")(cbEdgePulse)
  cbBigEnabled:GetScript("OnShow")(cbBigEnabled)
  cbBigPulse:GetScript("OnShow")(cbBigPulse)
  cbBigShake:GetScript("OnShow")(cbBigShake)
  cbBigFlash:GetScript("OnShow")(cbBigFlash)

  cbPullEnabled:GetScript("OnShow")(cbPullEnabled)
  cbPullSound10:GetScript("OnShow")(cbPullSound10)
  cbPullSoundLast:GetScript("OnShow")(cbPullSoundLast)

  cbBanner:GetScript("OnShow")(cbBanner)
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
