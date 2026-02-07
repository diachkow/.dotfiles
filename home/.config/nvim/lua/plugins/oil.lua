return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
    require("oil").setup({
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,

        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          local hidden_patterns = {
            "^__pycache__$",
            "^%.mypy_cache$",
            "^%.ruff_cache$",
            "^%.pytest_cache$",
            "^%.venv$",
            "^%.git$",
            "^node_modules$",
          }

          for _, pattern in ipairs(hidden_patterns) do
            if name:match(pattern) then
              return true
            end
          end

          return false
        end,
      },
    })

    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    vim.keymap.set("n", "_", "<CMD>Oil .<CR>", { desc = "Open project root directory" })
  end,
}
