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

async function isMainSession(client, sessionID, directory) {
  try {
    const result = await client.session.get({
      path: { id: sessionID },
      query: { directory },
    })
    const session = result.data ?? result

    return !session.parentID
  } catch {
    return true
  }
}

async function shouldBeepForEvent(event, client, directory) {
  if (event.type === "permission.asked") return true
  if (event.type !== "session.idle") return false

  return isMainSession(client, event.properties.sessionID, directory)
}

export const PermissionBeepPlugin = async ({ $, client, directory }) => {
  return {
    event: async ({ event }) => {
      const shouldBeep = await shouldBeepForEvent(event, client, directory)
      if (!shouldBeep) return
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
