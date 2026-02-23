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

      if vim.fn.isdirectory(ts_runtime) == 1 then
        vim.opt.rtp:prepend(ts_runtime)
      end

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
