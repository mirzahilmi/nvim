-- ============================================================================
-- OPTIONS
-- ============================================================================

vim.opt.termguicolors = true

vim.opt.relativenumber = true -- relative line numbers
vim.opt.wrap = false -- do not wrap lines by default
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.opt.tabstop = 2 -- tabwidth
vim.opt.shiftwidth = 2 -- indent width
vim.opt.numberwidth = 1
vim.opt.textwidth = 80 -- text width until wrapped with `gw` motion
vim.opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current line
vim.opt.breakindent = true -- enable break indent
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in string
vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true -- show matches as you type

vim.opt.signcolumn = "yes" -- always show a sign column
vim.opt.colorcolumn = "100" -- show a column at 100 position chars
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.cmdheight = 1 -- embedded command line
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- do not show the mode, instead have it in statusline
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.winblend = 0 -- floating window transparency
vim.opt.conceallevel = 0 -- do not hide markup
vim.opt.concealcursor = "" -- do not hide cursorline in markup
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = {
  eob = " ", -- hide "~" on empty lines
  -- fold things, thanks to https://www.reddit.com/r/neovim/comments/1t3aftx/comment/ojvnyqj
  fold = " ",
  foldopen = "▾",
  foldclose = "▸",
  foldinner = " ",
  foldsep = " ",
}

local undodir = vim.fn.expand "~/.vim/undodir"
if
  vim.fn.isdirectory(undodir) == 0 -- create undodir if nonexistent
then
  vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false -- do not create a backup file
vim.opt.writebackup = false -- do not write to a backup file
vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- do create an undo file
vim.opt.undodir = undodir -- set the undo directory
vim.opt.updatetime = 300 -- faster completion
vim.opt.timeoutlen = 500 -- timeout duration
vim.opt.ttimeoutlen = 0 -- key code timeout
vim.opt.autoread = true -- auto-reload changes if outside of neovim
vim.opt.autowrite = false -- do not auto-save
vim.opt.confirm = true -- raise a dialog asking if you wish to save the current file

vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false -- no error sounds
vim.opt.backspace = "indent,eol,start" -- better backspace behaviour
vim.opt.autochdir = false -- do not autochange directories
vim.opt.iskeyword:append "-" -- include - in words
vim.opt.path:append "**" -- include subdirs in search
vim.opt.selection = "inclusive" -- include last char in selection
vim.opt.mouse = "a" -- enable mouse support
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.encoding = "utf-8" -- set encoding

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldenable = true -- enable fold yk
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append "linematch:60" -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      -- see https://github.com/rust-lang/rust-analyzer/discussions/17881#discussioncomment-10351763
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = false,
          extraArgs = { "--release" },
          allTargets = false,
        },
      },
    },
  },
}
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Disable entire built-in ftplugin mappings to avoid conflicts.
-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
vim.g.no_plugin_maps = true

vim.filetype.add { extension = { zul = "html" } }
vim.filetype.add {
  pattern = {
    [".*/*.cf.yaml"] = "cloudformation",
  },
}

-- see https://www.reddit.com/r/neovim/comments/1byy8lu/copying_to_the_windows_clipboard_from_wsl2
if vim.fn.has "wsl" == 1 then
  vim.g.clipboard = {
    name = "win_clipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = "powershell.exe Get-Clipboard",
      ["*"] = "powershell.exe Get-Clipboard",
    },
    cache_enabled = 0,
  }
  vim.keymap.set({ "n", "v" }, "y", '"+y', { noremap = true, silent = true })
  vim.keymap.set({ "n", "v" }, "p", '"+p', { noremap = true, silent = true })
