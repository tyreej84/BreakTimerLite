-- Break Timer Lite - Core.lua
-- Commands:
--   /break [minutes] [reason]
--   /break +<minutes>
--   /break extend <minutes>
--   /break stop
--   /break status
--   /break options
-- Aliases:
--   /breaktimer /breaktime /bt

local ADDON, ns = ...
local PREFIX = "BreakTimerLite"
local ADDON_VERSION = "1.1.8"

local defaults = {
  width = 260,
  height = 20,
  point = { "CENTER", "UIParent", "CENTER", 0, 180 },

  defaultMinutes = 5,
  smartAnnounce = true,
  smartAnnounceMinSeconds = 30,

  announce = true,
  raidWarning = true,
  sound = true,
  remind = true,
  label = "Break",

  beeps = true,
  edgePulse = true,
  readyCheckOnEnd = true,

  big = {
    enabled = true,
    scale = 1.6,
    point = { "CENTER", "UIParent", "CENTER", 0, 60 },
    pulseLast10 = true,
    shakeLast5 = true,
    flashLast5 = true,
  },

  banner = { enabled = true },
}

BreakTimerDB = BreakTimerDB or {}
local db

local function CopyDefaults(src, dst)
  if type(dst) ~= "table" then dst = {} end
  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = CopyDefaults(v, dst[k])
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

-- ------------------------------------------------------------
-- Helpers
-- ------------------------------------------------------------
local function NowServer()
  if GetServerTime then return GetServerTime() end
  return time()
end

local function FormatTime(sec)
  sec = math.max(0, math.floor(sec + 0.5))
  local m = math.floor(sec / 60)
  local s = sec % 60
  return string.format("%d:%02d", m, s)
end

local function LocalPrint(msg)
  print("|cffffd100Break Timer Lite|r: " .. msg)
end

local function BigWarnLocal(msg)
  RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
end

local function GetGroupChannel()
  if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
  if IsInRaid() then return "RAID" end
  if IsInGroup() then return "PARTY" end
  return nil
end

-- ------------------------------------------------------------
-- Permissions + authority rank
-- ------------------------------------------------------------
local function IsPrivilegedLocal()
  if not IsInGroup() and not IsInRaid() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
    return true
  end
  if IsInRaid() then
    return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
  end
  return UnitIsGroupLeader("player")
end

