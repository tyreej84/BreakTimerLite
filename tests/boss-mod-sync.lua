-- Run from the addon directory: lua tests/boss-mod-sync.lua
local now, grouped, raid, encounter = 1000, true, false, false
unpack = table.unpack
local sent, registered, frames, deferred = {}, {}, {}, {}
local units = {
  player = { "Local", "Home", true },
  party1 = { "Leader", "Away", true },
  party2 = { "Member", "Home", false },
  raid1 = { "Assistant", "Away", false, true },
}
local function noop() end
local function widget()
  return setmetatable({ scripts = {} }, { __index = function(_, key)
    if key:match("^[a-z_]") then return nil end
    if key == "SetScript" then return function(self, event, fn) self.scripts[event] = fn end end
    if key:match("^Create") or key == "GetStatusBarTexture" then return widget end
    if key == "GetFrameStrata" then return function() return "MEDIUM" end end
    if key:match("^Get") then return function() return 260 end end
    return noop
  end })
end
function CreateFrame(_, name)
  local frame = widget()
  if name then _G[name] = frame end
  frames[#frames + 1] = frame
  return frame
end
UIParent = widget()
SlashCmdList = {}
LE_PARTY_CATEGORY_INSTANCE = 2
function GetTime() return now end
GetServerTime = GetTime
function GetRealmName() return "Home" end
function UnitFullName(unit) local u = units[unit]; if u then return u[1], u[2] end end
UnitName = UnitFullName
function UnitIsGroupLeader(unit) return units[unit] and units[unit][3] end
function UnitIsGroupAssistant(unit) return units[unit] and units[unit][4] end
function IsInGroup(category) return grouped and category ~= 2 end
function IsInRaid() return raid end
function GetNumGroupMembers() return 1 end
function GetNumSubgroupMembers() return 2 end
function IsEncounterInProgress() return encounter end
function Ambiguate(name) return name:match("^[^-]+") end
function strsplit(delimiter, str)
  local result, start = {}, 1
  while true do
    local at = str:find(delimiter, start, true)
    result[#result + 1] = str:sub(start, at and at - 1 or #str)
    if not at then break end
    start = at + #delimiter
  end
  return table.unpack(result)
end
C_Timer = {
  After = function(_, fn) deferred[#deferred + 1] = fn end,
  NewTicker = function() return { Cancel = noop } end,
}
local failSend
local function send(prefix, payload, channel)
  sent[#sent + 1] = { prefix, payload, channel }
  return failSend or 0
end
C_ChatInfo = {
  RegisterAddonMessagePrefix = function(prefix) registered[prefix] = true; return 0 end,
  SendAddonMessage = send, SendAddonMessageLogged = send,
}
Enum = { SendAddonMessageResult = { AddOnMessageLockdown = 11 } }
local ns = {}
assert(loadfile("BossModSync.lua"))("BreakTimerLite", ns)
assert(loadfile("Core.lua"))("BreakTimerLite", ns)
local eventFrame = frames[#frames]
local function event(name, ...) eventFrame.scripts.OnEvent(eventFrame, name, ...) end
event("ADDON_LOADED", "BreakTimerLite")
assert(registered.D5 and registered.BigWigs and registered.BreakTimerLite)
local function active() return ns.GetDB().runtime.activeBreak end
local function packet(prefix, message, sender, channel)
  event("CHAT_MSG_ADDON", prefix, message, channel or "PARTY", sender or "Leader-Away")
end
local function dbm(seconds, sender, channel)
  packet("D5", "Leader-Away\t1\tBT\t" .. seconds, sender, channel)
end
local cases = 0
local function check(name, fn)
  ns.StopTimer(true, true)
  sent = {}
  now = now + 5
  fn()
  cases = cases + 1
  print("PASS " .. name)
end
check("local start broadcasts native and shared protocol", function()
  ns.StartTimer(300, "bio")
  assert(#sent == 2 and sent[2][1] == "D5")
  assert(sent[2][2] == "Local-Home\t1\tBT\t300" and sent[2][3] == "PARTY")
  dbm(300, "Local-Home")
  assert(active().reason == "bio" and #sent == 2)
end)
check("DBM start and cancellation, no rebroadcast", function()
  dbm(300)
  assert(active().endServer == now + 300 and #sent == 0)
  dbm(0)
  assert(not active() and #sent == 0)
end)
check("BigWigs start, duplicate DBM packet and replacement", function()
  packet("BigWigs", "P^Break^600")
  local saved = active()
  dbm(600)
  assert(active() == saved)
  now = now + 2
  packet("BigWigs", "P^Break^900")
  assert(active().endServer == now + 900)
  packet("BigWigs", "P^Break^0")
  assert(not active() and #sent == 0)
end)
check("native metadata survives either packet order", function()
  dbm(300)
  packet("BreakTimerLite", "START;" .. now .. ";" .. (now + 300) .. ";bio;Leader;3;1.4.5")
  assert(active().reason == "bio")
  dbm(300)
  assert(active().reason == "bio")
end)
check("extension and stop broadcast updated remaining time", function()
  dbm(300)
  now = now + 30
  ns.ExtendTimer(120)
  assert(active().endServer == now + 390)
  assert(sent[2][2]:match("BT\t390$"))
  now = now + 2
  ns.StopTimer()
  assert(not active() and sent[4][2]:match("BT\t0$"))
end)
check("compatibility extension arriving first preserves native metadata", function()
  local start = now
  packet("BreakTimerLite", "START;" .. start .. ";" .. (start + 300) .. ";bio;Leader;3;1.4.5")
  now = now + 30
  dbm(390)
  packet("BreakTimerLite", "EXTEND;120;Leader;" .. start .. ";" .. (start + 420))
  assert(active().reason == "bio" and active().startServer == start and active().endServer == start + 420)
end)
check("reject unauthorized, wrong realm, wrong channel and malformed packets", function()
  dbm(300, "Member-Home")
  dbm(300, "Leader-Home")
  dbm(300, "Leader-Away", "GUILD")
  dbm(300, "Leader-Away", "WHISPER")
  for _, value in ipairs({ "-1", "nan", "inf", "59", "3601", "300\textra" }) do dbm(value) end
  packet("D5", "Leader-Away\t1\tPT\t300")
  assert(not active())
end)
check("raid assistant and instance channel", function()
  raid = true
  dbm(300, "Assistant-Away", "INSTANCE_CHAT")
  assert(active() and active().authority == 2)
  raid = false
end)
check("local permissions unchanged, external encounter restriction stays external", function()
  units.player[3] = false
  assert(not ns.StartTimer(300))
  units.player[3] = true
  encounter = true
  dbm(300)
  assert(not active())
  SlashCmdList.BREAKTIMERLITE("5 bio")
  assert(active().endServer == now + 300 and active().reason == "bio")
  SlashCmdList.BREAKTIMERLITE("+60")
  assert(active().endServer == now + 3900)
  SlashCmdList.BREAKTIMERLITE("stop")
  assert(not active())
  encounter = false
end)
check("original slash defaults, long timers, extensions and active-break protection", function()
  SlashCmdList.BREAKTIMERLITE("")
  assert(active().endServer == now + 300)
  SlashCmdList.BREAKTIMERLITE("90 lunch")
  assert(active().endServer == now + 300)
  SlashCmdList.BREAKTIMERLITE("stop")
  SlashCmdList.BREAKTIMERLITE("90 lunch")
  assert(active().endServer == now + 5400 and active().reason == "lunch")
  SlashCmdList.BREAKTIMERLITE("extend 30")
  assert(active().endServer == now + 7200)
  SlashCmdList.BREAKTIMERLITE("stop")
  assert(ns.StartTimer(59) and active().endServer == now + 59)
end)
check("lockdown retry uses remaining time", function()
  failSend = 11
  ns.StartTimer(300)
  failSend = nil
  now = now + 30
  ns.BossModSync.Flush()
  assert(sent[#sent][2]:match("BT\t270$"))
end)
check("queued start followed by stop cannot resurrect timer", function()
  failSend = 11
  ns.StartTimer(300)
  ns.StopTimer()
  failSend = nil
  ns.BossModSync.Flush()
  assert(sent[#sent][2]:match("BT\t0$") and not active())
end)
check("rapid stop waits for receiver throttle and supersedes older controls", function()
  ns.StartTimer(300)
  ns.ExtendTimer(60)
  ns.StopTimer()
  local before = #sent
  now = now + 2
  local work = deferred
  deferred = {}
  for _, fn in ipairs(work) do fn() end
  assert(#sent == before + 1 and sent[#sent][2]:match("BT\t0$") and not active())
end)
print(string.format("%d integration cases passed", cases))
