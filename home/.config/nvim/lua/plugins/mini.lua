return {
  "echasnovski/mini.statusline",
  dependencies = {
    { "echasnovski/mini.icons" },
  },
  config = function(opts)
    require("mini.icons").setup()

    local statusline = require("mini.statusline")
    statusline.setup({
      use_icons = true,
      section_location = function()
        return "%2l:%-2v"
      end,
    })
  end,
}
