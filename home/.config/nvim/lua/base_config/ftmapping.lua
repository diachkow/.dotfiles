-- [[ FileType mappings ]]
-- This module adds additional filetype mapping for cases, when Neovim is not able to detect filetype
-- by itself
vim.filetype.add({
  filename = {
    -- Associate `uv.lock` files with `toml` filetype
    ["uv.lock"] = "toml",
  },
})
