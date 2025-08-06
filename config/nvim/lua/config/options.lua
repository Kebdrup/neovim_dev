vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.signcolumn = "yes"

-- Blinking cursor
vim.o.guicursor = "n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"

-- No python keymaps
vim.g.no_python_maps = true

-- Colors in terminal
vim.opt.termguicolors = true

vim.keymap.set("n", "]]", "<C-]>", { desc = "Jump to tag" })
vim.keymap.set("n", "[[", "<CMD>pop<CR>", { desc = "Go back a tag" })
vim.keymap.set("n", "<C-o>", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<tab>", "<CMD>nohl<CR>", { desc = "Clear highlights" })
vim.keymap.set("n", "<C-.>", vim.lsp.buf.code_action, { desc = "Show code actions" })
vim.keymap.set("n", "<C-,>", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename across files" })