local function LocalAuthorityRank()
  if not (IsInGroup() or IsInRaid() or IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then return 1 end
  if IsInRaid() then
    if UnitIsGroupLeader("player") then return 3 end
    if UnitIsGroupAssistant("player") then return 2 end
    return 0
  end
  return UnitIsGroupLeader("player") and 2 or 0
end

local function FindUnitBySender(sender)
  if not sender or sender == "" then return nil end
  local shortSender = Ambiguate(sender, "short")

  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local unit = "raid" .. i
      local name = UnitName(unit)
      if name and Ambiguate(name, "short") == shortSender then
        return unit
      end
    end
  else
    for i = 1, GetNumSubgroupMembers() do
      local unit = "party" .. i
      local name = UnitName(unit)
      if name and Ambiguate(name, "short") == shortSender then
        return unit
      end
    end
    local myName = UnitName("player")
    if myName and Ambiguate(myName, "short") == shortSender then
      return "player"
    end
  end

  return nil
end

local function SenderAuthorityRank(sender)
  local unit = FindUnitBySender(sender)
  if not unit then return 0 end
  if IsInRaid() then
    if UnitIsGroupLeader(unit) then return 3 end
    if UnitIsGroupAssistant(unit) then return 2 end
    return 0
  end
  return UnitIsGroupLeader(unit) and 2 or 0
end

local function SenderIsPrivileged(sender)
  return SenderAuthorityRank(sender) >= 2
end

local function CanRaidWarn()
  return IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
end

-- ------------------------------------------------------------
-- Announcement formatting
-- ------------------------------------------------------------
local function FormatAnnounceLine(title, reason, timeStr)
  local t = title or "Break"
  local r = reason and reason ~= "" and (" (" .. reason .. ")") or ""
  local s = timeStr and timeStr ~= "" and (" - " .. timeStr) or ""
  return string.format("*** %s%s%s ***", t, r, s)
end

-- ------------------------------------------------------------
-- Throttle
-- ------------------------------------------------------------
local throttle = { lastSync = 0, lastAnnounce = 0, lastRequest = 0, lastHello = 0 }
local function Throttled(kind, window)
  window = window or 0.6
  local t = GetTime()
  local key = "last" .. kind
  if throttle[key] and (t - throttle[key] < window) then
    return true
  end
  throttle[key] = t
  return false
end

-- ------------------------------------------------------------
-- Announce
-- ------------------------------------------------------------
local function DoAnnounce(msg)
  if not db.announce then return end
  local ch = GetGroupChannel()
  if not ch then return end
  if Throttled("Announce", 0.35) then return end

  if db.raidWarning and ch == "RAID" and CanRaidWarn() then
    RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
    SendChatMessage(msg, "RAID_WARNING")
  else
    SendChatMessage(msg, ch)
  end
end

-- ------------------------------------------------------------
-- Addon Sync send
-- ------------------------------------------------------------
local function SyncSend(payload)
  local ch = GetGroupChannel()
  if not ch then return end
  if Throttled("Sync", 0.25) then return end
  C_ChatInfo.SendAddonMessage(PREFIX, payload, ch)
end

-- ------------------------------------------------------------
-- Blizzard countdown text (same as /cd 10)
-- Triggered at 10s remaining. If we're not privileged, request a privileged member do it.
-- ------------------------------------------------------------
local function DoBlizzardCountdown10()
  if not (C_PartyInfo and C_PartyInfo.DoCountdown) then return false end
  if GetGroupChannel() == nil then return false end
  if not IsPrivilegedLocal() then return false end
  C_PartyInfo.DoCountdown(10)
  return true
end

local function CancelBlizzardCountdownBestEffort()
  if GetGroupChannel() == nil then return end
  if not IsPrivilegedLocal() then return end
  if not C_PartyInfo then return end

  if type(C_PartyInfo.CancelCountdown) == "function" then
    C_PartyInfo.CancelCountdown()
  elseif type(C_PartyInfo.DoCountdown) == "function" then
    C_PartyInfo.DoCountdown(0)
  end
end

-- ------------------------------------------------------------
-- Screen flash helper
-- ------------------------------------------------------------
local function FlashScreen()
  local f = BreakTimerLiteFlashFrame
  if not f then
    f = CreateFrame("Frame", "BreakTimerLiteFlashFrame", UIParent)
    f:SetAllPoints(UIParent)
    f.tex = f:CreateTexture(nil, "OVERLAY")
    f.tex:SetAllPoints(f)
    f.tex:SetColorTexture(1, 1, 1, 0)
    f:Hide()
  end

  f:Show()
  f.tex:SetAlpha(0.6)
  C_Timer.After(0.08, function() if f and f.tex then f.tex:SetAlpha(0) end end)
  C_Timer.After(0.16, function() if f and f.tex then f.tex:SetAlpha(0.5) end end)
  C_Timer.After(0.24, function() if f and f.tex then f.tex:SetAlpha(0) end end)
  C_Timer.After(0.30, function() if f then f:Hide() end end)
end

-- ------------------------------------------------------------
-- Screen-edge pulse
-- ------------------------------------------------------------
local EdgePulse = CreateFrame("Frame", "BreakTimerLiteEdgePulse", UIParent)
EdgePulse:SetAllPoints(UIParent)
EdgePulse:SetFrameStrata("FULLSCREEN_DIALOG")
EdgePulse.tex = EdgePulse:CreateTexture(nil, "OVERLAY")
EdgePulse.tex:SetAllPoints(EdgePulse)
EdgePulse.tex:SetColorTexture(1, 0, 0, 0)
EdgePulse:Hide()

local function EdgePulseTick(alpha)
  if not db.edgePulse then return end
  EdgePulse:Show()
  EdgePulse.tex:SetAlpha(alpha)
end

local function EdgePulseOff()
  EdgePulse.tex:SetAlpha(0)
  EdgePulse:Hide()
end

-- ------------------------------------------------------------
-- Banner
-- ------------------------------------------------------------
local Banner = CreateFrame("Frame", "BreakTimerLiteBanner", UIParent, "BackdropTemplate")
Banner:Hide()
Banner:SetSize(520, 74)
Banner:SetPoint("TOP", UIParent, "TOP", 0, -140)
Banner:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = false,
  edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
Banner:SetBackdropColor(0, 0, 0, 0.65)
Banner:SetFrameStrata("HIGH")
Banner:SetAlpha(0)

Banner.text = Banner:CreateFontString(nil, "OVERLAY")
Banner.text:SetPoint("CENTER", 0, 8)
Banner.text:SetFont(STANDARD_TEXT_FONT, 26, "OUTLINE")
Banner.text:SetShadowOffset(2, -2)
Banner.text:SetShadowColor(0, 0, 0, 1)

Banner.sub = Banner:CreateFontString(nil, "OVERLAY")
Banner.sub:SetPoint("TOP", Banner.text, "BOTTOM", 0, -4)
Banner.sub:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
Banner.sub:SetShadowOffset(2, -2)
Banner.sub:SetShadowColor(0, 0, 0, 1)

Banner.ag = Banner:CreateAnimationGroup()
local aIn = Banner.ag:CreateAnimation("Alpha"); aIn:SetFromAlpha(0); aIn:SetToAlpha(1); aIn:SetDuration(0.14); aIn:SetOrder(1)
local tIn = Banner.ag:CreateAnimation("Translation"); tIn:SetOffset(0, -18); tIn:SetDuration(0.14); tIn:SetOrder(1)
local hold = Banner.ag:CreateAnimation("Alpha"); hold:SetFromAlpha(1); hold:SetToAlpha(1); hold:SetDuration(1.05); hold:SetOrder(2)
local aOut = Banner.ag:CreateAnimation("Alpha"); aOut:SetFromAlpha(1); aOut:SetToAlpha(0); aOut:SetDuration(0.22); aOut:SetOrder(3)
local tOut = Banner.ag:CreateAnimation("Translation"); tOut:SetOffset(0, 18); tOut:SetDuration(0.22); tOut:SetOrder(3)
Banner.ag:SetScript("OnFinished", function() Banner:Hide(); Banner:SetAlpha(0) end)

local function ShowBanner(mainText, subText)
  if not db.banner.enabled then return end
  Banner.text:SetText(mainText or "")
  if subText and subText ~= "" then
    Banner.sub:SetText(subText)
    Banner.sub:Show()
  else
    Banner.sub:SetText("")
    Banner.sub:Hide()
  end
  Banner.ag:Stop()
  Banner:Show()
  Banner:SetAlpha(0)
  Banner.ag:Play()
end

-- ------------------------------------------------------------
-- UI: Sleek bar (translucent black container + flat blue fill + thin edge line)
-- Text overlay frame is above the fill so it never disappears.
-- Text style: SIMPLE WHITE (no outline, no shadow)
-- ------------------------------------------------------------
local Bar = CreateFrame("Frame", "BreakTimerLiteBar", UIParent, "BackdropTemplate")
Bar:Hide()
Bar:SetClampedToScreen(true)
Bar:SetMovable(true)
Bar:EnableMouse(true)
Bar:RegisterForDrag("LeftButton")
Bar:SetScript("OnDragStart", function(self) if IsAltKeyDown() then self:StartMoving() end end)
Bar:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local p, rel, rp, x, y = self:GetPoint(1)
  db.point = { p, rel:GetName(), rp, x, y }
end)

