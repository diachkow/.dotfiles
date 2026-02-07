-- Use system clipboard for Neovim
-- vim.schedule schedules it until `UiEnter` event occurred
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable mouse actions
vim.opt.mouse = "a"

-- Enable following line to have the same indent level as the previous one
vim.opt.breakindent = true

-- Save undo history to a local file
vim.opt.undofile = true

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Smart-case searching (case insensitive unless different-case characters are presented in search)
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update-time (time before saving changes to swap-file on disk)
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Set highlight on search
vim.opt.hlsearch = true

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
