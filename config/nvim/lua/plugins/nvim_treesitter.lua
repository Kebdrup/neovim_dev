return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter")
      configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", 'typescript', 'python', "tsx", "go", python },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
      vim.treesitter.language.register('tsx', 'typescriptreact')
      vim.api.nvim_set_hl(0, "tsxCloseString", { link = "htmlTag" }) -- Fix green closing tags
      vim.cmd "TSEnable highlight"
    end
 }
