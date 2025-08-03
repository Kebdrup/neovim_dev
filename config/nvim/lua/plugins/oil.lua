return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	-- Optional dependencies
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
	config = function()
		require("oil").setup({
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["<C-h>"] = { "actions.select", opts = { horizontal = true } },
				["<C-Enter>"] = { "actions.select", opts = { vertical = true } },
				["<C-l>"] = false,
				["<C-r>"] = "actions.refresh",
			},
		})
	end,
}
