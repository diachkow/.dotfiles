return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      vim.o.background = "dark"
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
