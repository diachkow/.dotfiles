return {
  -- Visual selection for comments
  { "numToStr/Comment.nvim" },

  -- Useful plugin to show you pending keybinds.
  { 
    "folke/which-key.nvim",
    event = "VimEnter",
  },

  -- Highlight todo, notes, etc in comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  -- Notification pop-ups
  { "j-hui/fidget.nvim" },
}
