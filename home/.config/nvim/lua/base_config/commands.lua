-- Command for copying currently opened relative file path
vim.api.nvim_create_user_command("CopyRelPath", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end, {})
