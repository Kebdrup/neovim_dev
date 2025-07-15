return {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    local theme = require("github-theme")
    theme.setup({
      palettes = {
        -- Custom duskfox with black background
        github_dark_high_contrast = {
          bg1 = '#000000', -- Black background
          bg0 = '#000000', -- Alt backgrounds (floats, statusline, ...)
          bg3 = '#000000', -- 55% darkened from stock
          sel0 = '#000000', -- 55% darkened from stock
        },
      },
      groups = {
        all = {
          Normal = { bg = '#000000' },
          NormalNC = { bg = '#000000' },
          NormalFloat = { bg = '#000000' },
        }
      }
    })
    vim.cmd.colorscheme("github_dark_high_contrast")
  end,
} 
