return {
  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      local ts_runtime = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"

      -- Prefer Neovim's bundled parser when the plugin-managed one lags behind query changes.
      local function prefer_builtin_parser(lang)
        local bundled_parser

        for _, path in ipairs(vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", true)) do
          if not path:find("/lazy/nvim%-treesitter/parser/") then
            bundled_parser = path
            break
          end
        end

        if bundled_parser then
          pcall(vim.treesitter.language.add, lang, { path = bundled_parser })
        end
      end

      if vim.fn.isdirectory(ts_runtime) == 1 then
        vim.opt.rtp:prepend(ts_runtime)
      end

      prefer_builtin_parser("lua")

      ts.setup({})

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- Sticky top for nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enabled = true,
      min_window_height = 20,
      max_lines = 5,
      multiline_threshold = 1,
      mode = "topline",
    },
  },
}