end

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- Exit terminal mode in the builtin terminal.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
-- see https://www.reddit.com/r/neovim/comments/1fq0y8u/comment/lp2ez92
vim.keymap.set({ "x" }, "y", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<Esc>", function() vim.cmd "nohlsearch" end, { silent = true })
-- thanks to https://github.com/saghen/blink.cmp/discussions/2218#discussioncomment-14803834
-- clear snippet placeholder highlight on exit to normal mode
vim.keymap.set({ "i", "s" }, "<ESC>", function()
  if vim.snippet then vim.snippet.stop() end
  return "<ESC>"
end, { expr = true })
-- thanks to https://github.com/pawelgrzybek/dotfiles/blob/master/nvim/lua/keymaps.lua#L92-L107
-- incremental outter selection treesitter/lsp
vim.keymap.set({ "n", "x", "o" }, "<A-o>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = "Select parent treesitter node or outer incremental lsp selections" })
-- incremental outter selection treesitter/lsp
vim.keymap.set({ "n", "x", "o" }, "<A-i>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = "Select child treesitter node or inner incremental lsp selections" })
vim.keymap.set("n", "<C-t>", vim.diagnostic.setqflist)

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight when yanking (copying) text",
  callback = function() vim.highlight.on_yank() end,
})

-- Return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    if vim.o.diff then -- except in diff mode
      return
    end

    local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
    local last_line = vim.api.nvim_buf_line_count(0)

    local row = last_pos[1]
    if row < 1 or row > last_line then return end

    pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
  end,
})

-- No auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_comment", {}),
  callback = function() vim.opt_local.formatoptions:remove { "c", "r", "o" } end,
})

-- ============================================================================
-- PLUGINS
-- ============================================================================

local lze = require "lze"
lze.load {
  { "nvim-web-devicons", lazy = true, dep_of = { "fzf-lua", "trouble.nvim" } },
  { "nvim-nio", lazy = true, dep_of = { "nvim-dap" } },
  { "plenary.nvim", lazy = true, dep_of = { "todo-comments.nvim" } },
  { "nui.nvim", lazy = true, dep_of = { "noice.nvim" } },
  { "friendly-snippets", lazy = true, dep_of = { "blink.cmp" } },
}

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- LSP, Completions, Snippets
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
local servers = {
  basedpyright = {},
  phpactor = {},
  arduino_language_server = {},
  lemminx = {},
  protols = {},
  terraformls = {},
  ruff = {},
  gopls = {},
  biome = {},
  elp = {},
  tailwindcss = {},
  qmlls = { cmd = { "qmlls", "-E" } },
  nixd = {
    settings = {
      nixd = {
        nixpkgs = {
          expr = [[
                  let
                    flake = builtins.getFlake "/home/mirza/nixfilesv2/";
                  in import flake.inputs.nixpkgs {
                    overlays = builtins.attrValues flake.outputs.overlays;
                  }
                ]],
        },
        options = {
          nixos = {
            expr = '(builtins.getFlake "/home/mirza/nixfiles2").nixosConfigurations."t4nix".options',
          },
          home_manager = {
            expr = '(builtins.getFlake "/home/mirza/nixfiles2").homeConfigurations."mirza@t4nix".options',
          },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = "Replace" },
        diagnostics = {
          globals = { "nixCats", "vim" },
          disable = { "missing-fields" },
        },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        validate = false,
        hover = true,
        completion = true,
        format = { enable = true, bracketSpacing = true },
        schemaStore = { enable = true },
      },
    },
  },
  texlab = {
    settings = {
      texlab = {
        build = { onSave = true, forwardSearchAfter = true },
        forwardSearch = {
          executable = "zathura",
          args = { "--synctex-forward", "%l:1:%f", "%p" },
        },
      },
    },
  },
  tsgo = {
    on_attach = function(client, _) client.server_capabilities.codeActionProvider = false end,
    settings = {
      typescript = {
        format = { enable = false },
        preferences = {
          quoteStyle = "double",
          -- Thanks to https://github.com/LazyVim/LazyVim/discussions/1124#discussioncomment-10237303
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          importModuleSpecifier = "non-relative",
        },
      },
    },
  },
  -- complementary lsp with tsgo solely for better code action, remove later
  -- when tsgo code action become better
  vtsls = {
    on_attach = function(client, _)
      -- taken from https://github.com/sergiornelas/nvim/blob/261d3b8bb633e0c9a7253d9b5243d9e985a56f5f/lua/plugins/lsp/capabilities/tsgo.lua
      -- based on https://www.reddit.com/r/neovim/comments/1rxc29w/comment/ob8varr

      local caps = client.server_capabilities

      -- UX / interaction
      caps.hoverProvider = false
      caps.completionProvider = false
      caps.definitionProvider = false
      caps.declarationProvider = false
      caps.implementationProvider = false
      caps.referencesProvider = false
      caps.renameProvider = false
      caps.signatureHelpProvider = false
      caps.documentHighlightProvider = false

      -- symbols / navegation
      caps.documentSymbolProvider = false
      caps.workspaceSymbolProvider = false

      -- format / tokens
      caps.documentFormattingProvider = false
      caps.documentRangeFormattingProvider = false
      caps.semanticTokensProvider = nil

      -- other
      caps.typeDefinitionProvider = false
      caps.callHierarchyProvider = false
      caps.selectionRangeProvider = false
      caps.inlayHintProvider = false
    end,
  },
}

