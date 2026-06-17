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
  if (event.type === "question.asked") return true
  if (event.type !== "session.idle") return false

  return isMainSession(client, event.properties.sessionID, directory)
}

export const PermissionBeepPlugin = async ({ $, client, directory }) => {
  return {
    event: async ({ event }) => {
      const shouldBeep = await shouldBeepForEvent(event, client, directory)
      if (!shouldBeep) return

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
