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
      },
      specs = {
        github_dark_high_contrast = {
          syntax = {
            bracket = "#ff0000",
            bultin0 = "#ff0000", -- Camel part of reguar tags
            bultin1 = "#ffffff", -- Camel part of reguar tags
            bultin2 = "#0000ff", -- Camel part of reguar tags
            comment = "#ff0000",
            conditional = "#ff0000",
            const = "#ffffff",
            dep = "#ff0000",
            field = "#0000ff",
            func = "#ffffff", -- JSX tags
            ident = "#0000ff",
            keyword = "#0000ff",
            number = "#0000ff",
            operator = "#0000ff",
            preproc = "#0000ff",
            regex = "#0000ff",
            statement = "#0000ff",
            string = "#0000ff",
            type = "#ffffff", -- Camel part of reguar tags
            variable = "#ff0000"
          }
        }
      }
    })
    -- vim.cmd.colorscheme("github_dark_high_contrast")
  end,
} 