Bar:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
Bar:SetBackdropColor(0, 0, 0, 0.55)
Bar:SetBackdropBorderColor(1, 1, 1, 0.12)

local Track = Bar:CreateTexture(nil, "BACKGROUND")
Track:SetPoint("TOPLEFT", 2, -2)
Track:SetPoint("BOTTOMRIGHT", -2, 2)
Track:SetColorTexture(0, 0, 0, 0.40)

local Status = CreateFrame("StatusBar", nil, Bar)
Status:SetPoint("TOPLEFT", 2, -2)
Status:SetPoint("BOTTOMRIGHT", -2, 2)
Status:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
Status:GetStatusBarTexture():SetHorizTile(false)
Status:GetStatusBarTexture():SetVertTile(false)
Status:SetMinMaxValues(0, 1)
Status:SetValue(1)

local EdgeLine = Status:CreateTexture(nil, "OVERLAY")
EdgeLine:SetTexture("Interface\\Buttons\\WHITE8x8")
EdgeLine:SetColorTexture(1, 1, 1, 0.55)
EdgeLine:SetSize(2, (defaults.height or 20) + 10)

local Glow = Bar:CreateTexture(nil, "OVERLAY")
Glow:SetAllPoints(Bar)
Glow:SetColorTexture(1, 0.2, 0.2, 0)
Glow:Hide()

-- text overlay on top
local TextOverlay = CreateFrame("Frame", nil, Bar)
TextOverlay:SetAllPoints(Bar)
TextOverlay:SetFrameStrata(Bar:GetFrameStrata())
TextOverlay:SetFrameLevel(Bar:GetFrameLevel() + 20)

local function StyleBarText(fs, size, justify)
  fs:SetFont(STANDARD_TEXT_FONT, size or 12, "") -- no outline
  fs:SetTextColor(1, 1, 1, 1)                   -- simple white
  fs:SetShadowColor(0, 0, 0, 0)                 -- no shadow
  fs:SetShadowOffset(0, 0)
  fs:SetJustifyH(justify or "LEFT")
end

local TextLeft = TextOverlay:CreateFontString(nil, "OVERLAY")
TextLeft:SetPoint("LEFT", 6, 0)
StyleBarText(TextLeft, 12, "LEFT")

local TextRight = TextOverlay:CreateFontString(nil, "OVERLAY")
TextRight:SetPoint("RIGHT", -6, 0)
StyleBarText(TextRight, 12, "RIGHT")

local function SetBarSize()
  Bar:SetSize(db.width, db.height)
  EdgeLine:SetSize(2, db.height + 10)
end

local function SetBarPoint()
  Bar:ClearAllPoints()
  local p, relName, rp, x, y = unpack(db.point)
  local rel = _G[relName] or UIParent
  Bar:SetPoint(p, rel, rp, x, y)
end

-- ------------------------------------------------------------
-- UI: Big center timer
-- ------------------------------------------------------------
local Big = CreateFrame("Frame", "BreakTimerLiteBigFrame", UIParent)
Big:Hide()
Big:SetClampedToScreen(true)
Big:SetMovable(true)
Big:EnableMouse(true)
Big:RegisterForDrag("LeftButton")
Big:SetScript("OnDragStart", function(self) if IsAltKeyDown() then self:StartMoving() end end)
Big:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local p, rel, rp, x, y = self:GetPoint(1)
  db.big.point = { p, rel:GetName(), rp, x, y }
