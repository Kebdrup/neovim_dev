return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter")
      configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", 'typescript', 'python', "tsx", "go" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
      vim.treesitter.language.register('tsx', 'typescriptreact')
      vim.cmd "TSEnable highlight"
    end
 }
