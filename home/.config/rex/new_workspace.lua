-- Open a new Rex session with three plain shell tabs in a directory.
-- Usage: rex do ~/.config/rex/new_workspace.lua dir=/path [name=label]
local dir = rex.args.dir
if dir == nil or dir == "" then
  error("usage: rex do ~/.config/rex/new_workspace.lua dir=/path [name=label]", 0)
end

local shells = {}
for _, label in ipairs{ "nvim", "test", "vibe" } do
  shells[#shells + 1] = {
    window_label = label,
    layout = rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { cwd = dir },
    },
  }
end

local r, err = rex.call("session.create", {
  label           = rex.args.name or dir:match("[^/]+$"),
  initial_windows = shells,
})
if r == nil then error(err, 0) end
-- switch the app to the new session; needs Remote Control on for CLI calls
pcall(rex.client.queue, "session.select", { session_id = r.session_id })
return { session_id = r.session_id }