end)
Big:SetAlpha(0)

Big.header = Big:CreateFontString(nil, "OVERLAY")
Big.header:SetPoint("BOTTOM", Big, "CENTER", 0, 40)
Big.header:SetFont(STANDARD_TEXT_FONT, 28, "OUTLINE")
Big.header:SetShadowOffset(2, -2)
Big.header:SetShadowColor(0, 0, 0, 1)
Big.header:SetText("BREAK")

Big.text = Big:CreateFontString(nil, "OVERLAY")
Big.text:SetPoint("CENTER", 0, 0)
Big.text:SetFont(STANDARD_TEXT_FONT, 56, "OUTLINE")
Big.text:SetShadowOffset(2, -2)
Big.text:SetShadowColor(0, 0, 0, 1)
Big.text:SetJustifyH("CENTER")

Big.sub = Big:CreateFontString(nil, "OVERLAY")
Big.sub:SetPoint("TOP", Big, "CENTER", 0, -42)
Big.sub:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
Big.sub:SetShadowOffset(2, -2)
Big.sub:SetShadowColor(0, 0, 0, 1)
Big.sub:SetJustifyH("CENTER")

Big.flash = Big:CreateTexture(nil, "OVERLAY")
Big.flash:SetAllPoints(Big)
Big.flash:SetColorTexture(1, 1, 1, 0)
Big.flash:Hide()

local function SetBigPoint()
  Big:ClearAllPoints()
  local p, relName, rp, x, y = unpack(db.big.point)
  local rel = _G[relName] or UIParent
  Big:SetPoint(p, rel, rp, x, y)
end

local function SetBigScale()
  Big:SetScale(db.big.scale or 1.6)
end

local function BigFlashPulse()
  Big.flash:Show()
  Big.flash:SetAlpha(0.35)
  C_Timer.After(0.06, function() if Big and Big.flash then Big.flash:SetAlpha(0) end end)
  C_Timer.After(0.10, function() if Big and Big.flash then Big.flash:Hide() end end)
end

local function FadeFrameTo(frame, targetAlpha, duration)
  duration = duration or 0.15
  if frame._fadeTicker then frame._fadeTicker:Cancel() end
  local startAlpha = frame:GetAlpha() or 0
  local t0 = GetTime()
  frame._fadeTicker = C_Timer.NewTicker(0.02, function()
    local t = (GetTime() - t0) / duration
    if t >= 1 then
      frame:SetAlpha(targetAlpha)
      if frame._fadeTicker then frame._fadeTicker:Cancel() end
      frame._fadeTicker = nil
      return
    end
    frame:SetAlpha(startAlpha + (targetAlpha - startAlpha) * t)
  end)
end

-- ------------------------------------------------------------
-- Timer state
-- ------------------------------------------------------------
local state = {
  running = false,
  startServer = 0,
  endServer = 0,
  startLocal = 0,
  endLocal = 0,

  duration = 0,
  reason = "",
  caller = "",
  authority = 0,

  ticker = nil,
  warned10 = false,
  reminded = {},
  lastWhole = nil,
  baseBigScale = 1.6,
  shakeSeed = 0,

  cdStarted = false,
}

local function ResetReminderFlags()
  state.warned10 = false
  state.reminded = { [120]=false, [60]=false, [30]=false, [10]=false }
  state.lastWhole = nil
  state.shakeSeed = 0
  state.cdStarted = false
end

local function StopTicker()
  if state.ticker then state.ticker:Cancel(); state.ticker = nil end
end

local function Remaining()
  return state.endLocal - GetTime()
end

local function Beep()
  if not db.beeps then return end
  PlaySound(SOUNDKIT.UI_IG_MAINMENU_OPTION_CHECKBOX_ON, "Master")
end

local function BuildBarLeftText()
  local base = db.label or "Break"
  local r = state.reason or ""
  local who = state.caller or ""
  local txt = base
  if r ~= "" then txt = txt .. ": " .. r end
  if who ~= "" then txt = txt .. " (" .. who .. ")" end
  return txt
end

local function SetBarColor()
  -- slightly translucent blue so the black track can be seen underneath as it shrinks
  Status:SetStatusBarColor(0.15, 0.55, 1.00, 0.90)
end

local function UpdateEdgeLine(pct)
  local w = Status:GetWidth()
  local x = (w * pct)
  EdgeLine:ClearAllPoints()
  EdgeLine:SetPoint("CENTER", Status, "LEFT", x, 0)
  EdgeLine:SetShown(pct > 0.001)
end

local function UpdateBar(rem)
  local pct = 0
  if state.duration > 0 then pct = rem / state.duration end
  pct = math.max(0, math.min(1, pct))
  Status:SetValue(pct)
  SetBarColor()

  TextLeft:SetText(BuildBarLeftText())
  TextRight:SetText(FormatTime(rem))

  UpdateEdgeLine(pct)

  if rem <= 10 then
    Glow:Show()
    local pulse = 0.10 + 0.14 * (0.5 + 0.5 * math.sin(GetTime() * 10))
    Glow:SetAlpha(pulse)
  else
    Glow:Hide()
    Glow:SetAlpha(0)
  end
