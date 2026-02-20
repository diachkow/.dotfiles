const TERMINAL_APPS = new Set([
  "Terminal",
  "iTerm2",
  "Ghostty",
  "Alacritty",
  "kitty",
  "WezTerm",
  "Warp",
  "Hyper",
])

async function shouldNotify($) {
  try {
    const frontmost = (
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text()
    ).trim()
    if (!frontmost) return true
    return !TERMINAL_APPS.has(frontmost)
  } catch {
    return true
  }
}

export const PermissionBeepPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "permission.asked") return
      if (!(await shouldNotify($))) return

      try {
        await $`afplay /System/Library/Sounds/Glass.aiff`
      } catch {
        try {
          await $`osascript -e 'beep 1'`
        } catch {}
      }
    },
  }
}
