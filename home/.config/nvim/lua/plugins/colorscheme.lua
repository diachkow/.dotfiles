return {
  {
    "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    config = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_foreground = "mix"
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
}