end

local function SetBigColorByRemaining(rem)
  if rem <= 10 then
    Big.text:SetTextColor(1, 0.2, 0.2)
    Big.header:SetTextColor(1, 0.2, 0.2)
  elseif rem <= 30 then
    Big.text:SetTextColor(1, 0.85, 0.2)
    Big.header:SetTextColor(1, 0.85, 0.2)
  else
    Big.text:SetTextColor(0.2, 1, 0.2)
    Big.header:SetTextColor(0.2, 1, 0.2)
  end
end

local function UpdateBig(rem, whole)
  if not db.big.enabled then return end

  Big.text:SetText(FormatTime(rem))
  if state.reason ~= "" then
    Big.sub:SetText(state.reason)
    Big.sub:Show()
  else
    Big.sub:SetText("")
    Big.sub:Hide()
  end
  SetBigColorByRemaining(rem)

  if db.big.pulseLast10 and rem <= 10 then
    local frac = rem - math.floor(rem)
    local bump = 1 + (0.08 * math.sin(frac * 2 * math.pi))
    Big:SetScale(state.baseBigScale * bump)
  else
    Big:SetScale(state.baseBigScale)
  end

  if db.big.shakeLast5 and rem <= 5 then
    state.shakeSeed = state.shakeSeed + 1
    local dx = ((state.shakeSeed * 37) % 7) - 3
    local dy = ((state.shakeSeed * 53) % 7) - 3
    Big.text:SetPoint("CENTER", dx, dy)
  else
    Big.text:SetPoint("CENTER", 0, 0)
  end

  if db.big.flashLast5 and whole and whole <= 5 and whole >= 1 then
    if state.lastWhole ~= whole then BigFlashPulse() end
  end

  state.lastWhole = whole
end

local function ShouldAnnounceFor(seconds)
  if not db.smartAnnounce then return true end
  return seconds >= (db.smartAnnounceMinSeconds or 30)
end

local function TryReadyCheck()
  if not db.readyCheckOnEnd then return end
  if not IsPrivilegedLocal() then return end
  if type(DoReadyCheck) == "function" then DoReadyCheck() end
end

local function ShouldAcceptRemote(startServer, authorityRank)
  if not state.running then return true end
  if authorityRank > (state.authority or 0) then return true end
  if authorityRank < (state.authority or 0) then return false end
  return startServer > (state.startServer or 0)
end

local function StartTimerWithServerTimes(startServer, endServer, reason, caller, authority, silent, fromSync)
  local seconds = math.max(1, endServer - startServer)

  state.running = true
  state.startServer = startServer
  state.endServer = endServer
  state.duration = seconds
  state.reason = reason or ""
  state.caller = caller or ""
  state.authority = authority or 0

  local serverDelta = endServer - NowServer()
  state.endLocal = GetTime() + serverDelta
  local startDelta = startServer - NowServer()
  state.startLocal = GetTime() + startDelta

  ResetReminderFlags()

  Bar:Show()
  UpdateBar(Remaining())

  SetBigPoint()
  state.baseBigScale = db.big.scale or 1.6
  if db.big.enabled then
    Big:Show()
    Big:SetScale(state.baseBigScale)
    Big.text:SetPoint("CENTER", 0, 0)
    Big:SetAlpha(0)
    FadeFrameTo(Big, 1, 0.18)
  else
    Big:Hide()
  end

  BigWarnLocal(FormatAnnounceLine("Break", state.reason, FormatTime(seconds)) .. " - called by " .. (state.caller ~= "" and state.caller or "?"))
  ShowBanner("BREAK STARTED", state.reason ~= "" and state.reason or "")

  if (not silent) and ShouldAnnounceFor(seconds) then
    DoAnnounce(FormatAnnounceLine("Break", state.reason, FormatTime(seconds)) .. (state.caller ~= "" and (" (" .. state.caller .. ")") or ""))
  end

  StopTicker()
  state.ticker = C_Timer.NewTicker(0.05, function()
    if not state.running then return end
    local rem = Remaining()
    if rem <= 0 then
      state.running = false
      StopTicker()
      UpdateBar(0)

      FlashScreen()
      ShowBanner("BREAK OVER", state.reason ~= "" and state.reason or "")
      BigWarnLocal("BREAK OVER!")
      if db.sound then PlaySound(SOUNDKIT.RAID_WARNING, "Master") end
      if db.big.enabled then FadeFrameTo(Big, 0, 0.20) end

      EdgePulseOff()

      if ShouldAnnounceFor(seconds) then
        DoAnnounce(FormatAnnounceLine("Break Over", state.reason, ""))
      end

      C_Timer.After(1.0, function() TryReadyCheck() end)

      C_Timer.After(0.35, function()
        if not state.running then
          Bar:Hide()
          Big:Hide()
          Big.text:SetPoint("CENTER", 0, 0)
          Big:SetScale(state.baseBigScale)
        end
      end)
      return
    end

    local whole = math.floor(rem + 0.5)

    UpdateBar(rem)
    UpdateBig(rem, whole)

    if db.edgePulse and rem <= 10 then
      local a = 0.06 + 0.10 * (0.5 + 0.5 * math.sin(GetTime() * 10))
      EdgePulseTick(a)
    else
      EdgePulseOff()
    end

    if rem <= 10 and not state.warned10 then
      state.warned10 = true
      FlashScreen()
      BigWarnLocal("Break ends in 10 seconds!")
      if db.sound then PlaySound(SOUNDKIT.RAID_WARNING, "Master") end
      Beep()
    end

    if rem <= 10 and not state.cdStarted and GetGroupChannel() ~= nil then
      if DoBlizzardCountdown10() then
        state.cdStarted = true
        SyncSend("COUNTDOWN;" .. tostring(state.startServer))
      else
        SyncSend("CDREQUEST;" .. tostring(state.startServer))
      end
    end

    if whole == 3 then Beep() end
    if whole == 1 then Beep() end

    if db.remind then
      for _, t in ipairs({120, 60, 30, 10}) do
        if rem <= t and not state.reminded[t] then
          state.reminded[t] = true
          if ShouldAnnounceFor(seconds) then
            DoAnnounce(FormatAnnounceLine("Break", state.reason, FormatTime(rem)))
          end
        end
      end
    end
  end)

  return true
