import { defineHexConfig } from "@hex/commands"

// Hex runs this file itself and reloads it when you save. It is plain
// TypeScript or JavaScript with no npm packages, filesystem, or network:
// transformations return text.
export default defineHexConfig({
  // Transformations appear as optional final steps in every dictation mode.
  transformations: {
    "trim-whitespace": {
      name: "Trim whitespace",
      description: "Remove leading whitespace only",
      // Trailing whitespace is kept on purpose: removing it glues the next
      // dictation straight onto this one's last word.
      transform: (text) => text.trimStart(),
    },
    "symbols": {
      name: "Symbols",
      description: "Spoken symbol words become real symbols",
      // Surrounding spaces are collapsed so "home slash dot config"
      // pastes as home/.config. Trade-off: "slash"/"dot" etc. must not
      // appear as words in normal prose worth dictating.
      transform: (text) =>
        text
          .replace(/\s+slash\s+/gi, "/")
          .replace(/\s+backslash\s+/gi, "\\")
          .replace(/\s+(period|dot)\s+/gi, "."),
    },
  },
})
