#!/bin/sh

install_dir="/nvim"

mkdir -p $install_dir

apt update 

wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-arm64.appimage -O $install_dir/nvim.appimage
chmod u+x $install_dir/nvim.appimage
(cd $install_dir; ./nvim.appimage --appimage-extract)
ln -s $install_dir/squashfs-root/usr/bin/nvim /usr/bin/nvim && ln -s $install_dir/squashfs-root/usr/bin/nvim /usr/bin/vim

root_dir="/root/.config/nvim"
mkdir -p $root_dir

# Create neovim init.lua file
init_lua=$(cat << EOF
require("config.options")
require("config.lazy")
EOF
)

echo "$init_lua" > $root_dir/init.lua
echo "$root_dir/init.lua created"

mkdir -p $root_dir/lua/config

# Create lua/config/lazy.lua
lazy_lua=$(cat << "EOF"
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim", "ErrorMsg" },
      { out, "WarningMsg" },
      { "Press any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
EOF
)
echo "$lazy_lua" > $root_dir/lua/config/lazy.lua
echo "$root_dir/lua/config/lazy.lua created"

# Create lua/config/options.lua
options_lua=$(cat << "EOF"
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.signcolumn = "yes"
vim.keymap.set("n", "<c-[>", "<c-t>")
EOF
)

echo "$options_lua" > $root_dir/lua/config/options.lua
echo "$root_dir/lua/config/options.lua created"

mkdir -p $root_dir/lua/plugins

### PLUGINS ###

# Depedencies for treesitter
apt install -y nodejs npm build-essential # TODO: nodejs takes a long time to install
echo "Installing tree-sitter-cli"
npm install -g tree-sitter-cli


# Create lua/plugins/lsp_config
lsp_config_lua=$(cat << "EOF"
return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        automatic_enable = true,
        ensure_installed = {"ts_ls"}
    },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        {
            "neovim/nvim-lspconfig",
            config = function()
                vim.api.nvim_create_autocmd('LspAttach', {
                        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                        callback = function(event)
                          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                          -- to define small helper and utility functions so you don't have to repeat yourself.
                          --
                          -- In this case, we create a function that lets us more easily define mappings specific
                          -- for LSP related items. It sets the mode, buffer and description for us each time.
                          local map = function(keys, func, desc, mode)
                            mode = mode or 'n'
                            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                          end

                          -- Rename the variable under your cursor.
                          --  Most Language Servers support renaming across files, etc.
                          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

                          -- Execute a code action, usually your cursor needs to be on top of an error
                          -- or a suggestion from your LSP for this to activate.
                          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

                          -- Find references for the word under your cursor.
                          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                          -- Jump to the implementation of the word under your cursor.
                          --  Useful when your language has ways of declaring types without an actual implementation.
                          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                          -- Jump to the definition of the word under your cursor.
                          --  This is where a variable was first declared, or where a function is defined, etc.
                          --  To jump back, press <C-t>.
                          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                          -- WARN: This is not Goto Definition, this is Goto Declaration.
                          --  For example, in C this would take you to the header.
                          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                          -- Fuzzy find all the symbols in your current document.
                          --  Symbols are things like variables, functions, types, etc.
                          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

                          -- Fuzzy find all the symbols in your current workspace.
                          --  Similar to document symbols, except searches over your entire project.
                          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

                          -- Jump to the type of the word under your cursor.
                          --  Useful when you're not sure what type a variable is and you want to see
                          --  the definition of its *type*, not where it was *defined*.
                          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

                          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                          ---@param client vim.lsp.Client
                          ---@param method vim.lsp.protocol.Method
                          ---@param bufnr? integer some lsp support methods only in specific files
                          ---@return boolean
                          local function client_supports_method(client, method, bufnr)
                            if vim.fn.has 'nvim-0.11' == 1 then
                              return client:supports_method(method, bufnr)
                            else
                              return client.supports_method(method, { bufnr = bufnr })
                            end
                          end

                          -- The following two autocommands are used to highlight references of the
                          -- word under your cursor when your cursor rests there for a little while.
                          --    See `:help CursorHold` for information about when this is executed
                          --
                          -- When you move your cursor, the highlights will be cleared (the second autocommand).
                          local client = vim.lsp.get_client_by_id(event.data.client_id)
                          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                              buffer = event.buf,
                              group = highlight_augroup,
                              callback = vim.lsp.buf.document_highlight,
                            })

                            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                              buffer = event.buf,
                              group = highlight_augroup,
                              callback = vim.lsp.buf.clear_references,
                            })

                            vim.api.nvim_create_autocmd('LspDetach', {
                              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                              callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                              end,
                            })
                          end

                          -- The following code creates a keymap to toggle inlay hints in your
                          -- code, if the language server you are using supports them
                          --
                          -- This may be unwanted, since they displace some of your code
                          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                            map('<leader>th', function()
                              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                            end, '[T]oggle Inlay [H]ints')
                          end
                        end,
                      })

                      -- Diagnostic Config
                      -- See :help vim.diagnostic.Opts
                      vim.diagnostic.config {
                        severity_sort = true,
                        float = { border = 'rounded', source = 'if_many' },
                        underline = { severity = vim.diagnostic.severity.ERROR },
                        signs = vim.g.have_nerd_font and {
                          text = {
                            [vim.diagnostic.severity.ERROR] = '󰅚 ',
                            [vim.diagnostic.severity.WARN] = '󰀪 ',
                            [vim.diagnostic.severity.INFO] = '󰋽 ',
                            [vim.diagnostic.severity.HINT] = '󰌶 ',
                          },
                        } or {},
                        virtual_text = {
                          source = 'if_many',
                          spacing = 2,
                          format = function(diagnostic)
                            local diagnostic_message = {
                              [vim.diagnostic.severity.ERROR] = diagnostic.message,
                              [vim.diagnostic.severity.WARN] = diagnostic.message,
                              [vim.diagnostic.severity.INFO] = diagnostic.message,
                              [vim.diagnostic.severity.HINT] = diagnostic.message,
                            }
                            return diagnostic_message[diagnostic.severity]
                          end,
                        },
                      }
                      vim.keymap.set("n", "K", function()
                            vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
                          end, {})
            end
        },
    },
}
EOF
)

