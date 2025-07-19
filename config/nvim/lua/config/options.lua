vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.signcolumn = "yes"

vim.keymap.set("n", "]]", "<C-]>", { desc = "Jump to tag" })
vim.keymap.set("n", "[[", "<CMD>pop<CR>", { desc = "Go back a tag" })
vim.keymap.set("n", "<C-o>", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<tab>", "<CMD>nohl<CR>", { desc = "Clear highlights" })
vim.keymap.set("n", "<C-.>", vim.lsp.buf.code_action, { desc = "Show code actions" })
vim.keymap.set("n", "<C-,>", vim.diagnostic.open_float, { desc = "Show diagnostic float" })

