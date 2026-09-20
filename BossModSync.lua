-- Shared break protocol: D5 <name-realm>\t1\tBT\t<seconds>.
-- Both DBM and BigWigs consume it; BigWigs also emits P^Break^<seconds>.
-- Receive only: never relay another player's packets back to the group.
local _, ns = ...
local sync = {}
ns.BossModSync = sync
local callbacks
local sent = {}
local pending
local lastSend = -math.huge
local revision = 0

function sync.CancelPending()
  revision = revision + 1
  pending = nil
end

local function FullName(unit)
  local name, realm = UnitFullName(unit)
  if not name then return nil end
  realm = (realm and realm ~= "" and realm or GetRealmName()):gsub("[%s-]+", "")
  return name .. "-" .. realm
end

local function SenderUnit(sender)
  if type(sender) ~= "string" or sender == "" then return end
  if not sender:find("-", 1, true) then
    sender = sender .. "-" .. GetRealmName():gsub("[%s-]+", "")
  end
  if FullName("player") == sender then return "player" end
  local raid = IsInRaid()
  local count = raid and GetNumGroupMembers() or GetNumSubgroupMembers()
  for i = 1, count do
    local unit = (raid and "raid" or "party") .. i
    if FullName(unit) == sender then return unit end
  end
end

function sync.InEncounter()
  local check = C_InstanceEncounter and C_InstanceEncounter.IsEncounterInProgress or IsEncounterInProgress
  return check and check() or false
end

function sync.Initialize(config)
  callbacks = config
  for _, prefix in ipairs({ "D5", "BigWigs" }) do
    if not config.register(prefix) then
      config.warn("Warning: boss-addon break synchronization could not be registered.")
    end
  end
end

function sync.Send(seconds)
  if not callbacks then return end
  sync.CancelPending()
  local channel = callbacks.channel()
  if not channel then return end
  seconds = math.max(0, math.ceil(seconds))
  if seconds > 3600 or (seconds > 0 and seconds < 60) then return end
  local request = revision
  -- The receivers throttle starts for up to one second (and some throttle
  -- cancellation too). Coalesce rapid controls instead of losing the last one.
  local elapsed = GetTime() - lastSend
  if elapsed < 1 then
    local target = seconds == 0 and 0 or GetServerTime() + seconds
    C_Timer.After(1.1 - elapsed, function()
      if request ~= revision then return end
      local remaining = target == 0 and 0 or target - GetServerTime()
      sync.Send(remaining >= 60 and remaining or 0)
    end)
    return
  end
  -- Remember our own broadcast before WoW delivers it back to this client.
  sent[seconds] = GetTime()
  local payload = FullName("player") .. "\t1\tBT\t" .. seconds
  local ok, result = callbacks.send(payload, channel, nil, false, "D5")
  if not ok then
    if callbacks.lockdown(result) then
      pending = seconds == 0 and 0 or GetServerTime() + seconds
    else
      callbacks.warn("Warning: the break could not be sent to boss addons.")
    end
  else
    lastSend = GetTime()
    pending = nil
  end
end

function sync.Flush()
  if pending == nil then return end
  local target = pending
  pending = nil
  local seconds = target == 0 and 0 or target - GetServerTime()
  -- Do not resurrect an expired timer after combat.
  sync.Send(seconds >= 60 and seconds or 0)
end

local function Receive(prefix, message, channel, sender)
  if not callbacks or type(message) ~= "string" then return end
  if channel ~= "PARTY" and channel ~= "RAID" and channel ~= "INSTANCE_CHAT" then return end
  if not callbacks.channel() or sync.InEncounter() then return end
  local seconds
  if prefix == "D5" then
    seconds = message:match("^[^\t]+\t1\tBT\t(%d+)$")
  elseif prefix == "BigWigs" then
    seconds = message:match("^P%^Break%^(%d+)$")
  else
    return
  end
  seconds = tonumber(seconds)
  if not seconds or seconds > 3600 or (seconds > 0 and seconds < 60) then return end
  local unit = SenderUnit(sender)
  if not unit then return end
  local authority = UnitIsGroupLeader(unit) and 3 or (IsInRaid() and UnitIsGroupAssistant(unit) and 2 or 0)
  if authority < 2 then return end
  local now = GetTime()
  for duration, stamp in pairs(sent) do
    if now - stamp > 2 then sent[duration] = nil end
  end
  if unit == "player" and sent[seconds] then return end
  sync.CancelPending()
  callbacks.receive(seconds, sender, authority)
end

function sync.Receive(...)
  -- Restricted/secret event arguments must not break the event handler.
  pcall(Receive, ...)
end
