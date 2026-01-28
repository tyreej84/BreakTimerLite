-- Break Timer Lite - Options.lua
-- Simple, clean options panel (no chat announce options; visuals/sounds only)

local ADDON, ns = ...
local PANEL_NAME = "Break Timer Lite"

local function GetDB()
  return (ns and ns.GetDB and ns.GetDB()) or BreakTimerDB
end

local function MakeTitle(parent, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  fs:SetPoint("TOPLEFT", 16, -16)
  fs:SetText(text)
  return fs
end

local function MakeSubText(parent, anchor, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
  fs:SetWidth(600)
  fs:SetJustifyH("LEFT")
  fs:SetText(text)
  return fs
end

local function MakeHeader(parent, anchor, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -18)
  fs:SetText(text)
  return fs
end

local function MakeCheck(parent, anchor, label, tooltip, getter, setter)
  local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
  cb.Text:SetText(label)
  cb.tooltipText = tooltip

  cb:SetScript("OnShow", function(self)
    self:SetChecked(getter())
  end)

  cb:SetScript("OnClick", function(self)
    local v = self:GetChecked() and true or false
    setter(v)
  end)

  return cb
end

local function MakeSlider(parent, anchor, label, tooltip, minv, maxv, step, getter, setter, width)
  local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -28)
  s:SetWidth(width or 260)
  s:SetMinMaxValues(minv, maxv)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  s:SetOrientation("HORIZONTAL")
  s.tooltipText = tooltip

  _G[s:GetName() .. "Text"]:SetText(label)
  _G[s:GetName() .. "Low"]:SetText(tostring(minv))
  _G[s:GetName() .. "High"]:SetText(tostring(maxv))

  s:SetScript("OnShow", function(self)
    self:SetValue(getter())
  end)

  s:SetScript("OnValueChanged", function(self, value)
    value = math.floor((value / step) + 0.5) * step
    setter(value)
  end)

  return s
end

local function OpenBlizzOptionsToMe()
  if Settings and Settings.OpenToCategory then
    Settings.OpenToCategory(PANEL_NAME)
  else
    InterfaceOptionsFrame_OpenToCategory(PANEL_NAME)
    InterfaceOptionsFrame_OpenToCategory(PANEL_NAME)
  end
end

-- Expose for Core.lua slash handler
ns.OpenOptions = OpenBlizzOptionsToMe

-- ------------------------------------------------------------
-- Panel
-- ------------------------------------------------------------
local panel = CreateFrame("Frame", nil, UIParent)
panel.name = PANEL_NAME

local title = MakeTitle(panel, PANEL_NAME)
local sub = MakeSubText(panel, title,
  "A synced break timer replacement.\n" ..
  "• Only leader/raid assist can start/extend/stop while grouped.\n" ..
  "• No chat spam: all notifications are local only.\n" ..
  "Tip: Hold ALT and drag the bar or big timer to reposition."
)

local headerGeneral = MakeHeader(panel, sub, "General")

local cbRaidWarn = MakeCheck(panel, headerGeneral,
  "Show local Raid Warning messages",
  "Shows messages in the Raid Warning frame on your screen (does not send chat).",
  function() return GetDB().raidWarning end,
  function(v) GetDB().raidWarning = v end
)

local cbSound = MakeCheck(panel, cbRaidWarn,
  "Enable warning sounds",
  "Plays warning sounds at 10 seconds remaining and when the timer ends.",
  function() return GetDB().sound end,
  function(v) GetDB().sound = v end
)

local cbBeeps = MakeCheck(panel, cbSound,
  "Enable short beeps",
  "Plays short beeps at 3 and 1 seconds remaining.",
  function() return GetDB().beeps end,
  function(v) GetDB().beeps = v end
)

local cbReady = MakeCheck(panel, cbBeeps,
  "Ready check when break ends (leader/assist only)",
  "Starts a ready check when the break ends (requires leader/assist).",
  function() return GetDB().readyCheckOnEnd end,
  function(v) GetDB().readyCheckOnEnd = v end
)

local headerBar = MakeHeader(panel, cbReady, "Timer Bar")

local sWidth = MakeSlider(panel, headerBar,
  "Bar width",
  "Adjust the timer bar width.",
  180, 520, 10,
  function() return GetDB().width end,
  function(v)
    GetDB().width = v
    if ns.SetBarSize then ns.SetBarSize() end
  end
)

local sHeight = MakeSlider(panel, sWidth,
  "Bar height",
  "Adjust the timer bar height.",
  14, 40, 1,
  function() return GetDB().height end,
  function(v)
    GetDB().height = v
    if ns.SetBarSize then ns.SetBarSize() end
  end
)

local cbEdgePulse = MakeCheck(panel, sHeight,
  "Screen-edge pulse during last 10 seconds",
  "Shows a subtle red pulse at screen edges during the last 10 seconds.",
  function() return GetDB().edgePulse end,
  function(v) GetDB().edgePulse = v end
)

local headerBig = MakeHeader(panel, cbEdgePulse, "Big Countdown")

local cbBigEnabled = MakeCheck(panel, headerBig,
  "Enable big countdown",
  "Shows a large countdown timer near the center of your screen.",
  function() return GetDB().big.enabled end,
  function(v)
    GetDB().big.enabled = v
  end
)

local sBigScale = MakeSlider(panel, cbBigEnabled,
  "Big countdown scale",
  "Adjust the size of the big countdown.",
  1.0, 2.5, 0.1,
  function() return GetDB().big.scale end,
  function(v)
    GetDB().big.scale = v
    if ns.SetBigScale then ns.SetBigScale() end
  end
)

local cbBigPulse = MakeCheck(panel, sBigScale,
  "Pulse during last 10 seconds",
  "Adds a subtle pulse effect during the last 10 seconds.",
  function() return GetDB().big.pulseLast10 end,
  function(v) GetDB().big.pulseLast10 = v end
)

local cbBigShake = MakeCheck(panel, cbBigPulse,
  "Shake during last 5 seconds",
  "Adds a subtle shake effect during the last 5 seconds.",
  function() return GetDB().big.shakeLast5 end,
  function(v) GetDB().big.shakeLast5 = v end
)

local cbBigFlash = MakeCheck(panel, cbBigShake,
  "Flash during last 5 seconds",
  "Adds a subtle flash effect during the last 5 seconds.",
  function() return GetDB().big.flashLast5 end,
  function(v) GetDB().big.flashLast5 = v end
)

local headerBanner = MakeHeader(panel, cbBigFlash, "Banners")

local cbBanner = MakeCheck(panel, headerBanner,
  "Enable banners",
  "Shows large banners on start/extend/end/cancel.",
  function() return GetDB().banner.enabled end,
  function(v) GetDB().banner.enabled = v end
)

local headerDefaults = MakeHeader(panel, cbBanner, "Defaults")

local sDefault = MakeSlider(panel, headerDefaults,
  "Default /break minutes",
  "When you type /break with no arguments, this is the default duration (in minutes).",
  1, 30, 1,
  function() return tonumber(GetDB().defaultMinutes) or 5 end,
  function(v) GetDB().defaultMinutes = v end
)

-- ------------------------------------------------------------
-- Panel lifecycle
-- ------------------------------------------------------------
panel:SetScript("OnShow", function()
  -- refresh visible controls
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

if Settings and Settings.RegisterCanvasLayoutCategory then
  local category = Settings.RegisterCanvasLayoutCategory(panel, PANEL_NAME)
  Settings.RegisterAddOnCategory(category)
else
  InterfaceOptions_AddCategory(panel)
end
