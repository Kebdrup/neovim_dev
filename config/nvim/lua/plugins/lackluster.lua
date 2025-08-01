return {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    init = function()
        local lackluster = require("lackluster")
        -- !must called setup() before setting the colorscheme!
        lackluster.setup({
            -- tweak_color allows you to overwrite the default colors in the lackluster theme
            tweak_color = {
                -- you can set a value to a custom hexcode like' #aaaa77' (hashtag required)
                -- or if the value is 'default' or nil it will use lackluster's default color
                -- lack = "#aaaa77",
                lack = "#ffffff",
                luster = "default",
                orange = "default",
                yellow = "default",
                green = "default",
                blue = "#0000aa",
                red = "default",
                -- WARN: Watchout! messing with grays is probs a bad idea, its very easy to shoot yourself in the foot!
                -- black = "#000000",
                -- gray1 = "#000000",
                -- gray2 = "#000000",
                -- gray3 = "default",
                -- gray4 = "default",
                -- gray5 = "default",
                -- gray6 = "default",
                -- gray7 = "default",
                -- gray8 = "default",
                -- gray9 = "#000000",
                
                -- Custom
                black = "#000000",
                gray1 = "#000000",
                gray2 = "#000000",
                gray3 = "default",
                gray4 = "#678dc9", -- Attributes info messages
                gray5 = "#ffffff", -- Tags
                gray6 = "#aaaaaa", -- Brackets
                gray7 = "#67c990", -- Export / Import / props values 
                gray8 = "#ffffff", -- Variables
                gray9 = "default",

            },
            tweak_background = {
                    normal = '#000000',    -- main background
                    -- normal = 'none',    -- transparent
                    -- normal = '#a1b2c3',    -- hexcode
                    -- normal = color.green,    -- lackluster color
                    telescope = '#000000', -- telescope
                    menu = '#000000',      -- nvim_cmp, wildmenu ... (bad idea to transparent)
                    popup = '#000000',     -- lazy, mason, whichkey ... (bad idea to transparent)
                },
        })

        vim.cmd.colorscheme("lackluster-hack")
        -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
        -- vim.cmd.colorscheme("lackluster-mint")
       
        -- Fix highlight of paired brackets
        vim.api.nvim_set_hl(0, "MatchParen", { fg = "#000000", bg = "#888888" })
        vim.api.nvim_set_hl(0, "SnippetTabstop", { fg = "#ffffff", bg = "#000000" })
    end,
}
