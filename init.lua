-- see https://www.reddit.com/r/neovim/comments/17ieyn2/comment/kd9vt97
vim.api.nvim_create_autocmd({ "FocusGained" }, {
  pattern = { "*" },
  command = [[call setreg("@", getreg("+"))]],
})
vim.api.nvim_create_autocmd({ "FocusLost" }, {
  pattern = { "*" },
  command = [[call setreg("+", getreg("@"))]],
})

-- see https://www.reddit.com/r/neovim/comments/1byy8lu/copying_to_the_windows_clipboard_from_wsl2
if vim.fn.has "wsl" then
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

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.relativenumber = true
vim.opt.mouse = "a"
-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- Enable break indent
vim.opt.breakindent = true
-- Save undo history
vim.opt.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 500
-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- Show which line your cursor is on
vim.opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
-- Disable word wrap
vim.opt.wrap = false
-- more space in the neovim command line for displaying messages
vim.opt.cmdheight = 1
-- set term gui colors (most terminals support this)
vim.opt.termguicolors = true
-- enable persistent undo
vim.opt.undofile = true
-- Highlight zul files
vim.filetype.add { extension = { zul = "html" } }
-- Default tab to 4 space, see https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
-- Silent deprecation message
---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end
vim.opt.cursorline = false
vim.opt.swapfile = false
vim.lsp.set_log_level "DEBUG"

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", function()
  vim.cmd "nohlsearch"
end, { silent = true })
-- Exit terminal mode in the builtin terminal.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')
-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function()
    vim.highlight.on_yank()
  end,
})

