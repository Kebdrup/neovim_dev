vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.signcolumn = "yes"

vim.keymap.set("n", "<c-[>", "<c-t>")
vim.keymap.set("n", "<c-o>", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