end

local function StartTimer(seconds, reason, silent, fromSync, callerName, authorityRank, startServerOverride)
  seconds = tonumber(seconds)
  if not seconds or seconds <= 0 then return false end

  local grouped = (GetGroupChannel() ~= nil)
  if grouped and not fromSync and not IsPrivilegedLocal() then
    LocalPrint("Only the leader (or raid assist) can start a break timer.")
    return false
  end

  local caller = callerName and callerName ~= "" and callerName or Ambiguate(UnitName("player") or "", "short")
  local auth = authorityRank or LocalAuthorityRank()
  local startServer = startServerOverride or NowServer()
  local endServer = startServer + math.floor(seconds + 0.5)

  StartTimerWithServerTimes(startServer, endServer, reason or "", caller, auth, silent, fromSync)

  if grouped and not fromSync then
    SyncSend(string.format("START;%d;%d;%s;%s;%d;%s", startServer, endServer, reason or "", caller, auth, ADDON_VERSION))
  end

  return true
end

local function StopTimer(silent, fromSync, callerName)
  if not state.running then
    CancelBlizzardCountdownBestEffort()
    return
  end

  local grouped = (GetGroupChannel() ~= nil)
  if grouped and not fromSync and not IsPrivilegedLocal() then
    LocalPrint("Only the leader (or raid assist) can stop the break timer.")
    return
  end

  if not fromSync then CancelBlizzardCountdownBestEffort() end

  local who = (callerName and callerName ~= "" and callerName) or Ambiguate(UnitName("player") or "", "short")

  state.running = false
  StopTicker()
  Bar:Hide()

  if db.big.enabled then
    FadeFrameTo(Big, 0, 0.18)
    C_Timer.After(0.22, function() if not state.running then Big:Hide() end end)
  else
    Big:Hide()
  end

  EdgePulseOff()
  FlashScreen()
  ShowBanner("BREAK CANCELED", who)
  BigWarnLocal("BREAK CANCELED! (" .. who .. ")")

  if (not silent) and ShouldAnnounceFor(state.duration or 0) then
    DoAnnounce(FormatAnnounceLine("Break Canceled", state.reason, "") .. " (" .. who .. ")")
  end

  if grouped and not fromSync then
    SyncSend("STOP;" .. who)
  end
end

local function ExtendTimer(addSeconds, silent, fromSync, callerName)
  addSeconds = tonumber(addSeconds)
  if not addSeconds or addSeconds <= 0 then return false end

  local grouped = (GetGroupChannel() ~= nil)
  if grouped and not fromSync and not IsPrivilegedLocal() then
    LocalPrint("Only the leader (or raid assist) can extend the break timer.")
    return false
  end

  local who = (callerName and callerName ~= "" and callerName) or Ambiguate(UnitName("player") or "", "short")

  if not state.running then
    return StartTimer(addSeconds, state.reason or "", silent, fromSync, who)
  end

  state.endServer = state.endServer + math.floor(addSeconds + 0.5)
  state.endLocal = GetTime() + (state.endServer - NowServer())
  state.duration = (state.endServer - state.startServer)

  if Remaining() > 10 then
    state.cdStarted = false
  end

  ResetReminderFlags()

  local rem = Remaining()
  ShowBanner("BREAK EXTENDED", "+" .. FormatTime(addSeconds) .. " (" .. FormatTime(rem) .. " left)")

  if (not silent) and ShouldAnnounceFor(state.duration or 0) then
    DoAnnounce(FormatAnnounceLine("Break Extended", state.reason, "+" .. FormatTime(addSeconds)) .. " (" .. who .. ")")
  end

  UpdateBar(rem)
  UpdateBig(rem, math.floor(rem + 0.5))

  if grouped and not fromSync then
    SyncSend(string.format("EXTEND;%d;%s;%d;%d", math.floor(addSeconds + 0.5), who, state.startServer, state.endServer))
  end

  return true