local plugins = {
  { "nvim-web-devicons", lazy = true },
  { "nvim-dap-ui", lazy = true },
  { "nvim-nio", lazy = true },
  { "plenary.nvim", lazy = true },
  { "nui.nvim", lazy = true },
  { "LuaSnip", lazy = true },
  {
    "nvim-dap-virtual-text",
    lazy = true,
    after = function()
      require("nvim-dap-virtual-text").setup {}
    end,
  },
  {
    "nvim-treesitter",
    lazy = false,
    after = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup {
        auto_install = false,
        highlight = {
          enable = true,
          disable = { "latex" },
        },
        indent = { enable = true },
      }
    end,
  },
  {
    "nvim-lspconfig",
    after = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function()
          vim.keymap.set("n", "<leader>ds", function()
            require("fzf-lua").lsp_document_symbols {
              previewer = false,
              winopts = {
                width = 0.5,
                height = 0.7,
              },
            }
          end)

          local fzflua = require "fzf-lua"
          vim.keymap.set("n", "gd", fzflua.lsp_definitions)
          vim.keymap.set("n", "gri", fzflua.lsp_implementations)
          vim.keymap.set("n", "gr", function()
            fzflua.lsp_references {
              winopts = {
                preview = {
                  layout = "vertical",
                  vertical = "down:60%",
                },
              },
            }
          end)
          vim.keymap.set({ "n", "v" }, "<leader>ca", function()
            fzflua.lsp_code_actions {
              previewer = false,
              winopts = {
                width = 0.5,
                height = 0.7,
              },
            }
          end)

          vim.diagnostic.config { virtual_text = { current_line = true } }
        end,
      })

      local servers = {
        basedpyright = {},
        nixd = {},
        phpactor = {},
        arduino_language_server = {},
        lemminx = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "nixCats" },
                disable = { "missing-fields" },
              },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              -- validate = false,
              hover = true,
              completion = true,
              format = {
                enable = true,
                bracketSpacing = true,
              },
            },
          },
        },
        gopls = {},
        elp = {},
      }

      local lspconfig = require "lspconfig"
      for server, config in pairs(servers) do
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    "blink-cmp",
    before = function()
      require("lz.n").trigger_load "luasnip"
    end,
    after = function()
      require("blink.cmp").setup {
        fuzzy = { implementation = "prefer_rust" },
        -- see https://www.reddit.com/r/neovim/comments/1hmuwaz/comment/m421fcn
        snippets = { preset = "luasnip" },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "normal",
        },
        completion = {
          keyword = { range = "full" },
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
    "conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = "<leader>f",
    after = function()
      local conform = require "conform"
      conform.setup {
        notify_on_error = false,
        format_after_save = function(bufnr)
          local disable_filetypes = { c = true, cpp = true, java = true }
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
          python = { "black" },
        },
      }
      vim.keymap.set("n", "<leader>f", function()
        conform.format { async = true, lsp_format = "fallback" }
      end)
    end,
  },
  {
    "nvim-dap",
    before = function()
      require("lz.n").trigger_load { "nvim-dap-ui", "nvim-nio" }
    end,
    after = function()
      local dap = require "dap"
      local dapui = require "dapui"

      dapui.setup {
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      }

      vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
      vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
      local breakpoint_icons = vim.g.have_nerd_font
          and { Breakpoint = "", BreakpointCondition = "", BreakpointRejected = "", LogPoint = "", Stopped = "" }
        or { Breakpoint = "●", BreakpointCondition = "⊜", BreakpointRejected = "⊘", LogPoint = "◆", Stopped = "⭔" }
      for type, icon in pairs(breakpoint_icons) do
        local tp = "Dap" .. type
        local hl = (type == "Stopped") and "DapStop" or "DapBreak"
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      vim.keymap.set("n", "<F5>", dap.continue)
      vim.keymap.set("n", "<F1>", dap.step_into)
      vim.keymap.set("n", "<F2>", dap.step_over)
      vim.keymap.set("n", "<F3>", dap.step_out)
      vim.keymap.set("n", "<F4>", dap.step_back)
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<F7>", dapui.toggle)
    end,
  },
  {
    "lazydev.nvim",
    ft = "lua",
    after = {
      ---@diagnostic disable-next-line: missing-fields
      require("lazydev").setup {
        library = {
          { path = (require("nixCats").nixCatsPath or "") .. "/lua", words = { "nixCats" } },
        },
      },
    },
  },
  {
    "vscode.nvim",
    priority = 1000,
    after = function()
      require("vscode").setup {
        underline_links = false,
      }
      vim.cmd.colorscheme "vscode"
    end,
  },
  {
    "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup {}
    end,
  },
  {
    "gitsigns.nvim",
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
    "fzf-lua",
    before = function()
      require("lz.n").trigger_load "nvim-web-devicons"
    end,
    after = function()
      local fzflua = require "fzf-lua"
      fzflua.setup {
        "border-fused",
        winopts = {
          backdrop = 100,
          treesitter = true,
        },
        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 100,
          },
        },
      }
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
      vim.keymap.set("n", "<leader>sf", function()
        fzflua.files {
          actions = { ["ctrl-g"] = { require("fzf-lua").actions.toggle_ignore } },
          formatter = "path.filename_first",
        }
      end)
      vim.keymap.set("n", "<leader>sg", function()
        fzflua.live_grep {
          winopts = {
            preview = {
              layout = "vertical",
              vertical = "down:60%",
            },
          },
          formatter = "path.filename_first",
        }
      end)
      vim.keymap.set("n", "<leader>/", function()
        fzflua.lgrep_curbuf {
          winopts = {
            width = 0.6,
            preview = {
              layout = "vertical",
              vertical = "up:60%",
            },
          },
        }
      end)
      vim.keymap.set("n", "<leader>sh", fzflua.help_tags)
      vim.keymap.set("n", "<leader>sk", fzflua.keymaps)
      vim.keymap.set("n", "<leader><leader>", function()
        fzflua.buffers {
          formatter = "path.filename_first",
          previewer = false,
          winopts = {
            width = 0.5,
            height = 0.7,
          },
        }
      end)
      vim.keymap.set("n", "<leader>sm", fzflua.marks)
    end,
  },
  {
    "todo-comments.nvim",
    before = function()
      require("lz.n").trigger_load "plenary.nvim"
    end,
    after = function()
      require("todo-comments").setup {}
    end,
  },
  {
    "cord-nvim",
    after = function()
      require("cord").setup {
        editor = { tooltip = "Neovim" },
        idle = { enabled = false },
      }
    end,
  },
  {
    "mini.nvim",
    after = function()
      require("mini.ai").setup { n_lines = 500 }
      require("mini.surround").setup {}
    end,
  },
  {
    "treesj",
    keys = "<space>j",
    before = function()
      require("lz.n").trigger_load "nvim-treesitter"
    end,
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
    keys = { "u", "<C-r>", "p", "P" },
    after = function()
      require("highlight-undo").setup {}
    end,
  },
  {
    "showkeys",
    keys = "<leader>k",
    after = function()
      local showkeys = require "showkeys"
      showkeys.setup {}
      vim.keymap.set("n", "<leader>k", showkeys.toggle)
    end,
  },
  {
    "snacks.nvim",
    priority = 1000,
    lazy = false,
    after = function()
      require("snacks").setup {
        input = { enabled = true },
        rename = { enabled = true },
      }
    end,
  },
  {
    "noice.nvim",
    before = function()
      require("lz.n").trigger_load "nui.nvim"
    end,
    after = function()
      require("noice").setup {
        lsp = {
          signature = { enabled = false },
          message = { enabled = false },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          lsp_doc_border = true,
        },
        cmdline = { enabled = false },
        messages = { enabled = false },
        popupmenu = { enabled = false },
        notify = { enabled = false },
        views = {
          mini = {
            position = {
              row = -2,
              col = "100%",
            },
          },
        },
        routes = {
          {
            filter = {
              event = "lsp",
              kind = "progress",
              cond = function(message)
                local client = vim.tbl_get(message.opts, "progress", "client")
                if client == "jdtls" then
                  local content = vim.tbl_get(message.opts, "progress", "message")
                  return content == "Validate documents"
                end
                return false
              end,
            },
            opts = { skip = true },
          },
        },
      }
    end,
  },
  {
    "nvim-jdtls",
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
            settings = {
              url = vim.fn.stdpath "config" .. "/org.eclipse.jdt.core.formatter.prefs",
            },
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
            saveActions = {
              organizeImports = true,
            },
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
            contentProvider = {
              preferred = "fernflower",
            },
          },
        },

        init_options = {
          bundles = {},
        },

        handlers = {
          ["language/status"] = function() end,
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          require("jdtls").start_or_attach(config)
        end,
      })

      require("jdtls").start_or_attach(config)
    end,
  },
  {
    "lualine.nvim",
    before = function()
      require("lz.n").trigger_load "nvim-web-devicons"
    end,
    after = function()
      local filename = { "filename", path = 1 }

      local diagnostics = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        sections = { "error", "warn", "info", "hint" },
        symbols = {
          error = "E ",
          hint = "H ",
          info = "I ",
          warn = "W ",
        },
        colored = true,
        update_in_insert = false,
        always_visible = false,
      }

      local diff = {
        "diff",
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
        symbols = {
          added = " ",
          modified = " ",
          removed = " ",
        },
        colored = true,
        always_visible = false,
      }
      require("lualine").setup {
        options = {
          globalstatus = true,
          section_separators = "",
          component_separators = "",
          disabled_filetypes = { "fzf", "NvimTree" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {},
          lualine_c = { filename },
          lualine_x = { diagnostics, diff, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
  {
    "trouble.nvim",
    keys = "<leader>tr",
    before = function()
      require("lz.n").trigger_load "nvim-web-devicons"
    end,
    after = function()
      require("trouble").setup {
        warn_no_results = false,
        win = { wo = { wrap = true } },
      }
      vim.keymap.set("n", "<leader>tr", ":Trouble diagnostics toggle<CR>", { silent = true })
    end,
  },
  {
    "neotest",
    keys = {
      "<leader>tt",
      "<leader>td",
      "<leader>TT",
      "<leader>ts",
    },
    before = function()
      require("lz.n").trigger_load "nvim-nio"
      require("lz.n").trigger_load "plenary.nvim"
      require("lz.n").trigger_load "nvim-treesitter"
    end,
    after = function()
      local neotest = require "neotest"
      neotest.setup {
        adapters = {
          require "neotest-java" {},
        },
      }
      vim.keymap.set("n", "<leader>tt", function()
        neotest.run.run(vim.fn.expand "%")
      end, { noremap = true })
      vim.keymap.set("n", "<leader>td", function()
        neotest.run.run { strategy = "dap" }
      end, { noremap = true })
      vim.keymap.set("n", "<leader>TT", function()
        ---@diagnostic disable-next-line: undefined-field
        neotest.run.run(vim.uv.cwd())
      end, { noremap = true })
      vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, { noremap = true })
      vim.keymap.set("n", "<leader>tu", neotest.output_panel.toggle, { noremap = true })
    end,
  },
  {
    "neotest-java",
    ft = "java",
    before = function()
      require("lz.n").trigger_load "nvim-jdtls"
      require("lz.n").trigger_load "nvim-dap"
      require("lz.n").trigger_load "nvim-dap-ui"
      require("lz.n").trigger_load "nvim-dap-virtual-text"
    end,
  },
  {
    "vim-fugitive",
    after = function()
      vim.keymap.set("n", "<C-b>", function()
        for i = 1, vim.fn.winnr "$" do
          if vim.api.nvim_get_option_value("filetype", { buf = vim.fn.winbufnr(i) }) == "fugitiveblame" then
            vim.cmd(i .. "close")
            return
          end
        end
        vim.cmd "Git blame"
      end, { silent = true })
    end,
  },
  {
    "nvim-tree.lua",
    before = function()
      require("lz.n").trigger_load "nvim-web-devicons"
    end,
    after = function()
      require("nvim-tree").setup {
        hijack_netrw = true,
        renderer = {
          group_empty = true,
        },
      }
      local api = require "nvim-tree.api"
      vim.keymap.set("n", "<leader>e", function()
        api.tree.toggle {
          current_window = true,
          find_file = true,
        }
      end, { silent = true })
    end,
  },
  {
    "go.nvim",
    ft = { "go", "gomod" },
    after = function()
      require("go").setup {}
    end,
  },
  {
    "vimtex",
    lazy = false,
    after = function()
      vim.g.vimtex_view_general_viewer = "sumatrapdf-wrapper"
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
    end,
  },
}

require("lz.n").load(plugins)
