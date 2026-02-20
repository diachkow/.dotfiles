function isGhosttyApp(appName) {
  return /ghostty/i.test(appName)
}

async function shouldNotify($) {
  try {
    const frontmost = (
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text()
    ).trim()
    if (!frontmost) return true
    return !isGhosttyApp(frontmost)
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
