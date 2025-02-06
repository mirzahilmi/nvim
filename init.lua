vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.relativenumber = true
vim.opt.mouse = "a"
-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamedplus"
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
vim.opt.timeoutlen = 300
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
-- Highlight zul files
vim.filetype.add { extension = { zul = "html" } }

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
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
  { "vim-sleuth" },
  { "comment.nvim" },
  { "nvim-web-devicons", lazy = true },
  { "nvim-dap-ui", lazy = true },
  { "nvim-nio", lazy = true },
  { "plenary.nvim", lazy = true },
  { "nui.nvim", lazy = true },
  { "friendly-snippets", lazy = true },
  {
    "nvim-treesitter",
    after = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup {
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },
  {
    "nvim-lspconfig",
    after = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          vim.keymap.set("n", "<leader>ds", require("fzf-lua").lsp_document_symbols)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

          local fzflua = require "fzf-lua"
          vim.keymap.set("n", "gd", function()
            fzflua.lsp_definitions { jump_to_single_result = true }
          end)
          vim.keymap.set("n", "gI", function()
            fzflua.lsp_implementations { jump_to_single_result = true }
          end)
          vim.keymap.set("n", "gr", fzflua.lsp_references)
          vim.keymap.set({ "n", "v" }, "<leader>ca", function()
            fzflua.lsp_code_actions {
              winopts = {
                preview = {
                  layout = "vertical",
                  vertical = "up:70%",
                },
              },
            }
          end)

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight-word", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "lsp-highlight-word", buffer = event2.buf }
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.keymap.set("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end)
          end
        end,
      })

      local servers = {
        basedpyright = {},
        nixd = {},
        phpactor = {},
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
              validate = true,
              hover = true,
              completion = true,
              format = {
                enable = true,
                bracketSpacing = true,
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
              },
            },
          },
        },
      }

      local lspconfig = require "lspconfig"
      for server, config in pairs(servers) do
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    "blink.cmp",
    before = function()
      require("lz.n").trigger_load "friendly-snippets"
    end,
    after = function()
      require("blink.cmp").setup {
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "normal",
        },
        completion = {
          documentation = { window = { border = "single" } },
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
          local disable_filetypes = { c = true, cpp = true }
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
          java = { "google-java-format" },
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
    "gruvbox-material",
    priority = 1000,
    after = function()
      vim.cmd.colorscheme "gruvbox-material"
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_diagnostic_virtual_text = 1
      vim.api.nvim_set_hl(0, "NormalFloat", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "FloatBorder", { link = "FloatBorder" })
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
        winopts = {
          backdrop = 100,
          treesitter = true,
        },
        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 100,
          },
        },
        lsp = {
          code_actions = {
            previewer = "codeaction_native",
            preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS --hunk-header-style='omit' --file-style='omit'",
          },
        },
        files = { formatter = "path.filename_first" },
        buffers = { formatter = "path.filename_first" },
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
      vim.keymap.set("n", "<leader>sf", fzflua.files)
      vim.keymap.set("n", "<leader>sg", fzflua.live_grep)
      vim.keymap.set("n", "<leader>/", fzflua.lgrep_curbuf)
      vim.keymap.set("n", "<leader>sh", fzflua.help_tags)
      vim.keymap.set("n", "<leader>sk", fzflua.keymaps)
      vim.keymap.set("n", "<leader><leader>", fzflua.buffers)
      vim.keymap.set("n", "<leader>sm", fzflua.marks)
    end,
  },
  {
    "neo-tree.nvim",
    before = function()
      require("lz.n").trigger_load { "plenary.nvim", "nvim-web-devicons", "nui.nvim" }
    end,
    after = function()
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end
      local events = require "neo-tree.events"
      require("neo-tree").setup {
        event_handlers = {
          { event = events.FILE_MOVED, handler = on_move },
          { event = events.FILE_RENAMED, handler = on_move },
        },
        filesystem = {
          group_empty_dirs = true,
        },
      }
      vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })
    end,
  },
  {
    "todo-comments.nvim",
    before = function()
      require("lz.n").trigger_load "plenary.nvim"
    end,
    after = function()
      require("todo-comments").setup {
        signs = false,
      }
    end,
  },
  {
    "cord.nvim",
    after = function()
      require("cord").setup {
        editor = { tooltip = "Neovim" },
        display = { show_cursor_position = true },
        lsp = { show_problem_count = false },
        idle = { enable = false },
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
      local opts_cmd = { vim.fn.exepath "jdtls" }
      table.insert(opts_cmd, string.format("--jvm-arg=-javaagent:%s", vim.env.LOMBOK_JAR_PATH))

      local opts = {
        root_dir = require("lspconfig.configs.jdtls").default_config.root_dir,

        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,

        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/workspace"
        end,

        cmd = opts_cmd,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,

        handlers = {
          ["language/status"] = function() end,
        },

        dap = { hotcodereplace = "auto", config_overrides = {} },
        dap_main = {},
        test = true,

        settings = {
          java = {
            configuration = { runtimes = {} },
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
            completion = {
              favoriteStaticMembers = {
                "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
                "org.assertj.core.api.Assertions.*",
                "org.mockito.Mockito.*",
              },
            },
          },
        },
      }

      if vim.env.JAVA8_RUNTIME_PATH ~= "" then
        table.insert(opts.settings.java.configuration.runtimes, {
          name = "JavaSE-1.8",
          path = vim.env.JAVA8_RUNTIME_PATH,
        })
      end

      local bundles = {} ---@type string[]
      local jar_patterns = {
        vim.env.JAVA_DEBUG_PATH .. "/server/com.microsoft.java.debug.plugin-*.jar",
      }
      vim.list_extend(jar_patterns, {
        vim.env.JAVA_TEST_PATH .. "/server/*.jar",
      })
      for _, jar_pattern in ipairs(jar_patterns) do
        for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
          table.insert(bundles, bundle)
        end
      end

      local function extend_or_override(config, custom, ...)
        if type(custom) == "function" then
          config = custom(config, ...) or config
        elseif custom then
          config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
        end
        return config
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          handlers = opts.handlers,
          settings = opts.settings,
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        }, opts.jdtls)

        require("jdtls").start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = attach_jdtls,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            require("jdtls").setup_dap(opts.dap)
            if opts.dap_main then
              require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
            end

            if opts.on_attach then
              opts.on_attach(args)
            end
          end
        end,
      })

      attach_jdtls()
    end,
  },
  {
    "lualine.nvim",
    before = function()
      require("lz.n").trigger_load "nvim-web-devicons"
    end,
    after = function()
      local filename = { "filename", path = 1 }
      local progress = { "progress", color = { bg = "#32302f" } }
      local location = { "location", color = { fg = "ddc7a1", bg = "#32302f", gui = "bold" } }

      local diagnostics = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        sections = { "error", "warn", "info", "hint" },
        symbols = {
          error = " ",
          hint = " ",
          info = " ",
          warn = " ",
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
          disabled_filetypes = { "fzf" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {},
          lualine_c = { filename },
          lualine_x = { diff, diagnostics, "filetype" },
          lualine_y = { progress },
          lualine_z = { location },
        },
      }
    end,
  },
}

require("lz.n").load(plugins)