lze.load {
  {
    "nvim-lspconfig",
    -- see https://www.reddit.com/r/neovim/comments/1nb0w5k/comment/nczrv70
    lazy = false,
    after = function()
      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          vim.keymap.set(
            "n",
            "<leader>th",
            function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end,
            { desc = "[T]oggle Inlay [H]ints" }
          )

          vim.diagnostic.config {
            severity_sort = true,
            float = { border = "rounded", source = "if_many" },
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = {
              text = {
                [vim.diagnostic.severity.ERROR] = "󰅚 ",
                [vim.diagnostic.severity.WARN] = "󰀪 ",
                [vim.diagnostic.severity.INFO] = "󰋽 ",
                [vim.diagnostic.severity.HINT] = "󰌶 ",
              },
            },
            virtual_text = {
              source = "if_many",
              spacing = 2,
              current_line = true,
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
        end,
      })
    end,
  },
  {
    "blink.cmp",
    lazy = true,
    event = { "InsertEnter", "CmdlineEnter" },
    after = function()
      require("blink.cmp").setup {
        sources = {
          default = { "lsp", "path", "buffer", "snippets", "omni" },
          providers = { snippets = { opts = { extended_filetypes = { typescriptreact = { "html" } } } } },
        },
        fuzzy = { implementation = "prefer_rust" },
        appearance = { nerd_font_variant = "mono" },
        completion = {
          list = { selection = { auto_insert = false } },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            window = { border = "single" },
          },
        },
      }
    end,
  },
  {
    "nvim-jdtls",
    lazy = true,
    ft = "java",
    after = function()
      local config = {
        cmd = {
          vim.env.JDTLS_BIN_PATH,
          string.format("--jvm-arg=-javaagent:%s", vim.env.LOMBOK_JAR_PATH),
          "--jvm-arg=-Xmx4g",
        },

        settings = {
          java = {
            settings = { url = vim.fn.stdpath "config" .. "/org.eclipse.jdt.core.formatter.prefs" },
            completion = {
              favoriteStaticMembers = {
                "org.mockito.Mockito.*",
                "org.mockito.ArgumentMatchers.*",
                "org.assertj.core.api.Assertions.*",
                "org.springframework.test.web.client.match.MockRestRequestMatchers.*",
                "org.springframework.test.web.client.response.MockRestResponseCreators.*",
              },
              importOrder = {
                "java",
                "javax",
                "jakarta",
                "com",
                "org",
                "id",
              },
              maxResults = 50,
            },
            saveActions = { organizeImports = true },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              useBlocks = true,
              addFinalForNewDeclaration = "all",
            },
            contentProvider = { preferred = "fernflower" },
          },
        },

        init_options = { bundles = {} },

        handlers = {
          ["language/status"] = function() end,
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function() require("jdtls").start_or_attach(config) end,
      })

      require("jdtls").start_or_attach(config)
    end,
  },
  {
    "roslyn.nvim",
    lazy = true,
    ft = { "cs", "razor", "cshtml" },
    after = function() require("roslyn").setup {} end,
  },
  {
    "rustaceanvim",
    -- already lazy, as the docs said
    lazy = false,
    after = function()
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.rs",
        callback = function()
          local cwd = vim.lsp.buf.list_workspace_folders()
          if not (cwd == nil) then
            if vim.fn.filereadable(cwd[1] .. "/Dioxus.toml") == 1 then
              local command = "dx fmt --file %"
              vim.cmd("silent ! " .. command)
            end
          end
        end,
      })
    end,
  },
  {
    "go.nvim",
    lazy = true,
    ft = { "go", "gomod" },
    after = function()
      require("go").setup {
        lsp_keymaps = false,
        lsp_cfg = false,
        icons = false,
        dap_debug = false,
      }

      -- see https://github.com/ray-x/go.nvim?tab=readme-ov-file#run-gofmt--goimports-on-save
      local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function() require("go.format").goimports() end,
        group = format_sync_grp,
      })

      vim.lsp.inlay_hint.enable(false)
    end,
  },
}

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Highlighting, Formatting, Lint
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lze.load {
  {
    "nvim-treesitter",
    lazy = false,
    after = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          -- check if parser exists and load it
          if not vim.treesitter.language.add(language) then return end
          -- enables syntax highlighting and other treesitter features
          vim.treesitter.start(buf, language)

          -- enables treesitter based folds
          -- for more info on folds see `:help folds`
          -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- vim.wo.foldmethod = 'expr'

          -- enables treesitter based indentation
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "conform.nvim",
    lazy = true,
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = "<leader>f",
    after = function()
      local conform = require "conform"
      conform.setup {
        notify_on_error = false,
        format_after_save = function(bufnr)
          local disable_filetypes = {
            c = true,
            cpp = true,
            java = true,
            typescript = true,
            typescriptreact = true,
          }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = "never"
          else
            lsp_format_opt = "fallback"
          end
          return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
          }
        end,
        formatters_by_ft = {
          lua = { "stylua" },
          nix = { "alejandra" },
          tex = { "latexindent" },
          html = { "biome" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
        },
      }
      vim.keymap.set("n", "<leader>f", function() conform.format { async = true, lsp_format = "fallback" } end)
    end,
  },
  {
    "nvim-lint",
    lazy = true,
    event = { "BufReadPost" },
    after = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        cloudformation = { "cfn_lint" },
        dockerfile = { "hadolint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then lint.try_lint() end
        end,
      })
    end,
  },
}

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Debugger (DAP)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lze.load {
  {
    "nvim-dap-view",
    lazy = true,
    on_plugin = "nvim-dap",
    after = function()
      local dapview = require "dap-view"
      dapview.setup {
        auto_toggle = true,
        winbar = {
          controls = { enabled = true },
          sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
          default_section = "console",
        },
      }
      vim.keymap.set("n", "<F7>", dapview.toggle)
      vim.keymap.set("n", "<leader>dw", dapview.add_expr)
    end,
  },
  {
    "nvim-dap",
    lazy = true,
    event = "DeferredUIEnter",
    after = function()
      local dap = require "dap"

      -- remap .vscode/launch.json location to dap.jsonc
      -- .vscode folder in a project are too sussy baka
      local getconfig = require("dap.ext.vscode").getconfigs
      require("dap.ext.vscode").getconfigs = function() return getconfig(vim.fn.getcwd() .. "/dap.jsonc") end

      -- Go
      -- see https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
      dap.adapters.delve = function(callback, config)
        if config.mode == "remote" and config.request == "attach" then
          callback {
            type = "server",
            host = config.host or "127.0.0.1",
            port = config.port or "38697",
          }
        else
          callback {
            type = "server",
            port = "${port}",
            executable = {
              command = "dlv",
              args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
              detached = vim.fn.has "win32" == 0,
            },
          }
        end
      end
      -- TypeScript (and JavaScript also i think)
      -- bug https://github.com/mfussenegger/nvim-dap/issues/1492
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug",
          args = { "${port}" },
        },
      }

      vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
      vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
      local breakpoint_icons = vim.g.have_nerd_font
          and {
            Breakpoint = "",
            BreakpointCondition = "",
            BreakpointRejected = "",
            LogPoint = "",
            Stopped = "",
          }
        or {
          Breakpoint = "●",
          BreakpointCondition = "⊜",
          BreakpointRejected = "⊘",
          LogPoint = "◆",
          Stopped = "⭔",
        }
      for type, icon in pairs(breakpoint_icons) do
        local tp = "Dap" .. type
        local hl = (type == "Stopped") and "DapStop" or "DapBreak"
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      vim.keymap.set("n", "<F5>", dap.continue)
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)

      -- load nvim-dap-view after dap configured
      lze.trigger_load { "nvim-dap-view" }
    end,
  },
}

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UI
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lze.load {
  {
    "fzf-lua",
    lazy = true,
    event = "DeferredUIEnter",
    after = function()
      local fzflua = require "fzf-lua"
      fzflua.setup {
        "border-fused",
        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 100,
          },
          extensions = {
            ["png"] = { "chafa" },
            ["svg"] = { "chafa" },
            ["jpg"] = { "chafa" },
          },
        },
      }

      -- - "gra" (Normal and Visual mode) is mapped to |vim.lsp.buf.code_action()|
      -- - "gri" is mapped to |vim.lsp.buf.implementation()|
      -- - "grn" is mapped to |vim.lsp.buf.rename()|
      -- - "grr" is mapped to |vim.lsp.buf.references()|
      -- - "grt" is mapped to |vim.lsp.buf.type_definition()|
      -- - "grx" is mapped to |vim.lsp.codelens.run()|
      -- - "gO" is mapped to |vim.lsp.buf.document_symbol()|
      -- - CTRL-S (Insert mode) is mapped to |vim.lsp.buf.signature_help()|
      -- - |v_an| and |v_in| fall back to LSP |vim.lsp.buf.selection_range()| if
      --   treesitter is not active.
      -- - |gx| handles `textDocument/documentLink`. Example: with gopls, invoking gx
      --   on "os" in this Go code will open documentation externally: >
      fzflua.register_ui_select(function(_, items)
        local min_h, max_h = 0.15, 0.70
        local h = (#items + 4) / vim.o.lines
        if h < min_h then
          h = min_h
        elseif h > max_h then
          h = max_h
        end
        return { winopts = { height = h, width = 0.60, row = 0.40 } }
      end)

      -- Keymaps
      vim.keymap.set("n", "<leader>sh", fzflua.helptags)
      vim.keymap.set("n", "<leader>sk", fzflua.keymaps)
      vim.keymap.set("n", "<leader>sm", fzflua.marks)
      vim.keymap.set(
        "n",
        "<leader>sf",
        function()
          fzflua.files {
            actions = { ["ctrl-g"] = { require("fzf-lua").actions.toggle_ignore } },
            formatter = "path.filename_first",
            previewer = false,
            winopts = {
              height = 0.70,
              width = 0.50,
            },
          }
        end
      )
      vim.keymap.set(
        "n",
        "<leader>sg",
        function()
          fzflua.live_grep {
            winopts = {
              preview = {
                layout = "vertical",
                vertical = "down:40%",
              },
            },
            formatter = "path.filename_first",
          }
        end
      )
      vim.keymap.set(
        "n",
        "<leader>/",
        function()
          fzflua.lgrep_curbuf {
            winopts = {
              width = 0.6,
              preview = {
                layout = "vertical",
                vertical = "up:60%",
              },
            },
          }
        end
      )
      vim.keymap.set(
        "n",
        "<leader><leader>",
        function()
          fzflua.buffers {
            formatter = "path.filename_first",
            previewer = false,
            winopts = { width = 0.3, height = 0.8 },
          }
        end
      )

      -- LSP Keymaps
      vim.keymap.set("n", "gd", fzflua.lsp_definitions)
      -- vim.keymap.set("n", "gi", fzflua.lsp_implementations)
      vim.keymap.set(
        "n",
        "gO",
        function()
          fzflua.lsp_document_symbols {
            previewer = false,
            winopts = {
              width = 0.5,
              height = 0.7,
            },
          }
        end,
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        "grr",
        function()
          fzflua.lsp_references {
            winopts = {
              preview = {
                layout = "vertical",
                vertical = "down:60%",
              },
            },
          }
        end,
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        { "n", "v" },
        "gra",
        function()
          fzflua.lsp_code_actions {
            previewer = false,
            winopts = {
              width = 0.5,
              height = 0.7,
            },
          }
        end,
        { noremap = true, silent = true }
      )
    end,
  },
  {
    "hover.nvim",
    lazy = true,
    keys = { "K", "gK" },
    after = function()
      require("hover").config {
        title = false,
      }
      vim.keymap.set("n", "K", function() require("hover").open() end, { desc = "hover.nvim (open)" })
      vim.keymap.set("n", "gK", function() require("hover").enter() end, { desc = "hover.nvim (enter)" })
    end,
  },
  {
    "fidget.nvim",
    lazy = true,
    event = "DeferredUIEnter",
    after = function() require("fidget").setup {} end,
  },
  {
    "snacks.nvim",
    lazy = true,
    event = "DeferredUIEnter",
    after = function()
      local snacks = require "snacks"
      snacks.setup {
        zen = {
          enabled = true,
          toggles = { dim = false },
        },
        toggles = { dim = false },
        styles = { zen = { backdrop = { transparent = false } } },
      }
      vim.keymap.set("n", "<leader>z", function() snacks.zen() end)
    end,
  },
  {
    "nvim-tree.lua",
    lazy = true,
    keys = {
      "<leader>e",
      "<leader>E",
    },
    after = function()
      require("nvim-tree").setup {
        view = {
          width = 35,
          relativenumber = true,
          side = "right",
        },
        filters = { dotfiles = false },
        renderer = { group_empty = true },
      }
      vim.keymap.set("n", "<leader>e", function() require("nvim-tree.api").tree.toggle() end, { desc = "Toggle NvimTree" })
      vim.keymap.set("n", "<leader>E", function() require("nvim-tree.api").tree.toggle { current_window = true } end, { desc = "Toggle NvimTree" })
    end,
  },
  {
    "cloak.nvim",
    lazy = true,
    ft = {
      "sh", -- ft for *.env files, perhaps set custom ft for these?
    },
    after = function()
      require("cloak").setup {
        patterns = {
          {
            file_pattern = "*.env",
            cloak_pattern = "=.+",
            replace = nil,
          },
          -- TODO: configures json yaml secrets
        },
      }
      vim.keymap.set("n", "gct", ":CloakToggle<cr>", { noremap = true, silent = true })
    end,
  },
  {
    "nvim.undotree",
    lazy = true,
    event = "DeferredUIEnter",
    after = function() vim.keymap.set("n", "<leader>u", require("undotree").open) end,
  },
  {
    "blink.indent",
    -- enabled = false,
    lazy = true,
    event = "DeferredUIEnter",
    -- ft = { "javascriptreact", "typescriptreact" },
    after = function() require("blink.indent").setup { scope = { enabled = false } } end,
  },
}

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Editor
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lze.load {
  {
    "gitsigns.nvim",
    lazy = true,
    event = "BufReadPost",
    after = function()
      require("gitsigns").setup {
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      }
    end,
  },
  {
    "nvim-autopairs",
    lazy = true,
    event = "InsertEnter",
    after = function() require("nvim-autopairs").setup {} end,
  },
  {
    "todo-comments.nvim",
    lazy = true,
    event = "BufReadPost",
    after = function() require("todo-comments").setup {} end,
  },
  {
    "nvim-colorizer.lua",
    lazy = true,
    event = "BufReadPre",
    after = function()
      require("colorizer").setup {
        options = { parsers = { css_fn = true } },
      }
      vim.keymap.set("n", "gtc", ":ColorizerToggle<cr>", { desc = "[g]o [t]oggle [c]olor" })
    end,
  },
  {
    "cellular-automaton.nvim",
    lazy = true,
    cmd = "CellularAutomaton",
  },
  {
    "cord-nvim",
    enabled = false,
    lazy = true,
    event = "UIEnter",
    after = function()
      require("cord").setup {
        editor = { tooltip = "Neovim" },
        idle = { enabled = false },
      }
    end,
  },
  {
    "mini.nvim",
    lazy = true,
    event = "BufReadPost",
    after = function()
      local spec_treesitter = require("mini.ai").gen_spec.treesitter
      require("mini.ai").setup {
        n_lines = 500,
        custom_textobjects = {
          ["c"] = spec_treesitter { a = "@class.outer", i = "@class.inner" },
          ["/"] = spec_treesitter { a = "@comment.outer", i = "@comment.inner" },
          ["i"] = spec_treesitter { a = "@conditional.outer", i = "@conditional.inner" },
          ["f"] = spec_treesitter { a = "@function.outer", i = "@function.inner" },
          ["o"] = spec_treesitter { a = "@loop.inner", i = "@loop.outer" },
        },
      }
      require("mini.surround").setup {}
      -- motions:
      -- [r]eplace
      -- [m]ultiply
      -- [x]change (swap)
      -- [=]evaluate
      -- [s]ort
      require("mini.operators").setup {
        replace = { prefix = "cr" },
        exchange = { prefix = "cx" },
      }
    end,
  },
  {
    "treesj",
    lazy = true,
    keys = "<space>j",
    after = function()
      local treesj = require "treesj"
      treesj.setup {
        use_default_keymaps = false,
        max_join_length = 1024,
      }
      vim.keymap.set("n", "<space>j", treesj.toggle)
    end,
  },
  {
    "highlight-undo.nvim",
    lazy = true,
    keys = { "u", "<C-r>" },
    after = function() require("highlight-undo").setup {} end,
  },
  {
    "vscode.nvim",
    lazy = false,
    priority = 1000,
    after = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup {
        underline_links = false,
        group_overrides = {
          BlinkCmpMenu = { bg = c.vscPopupBack },
          StatusLine = { link = "Normal" },
          StatusLineNC = { link = "Normal" },
        },
      }
      vim.cmd.colorscheme "vscode"
    end,
  },
  {
    "persistence.nvim",
    lazy = false,
    after = function()
      local persistence = require "persistence"
      persistence.setup()

      -- load the session for the current directory
      vim.keymap.set("n", "<leader>s", persistence.load)
      -- select a session to load
      vim.keymap.set("n", "<leader>S", persistence.select)
      -- load the last session
      vim.keymap.set("n", "<leader>ql", function() persistence.load { last = true } end)
      -- stop Persistence => session won't be saved on exit
      vim.keymap.set("n", "<leader>qd", persistence.stop)
    end,
  },
  {
    "marks.nvim",
    lazy = true,
    event = "BufReadPost",
    after = function()
      -- mx              Set mark x
      -- m,              Set the next available alphabetical (lowercase) mark
      -- m;              Toggle the next available mark at the current line
      -- dmx             Delete mark x
      -- dm-             Delete all marks on the current line
      -- dm<space>       Delete all marks in the current buffer
      -- m]              Move to next mark
      -- m[              Move to previous mark
      -- m:              Preview mark. This will prompt you for a specific mark to
      --                 preview; press <cr> to preview the next mark.

      -- m[0-9]          Add a bookmark from bookmark group[0-9].
      -- dm[0-9]         Delete all bookmarks from bookmark group[0-9].
      -- m}              Move to the next bookmark having the same type as the bookmark under
      --                 the cursor. Works across buffers.
      -- m{              Move to the previous bookmark having the same type as the bookmark under
      --                 the cursor. Works across buffers.
      -- dm=             Delete the bookmark under the cursor.
      require("marks").setup {}
    end,
  },
  {
    "indent-o-matic",
    lazy = true,
    event = "DeferredUIEnter",
    after = function() require("indent-o-matic").setup { standard_widths = { 2, 4 } } end,
  },
  {
    "nvim-ts-autotag",
    lazy = true,
    ft = { "html", "javascriptreact", "typescriptreact" },
    after = function() require("nvim-ts-autotag").setup {} end,
  },
}

vim.cmd.colorscheme "monokai"
vim.api.nvim_set_hl(0, "StatusLine", { link = "Normal" })
vim.api.nvim_set_hl(0, "StatusLineNC", { link = "StatusLine" })
vim.api.nvim_set_hl(0, "debugPC", { bg = "#4C4C19" })

require("vim._core.ui2").enable {}
