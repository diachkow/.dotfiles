-- agent-notify.lua: sound when an agent stops generating (message ready).
-- Started automatically by init.lua; run manually with: rex do agent-notify.lua --all
--
-- Notification banners stay Rex's own: Settings > Notifications > Program
-- Activity > Done sends a Rex-owned notification (click opens the tab) while
-- Rex is in the background, for agents that report state=done. pi does;
-- opencode does not (anomalyco/opencode#60411) — it drops from working to
-- idle, so this script watches that transition too and adds the missing
-- completion sound, which Rex plays only from its own Done state.
-- shortcut: remove the afplay call if Rex's built-in Done sound ever doubles up

local last = {}

rex.on("terminal.program_status_changed", function(ctx, ev)
  local r = ev.record
  if r == nil or r.state == nil then return end
  local key = ctx.block_id .. "|" .. (ev.id or "")
  local prev = last[key]
  last[key] = r.state
  local app = r.app or r.effective_app or "agent"
  if r.state == "done"
      or (r.state == "idle" and prev == "working" and app == "opencode") then
    -- shortcut: opencode reports idle instead of done (#60411); also fires on run cancel
    rex.exec{ "afplay", "/System/Library/Sounds/Glass.aiff" }
  end
end)
