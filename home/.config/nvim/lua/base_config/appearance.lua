-- Enable 24-bit colors
vim.opt.termguicolors = true

-- Show line numbers
vim.opt.number = true

-- Draw whitespace characters as special symbols
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Disable showing current mode (normal/insert/visual) since it is already covered by statusline
vim.opt.showmode = false

-- Do not wrap lines
vim.opt.wrap = false
