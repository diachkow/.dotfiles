return {
  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "lua",
          "markdown",
          "vim",
          "vimdoc",
          "dockerfile",
          "just",
          -- Python and related
          "python",
          "toml",
          "rst",
          "ninja",
          -- js and related
          "javascript",
          "typescript",
          -- go
          "go",
          "gosum",
          "gomod",
          -- misc
          "html",
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = { enable = true },

        -- Disabled as treesitter auto-indentation works weird
        -- in Python
        indent = { enable = false },
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
