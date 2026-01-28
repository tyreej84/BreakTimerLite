-- Break Timer Lite - Options.lua
-- Sync is always enabled; no sync toggle.

local ADDON, ns = ...
local panel = CreateFrame("Frame")
panel.name = "Break Timer Lite"

local function MakeCheckbox(parent, label, tooltip, get, set, x, y)
  local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", x, y)
  cb.Text:SetText(label)
  cb.tooltipText = tooltip
  cb:SetScript("OnShow", function(self) self:SetChecked(get()) end)
  cb:SetScript("OnClick", function(self) set(self:GetChecked()) end)
  return cb
end

local function MakeSlider(parent, label, minV, maxV, step, get, set, x, y)
  local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", x, y)
  s:SetMinMaxValues(minV, maxV)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  s:SetWidth(260)

  _G[s:GetName() .. "Text"]:SetText(label)
  _G[s:GetName() .. "Low"]:SetText(tostring(minV))
  _G[s:GetName() .. "High"]:SetText(tostring(maxV))

  s:SetScript("OnShow", function(self) self:SetValue(get()) end)
  s:SetScript("OnValueChanged", function(self, v) set(v) end)
  return s
end

local function RegisterOptions(panelFrame)
  if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panelFrame, panelFrame.name)
    category.ID = panelFrame.name
    Settings.RegisterAddOnCategory(category)
    return category
  end
  if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panelFrame)
  end
end

local function OpenOptions(panelFrame)
  if Settings and Settings.OpenToCategory then
    Settings.OpenToCategory(panelFrame.name)
    return
  end
  if InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(panelFrame)
    InterfaceOptionsFrame_OpenToCategory(panelFrame)
  end
end

panel:SetScript("OnShow", function(self)
  if self._built then return end
  self._built = true

  local db = ns.GetDB()

  local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("Break Timer Lite")

  local tip = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  tip:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  tip:SetText("Sync is always on. Commands: /break [minutes] [reason], /break +5, /break extend 5, /break stop, /break status. Aliases: /breaktimer /breaktime /bt")

  -- Left column
  MakeCheckbox(self, "Show minimap button", "Show or hide the minimap button.",
    function() return not db.minimap.hide end,
    function(v)
      db.minimap.hide = not v
      if ns.MinimapButton_Reposition then ns.MinimapButton_Reposition() end
    end,
    16, -60
  )

  MakeSlider(self, "Default break minutes (/break)", 1, 30, 1,
    function() return db.defaultMinutes or 5 end,
    function(v) db.defaultMinutes = math.floor(v + 0.5) end,
    16, -110
  )

  MakeCheckbox(self, "Enable center banner", "Show banners on start, extend, end, and cancel.",
    function() return db.banner.enabled end,
    function(v) db.banner.enabled = v and true or false end,
    16, -170
  )

  MakeCheckbox(self, "Enable big center timer", "Show a large center countdown (ALT-drag to move).",
    function() return db.big.enabled end,
    function(v) db.big.enabled = v and true or false end,
    16, -200
  )

  MakeSlider(self, "Big timer scale", 0.8, 2.6, 0.1,
    function() return db.big.scale or 1.6 end,
    function(v) db.big.scale = math.floor((v + 0.00001) * 10) / 10 end,
    16, -250
  )

  -- Right column
  MakeCheckbox(self, "Announce to group", "Send start/extend/end lines to party/raid/instance chat (smart rules apply).",
    function() return db.announce end,
    function(v) db.announce = v and true or false end,
    320, -60
  )

  MakeCheckbox(self, "Smart announce", "Avoid chat spam for very short timers (default min 30 seconds).",
    function() return db.smartAnnounce end,
    function(v) db.smartAnnounce = v and true or false end,
    320, -90
  )

  MakeCheckbox(self, "Use Raid Warning when possible", "If you're leader/assist in a raid, also use Raid Warning.",
    function() return db.raidWarning end,
    function(v) db.raidWarning = v and true or false end,
    320, -120
  )

  MakeCheckbox(self, "Reminder messages (2:00 / 1:00 / 0:30 / 0:10)", "Reminder cadence as the break ends.",
    function() return db.remind end,
    function(v) db.remind = v and true or false end,
    320, -150
  )

  MakeCheckbox(self, "Beep at 10 / 3 / 1 (built-in)", "Extra beeps on 10, 3, and 1 seconds remaining.",
    function() return db.beeps end,
    function(v) db.beeps = v and true or false end,
    320, -180
  )

  MakeCheckbox(self, "Screen-edge pulse last 10s", "Adds urgency pulse on the screen edges in the last 10 seconds.",
    function() return db.edgePulse end,
    function(v) db.edgePulse = v and true or false end,
    320, -210
  )

  MakeCheckbox(self, "Ready check when break ends", "Leader/assist only. Triggers a ready check after the break ends.",
    function() return db.readyCheckOnEnd end,
    function(v) db.readyCheckOnEnd = v and true or false end,
    320, -240
  )

  MakeSlider(self, "Bar width", 180, 420, 10,
    function() return db.width end,
    function(v) db.width = math.floor(v + 0.5); ns.SetBarSize() end,
    320, -290
  )

  MakeSlider(self, "Bar height", 12, 32, 1,
    function() return db.height end,
    function(v) db.height = math.floor(v + 0.5); ns.SetBarSize() end,
    320, -350
  )

  local test = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
  test:SetSize(120, 22)
  test:SetPoint("TOPLEFT", 16, -360)
  test:SetText("Test (30s)")
  test:SetScript("OnClick", function()
    ns.StartTimer(30, "Test", true, true, "You", false)
  end)

  local status = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
  status:SetSize(120, 22)
  status:SetPoint("LEFT", test, "RIGHT", 10, 0)
  status:SetText("Status")
  status:SetScript("OnClick", function()
    if ns.OpenStatus then ns.OpenStatus() end
  end)

  local help = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  help:SetPoint("TOPLEFT", 16, -392)
  help:SetText("Move bar + big timer: hold ALT and drag. Late-join sync, conflict handling, and version handshake are always on.")
end)

RegisterOptions(panel)
ns.OpenOptions = function() OpenOptions(panel) end
