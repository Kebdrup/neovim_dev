return {
	{
		"Kebdrup/purnell-colorscheme.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("purnell-colorscheme").setup()
		end,
	},
}