end

-- ------------------------------------------------------------
-- Slash commands
-- ------------------------------------------------------------
local function PrintHelp()
  LocalPrint("Commands:")
  LocalPrint("/break [minutes] [reason]      - start break (no args uses default)")
  LocalPrint("/break +<minutes>              - extend (or start if none running)")
  LocalPrint("/break extend <minutes>        - extend (or start if none running)")
  LocalPrint("/break stop                    - cancel break")
  LocalPrint("/break status                  - show current state")
  LocalPrint("/break options                 - open options")
  LocalPrint("Aliases: /breaktimer /breaktime /bt")
  LocalPrint("Move bar + big timer: hold ALT and drag.")
end

local function ParseInt(tok)
  if not tok or tok == "" then return nil end
  local n = tok:match("^(%d+)$")
  return n and tonumber(n) or nil
end

local function HandleSlash(msg)
  msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")

  if msg == "" then
    local mins = tonumber(db.defaultMinutes) or 5
    StartTimer(mins * 60, "", false, false, Ambiguate(UnitName("player") or "", "short"))
    return
  end

  local first, rest = msg:match("^(%S+)%s*(.-)$")
  first = (first or ""):lower()

  if first == "help" then PrintHelp(); return end
  if first == "options" or first == "opt" or first == "config" then
    if ns.OpenOptions then ns.OpenOptions() end
    return
  end
  if first == "stop" or first == "end" or first == "cancel" then
    StopTimer(false, false, Ambiguate(UnitName("player") or "", "short"))
    return
  end
  if first == "status" then
    if not state.running then
      LocalPrint("No break timer running.")
      return
    end
    local rem = Remaining()
    local who = state.caller ~= "" and state.caller or "?"
    local auth = state.authority or 0
    LocalPrint(string.format("Break running: %s remaining%s. Caller: %s. Authority: %d.",
      FormatTime(rem),
      (state.reason ~= "" and (" (" .. state.reason .. ")") or ""),
      who,
      auth
    ))
    return
  end

  local plus = first:match("^%+(%d+)$")
  if plus then
    local mins = tonumber(plus)
    if mins and mins > 0 then
      ExtendTimer(mins * 60, false, false, Ambiguate(UnitName("player") or "", "short"))
    else
      PrintHelp()
    end
    return
  end

  if first == "extend" then
    local tok = rest:match("^(%S+)")
    local mins = ParseInt(tok or "")
    if mins and mins > 0 then
      ExtendTimer(mins * 60, false, false, Ambiguate(UnitName("player") or "", "short"))
    else
      PrintHelp()
    end
    return
  end

  local mins = ParseInt(first)
  if mins and mins > 0 then
    StartTimer(mins * 60, rest, false, false, Ambiguate(UnitName("player") or "", "short"))
    return
  end

  PrintHelp()
end

SLASH_BREAKTIMERLITE1 = "/break"
SLASH_BREAKTIMERLITE2 = "/breaktimer"
SLASH_BREAKTIMERLITE3 = "/breaktime"
SLASH_BREAKTIMERLITE4 = "/bt"
SlashCmdList["BREAKTIMERLITE"] = HandleSlash

-- ------------------------------------------------------------
-- Version handshake + late-join sync + countdown request/confirm
-- ------------------------------------------------------------
local knownVersions = {}

local function CompareVersions(a, b)
  local function parts(v)
    local x,y,z = v:match("^(%d+)%.(%d+)%.(%d+)$")
    return tonumber(x or 0), tonumber(y or 0), tonumber(z or 0)
  end
  local ax,ay,az = parts(a or "0.0.0")
  local bx,by,bz = parts(b or "0.0.0")
  if ax ~= bx then return ax < bx and -1 or 1 end
  if ay ~= by then return ay < by and -1 or 1 end
  if az ~= bz then return az < bz and -1 or 1 end
  return 0
end

local function Major(v)
  local x = v and v:match("^(%d+)%.") or "0"
  return tonumber(x) or 0
end

local function SendHello()
  if Throttled("Hello", 5.0) then return end
  if GetGroupChannel() == nil then return end
  SyncSend("HELLO;" .. ADDON_VERSION)
end

local function RequestState()
  if Throttled("Request", 2.0) then return end
  if GetGroupChannel() == nil then return end
  SyncSend("REQUEST;" .. ADDON_VERSION)
end

local function SendStateTo(channel, target)
  if not state.running then return end
  local payload = string.format("STATE;%d;%d;%s;%s;%d;%s;%d",
    state.startServer, state.endServer, state.reason or "", state.caller or "",
    state.authority or 0, ADDON_VERSION, (state.cdStarted and 1 or 0)
  )
  C_ChatInfo.SendAddonMessage(PREFIX, payload, channel, target)
