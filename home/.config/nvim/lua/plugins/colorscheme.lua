return {
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function(opts)
  --     require("catppuccin").setup({
  --       flavor = "macchiato",
  --       background = {
  --         light = "latte",
  --         dark = "macchiato",
  --       },
  --       no_italic = true,
  --     })
  --     -- vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },
  {
    "Everblush/nvim",
    name = "everblush",
    config = function()
      require("everblush").setup({
        override = {
          MiniStatuslineModeNormal = { fg = "#141b1e", bg = "#67b0e8", bold = true },
          MiniStatuslineModeInsert = { fg = "#141b1e", bg = "#8ccf7e", bold = true },
          MiniStatuslineModeVisual = { fg = "#141b1e", bg = "#c47fd5", bold = true },
          MiniStatuslineModeReplace = { fg = "#141b1e", bg = "#e57474", bold = true },
          MiniStatuslineModeCommand = { fg = "#141b1e", bg = "#e5c76b", bold = true },
          MiniStatuslineModeOther = { fg = "#141b1e", bg = "#6cbfbf", bold = true },
          MiniStatuslineDevinfo = { fg = "#dadada", bg = "#232a2d" },
          MiniStatuslineFilename = { fg = "#8ccf7e", bg = "#141b1e" },
          MiniStatuslineFileinfo = { fg = "#dadada", bg = "#232a2d" },
          MiniStatuslineInactive = { fg = "#dadada", bg = "#141b1e" },
        },
      })
      vim.cmd.colorscheme("everblush")
    end,
  },
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1001,
  --   config = function()
  --     require("tokyonight").setup({
  --       -- Disable italic style
  --       styles = {
  --         comments = { italic = false },
  --         keywords = { italic = false },
  --       },
  --       -- Borderless telescope config
  --       on_highlights = function(hl, c)
  --         local prompt = "#2d3149"
  --         hl.TelescopeNormal = {
  --           bg = c.bg_dark,
  --           fg = c.fg_dark,
  --         }
  --         hl.TelescopeBorder = {
  --           bg = c.bg_dark,
  --           fg = c.bg_dark,
  --         }
  --         hl.TelescopePromptNormal = {
  --           bg = prompt,
  --         }
  --         hl.TelescopePromptBorder = {
  --           bg = prompt,
  --           fg = prompt,
  --         }
  --         hl.TelescopePromptTitle = {
  --           bg = prompt,
  --           fg = prompt,
  --         }
  --         hl.TelescopePreviewTitle = {
  --           bg = c.bg_dark,
  --           fg = c.bg_dark,
  --         }
  --         hl.TelescopeResultsTitle = {
  --           bg = c.bg_dark,
  --           fg = c.bg_dark,
  --         }
  --       end,
  --     })
  --     vim.cmd.colorscheme("tokyonight-storm")
  --   end,
  -- },
}
