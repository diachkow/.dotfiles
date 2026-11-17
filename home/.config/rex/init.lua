-- Migrated from ~/.config/ghostty/config and ~/.config/herdr/config.toml
rex.bind("shift+cmd+r", "client.config.reload")

-- New session with three plain shell tabs in the focused pane's directory
rex.action{
  name  = "workspace",
  title = "New Workspace Here (3 shells)",
  description = "Creates a new session with three plain shell tabs in the working directory of the focused pane.",
  run   = function(ctx, args)
    if ctx.block_id == nil then error("run this from a terminal pane", 0) end
    local p = rex.block.call("com.superlogical.terminal", "pwd", {})
    local dir = p and p.pwd or nil
    if dir == nil or dir == "" then error("this pane has not reported a directory", 0) end
    dir = dir:gsub("^file://", "")
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
      label           = dir:match("[^/]+$"),
      initial_windows = shells,
    })
    if r == nil then error(err, 0) end
    -- switch the app to the new session; harmless no-op if the client refuses
    pcall(rex.client.queue, "session.select", { session_id = r.session_id })
    return { session_id = r.session_id }
  end,
}

-- tmux-style prefix: ctrl+b enters a one-shot mode; its keys run commands;
-- Esc or the command itself leaves the mode. rex.mode only sets exclusive.
rex.mode("tmux", { exclusive = true })
rex.bind("ctrl+b", "client.mode.enter", { name = "tmux", once = true })

rex.bind("tmux/c", "client.tab.new")
rex.bind("tmux/n", "client.tab.next")
rex.bind("tmux/p", "client.tab.previous")
for i = 1, 9 do
  rex.bind("tmux/" .. tostring(i), "client.tab.goto", { index = i })
end
rex.bind("tmux/shift+\\", "pane.split", { direction = "right" })
rex.bind("tmux/-", "pane.split", { direction = "down" })
rex.bind("tmux/h", "pane.focus.left")
rex.bind("tmux/j", "pane.focus.down")
rex.bind("tmux/k", "pane.focus.up")
rex.bind("tmux/l", "pane.focus.right")
rex.bind("tmux/[", "pane.copy_mode.enter")
rex.bind("tmux/]", "pane.paste")
rex.bind("tmux/x", "pane.close")
rex.bind("tmux/z", "pane.zoom")
rex.bind("tmux/s", "session.switch")

-- switch to the Nth session in the sidebar order; missing index does nothing
rex.action{
  name  = "session_by_index",
  title = "Go to Session by Index",
  args  = { index = "integer" },
  run   = function(ctx, args)
    local l = rex.call("session.list")
    local s = l and l.sessions and l.sessions[args.index]
    if not s then return end
    rex.client.queue("session.select", { session_id = s.session_id })
  end,
}
for i = 1, 9 do
  rex.bind("tmux/shift+" .. tostring(i), "session_by_index", { index = i })
end

-- sticky resize submode: arrows resize, shift+arrows bigger steps, = balances
rex.mode("resize", { exclusive = true })
rex.bind("tmux/r", "client.mode.enter", { name = "resize" })
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/shift+left", "pane.resize", { direction = "left", amount = 5 })
rex.bind("resize/shift+right", "pane.resize", { direction = "right", amount = 5 })
rex.bind("resize/shift+up", "pane.resize", { direction = "up", amount = 5 })
rex.bind("resize/shift+down", "pane.resize", { direction = "down", amount = 5 })
rex.bind("resize/=", "pane.balance")

-- double prefix sends ctrl+b to the running program (readline, less, ...)
rex.bind("tmux/ctrl+b", "pane.send_key", { key = "ctrl+b" })