end

local function OnAddonMessage(prefix, text, channel, sender)
  if prefix ~= PREFIX then return end
  if sender == UnitName("player") then return end

  local senderShort = Ambiguate(sender, "short")
  local auth = SenderAuthorityRank(sender)

  local action, a, b, c, d, e, f, g = strsplit(";", text)

  if action == "HELLO" then
    local ver = a or "0.0.0"
    knownVersions[senderShort] = ver
    if Major(ver) ~= Major(ADDON_VERSION) then
      LocalPrint("Version mismatch with " .. senderShort .. ": " .. ver .. " (you: " .. ADDON_VERSION .. ")")
    else
      if CompareVersions(ver, ADDON_VERSION) < 0 then
        LocalPrint(senderShort .. " is running older version: " .. ver)
      end
    end
    return
  end

  if action == "REQUEST" then
    if not SenderIsPrivileged(sender) then return end
    if not IsPrivilegedLocal() then return end
    SendStateTo("WHISPER", sender)
    return
  end

  if action == "STATE" then
    if auth < 2 then return end
    local startServer = tonumber(a or 0) or 0
    local endServer = tonumber(b or 0) or 0
    local reason = c or ""
    local caller = d or senderShort
    local authority = tonumber(e or auth) or auth
    local ver = f or "0.0.0"
    local cdFlag = tonumber(g or 0) or 0
    knownVersions[senderShort] = ver

    if startServer > 0 and endServer > startServer then
      if ShouldAcceptRemote(startServer, authority) then
        StartTimerWithServerTimes(startServer, endServer, reason, caller, authority, true, true)
        if cdFlag == 1 then state.cdStarted = true end
      end
    end
    return
  end

  if action == "STOP" then
    if auth < 2 then return end
    local who = a or senderShort
    StopTimer(true, true, who)
    return
  end

  if action == "START" then
    if auth < 2 then return end
    local startServer = tonumber(a or 0) or 0
    local endServer = tonumber(b or 0) or 0
    local reason = c or ""
    local caller = d or senderShort
    local authority = tonumber(e or auth) or auth
    local ver = f or "0.0.0"
    knownVersions[senderShort] = ver

    if startServer > 0 and endServer > startServer then
      if ShouldAcceptRemote(startServer, authority) then
        StartTimerWithServerTimes(startServer, endServer, reason, caller, authority, true, true)
      end
    end
    return
  end

  if action == "EXTEND" then
    if auth < 2 then return end
    local add = tonumber(a or 0) or 0
    local startServer = tonumber(c or 0) or 0
    local endServer = tonumber(d or 0) or 0

    if state.running and startServer == state.startServer and endServer > state.endServer then
      state.endServer = endServer
      state.endLocal = GetTime() + (state.endServer - NowServer())
      state.duration = (state.endServer - state.startServer)

      if Remaining() > 10 then
        state.cdStarted = false
      end

      ResetReminderFlags()

      local rem = Remaining()
      ShowBanner("BREAK EXTENDED", "+" .. FormatTime(add) .. " (" .. FormatTime(rem) .. " left)")
      UpdateBar(rem)
      UpdateBig(rem, math.floor(rem + 0.5))
    elseif (not state.running) and add > 0 then
      RequestState()
    end
    return
  end

  if action == "CDREQUEST" then
    if not IsPrivilegedLocal() then return end
    local startServer = tonumber(a or 0) or 0
    if state.running and startServer == state.startServer and not state.cdStarted then
      if DoBlizzardCountdown10() then
        state.cdStarted = true
        SyncSend("COUNTDOWN;" .. tostring(state.startServer))
      end
    end
    return
  end

  if action == "COUNTDOWN" then
    local startServer = tonumber(a or 0) or 0
    if state.running and startServer == state.startServer then
      state.cdStarted = true
    end
    return
  end
end

-- ------------------------------------------------------------
-- Init + events
-- ------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    local name = ...
    if name ~= ADDON then return end

    BreakTimerDB = CopyDefaults(defaults, BreakTimerDB)
    db = BreakTimerDB

    SetBarSize()
    SetBarPoint()
    SetBigPoint()
    SetBigScale()

    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

    LocalPrint("loaded. /break [minutes] [reason]  (aliases: /breaktimer /breaktime /bt)")
  elseif event == "CHAT_MSG_ADDON" then
    local prefix, text, channel, sender = ...
    OnAddonMessage(prefix, text, channel, sender)
  elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
    if GetGroupChannel() ~= nil then
      SendHello()
      if not state.running then RequestState() end
    end
  end
end)

-- Expose to Options.lua
ns.GetDB = function() return db end
ns.SetBarSize = SetBarSize
ns.SetBarPoint = SetBarPoint
ns.SetBigPoint = SetBigPoint
ns.SetBigScale = SetBigScale
ns.StartTimer = StartTimer
ns.StopTimer = StopTimer
ns.ExtendTimer = ExtendTimer
ns.OpenStatus = function() HandleSlash("status") end