echo "$lsp_config_lua" > $root_dir/lua/plugins/lsp_config.lua
echo "$root_dir/lua/plugins/lsp_config.lua created"

add_plugin () {
	echo "$2" > $root_dir/lua/plugins/$1.lua
	echo "$root_dir/lua/plugins/$1.lua created"
}

add_plugin "lackluster" "$(cat << "EOF"
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
                lack = "default",
                luster = "default",
                orange = "default",
                yellow = "default",
                green = "default",
                blue = "default",
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
    end,
}
EOF
)"

add_plugin "nvim_treesitter" "$(cat << "EOF"
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter")

      configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", 'typescript', 'python' },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
    end
 }
EOF
)"

add_plugin "telescope" "$(cat << "EOF"
return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
}
EOF
)"

add_plugin "lualine" "$(cat << "EOF"
return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup({
          options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = ''},
            section_separators = { left = '', right = ''},
            disabled_filetypes = {
              statusline = {},
              winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            always_show_tabline = true,
            globalstatus = false,
            refresh = {
              statusline = 100,
              tabline = 100,
              winbar = 100,
            }
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {},
          winbar = {},
          inactive_winbar = {},
          extensions = {}
        })
    end
}
EOF
)"

add_plugin "conform" "$(cat << "EOF"
return {
  'stevearc/conform.nvim',
  opts = {
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "ruff", "isort", "black" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  }
}
EOF
)"

add_plugin "blink_cmp" "$(cat << "EOF"
return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default' },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = true } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
EOF
)"
