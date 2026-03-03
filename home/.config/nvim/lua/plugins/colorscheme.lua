return {
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
}
