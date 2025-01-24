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
-- Set lsp log verbosity to TRACE
vim.lsp.set_log_level(vim.log.levels.TRACE)

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
          vim.keymap.set({ "n", "v" }, "<leader>ca", fzflua.lsp_code_actions)

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
        jdtls = {},
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
        if server == "jdtls" then
          goto continue
        end
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
        ::continue::
      end
    end,
  },
  {
    "blink.cmp",
    after = function()
      require("blink.cmp").setup {
        appearance = {
          nerd_font_variant = "normal",
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
        format_on_save = function(bufnr)
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
  { "nvim-web-devicons" },
  { "nvim-dap-ui" },
  { "nvim-nio" },
  { "vim-sleuth" },
  { "comment.nvim" },
  { "plenary.nvim" },
  { "nui.nvim" },
  {
    "gruvbox-material",
    priority = 1000,
    after = function()
      vim.cmd.colorscheme "gruvbox-material"
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_diagnostic_virtual_text = 1
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
      }
      vim.keymap.set("n", "<leader>sf", fzflua.files)
      vim.keymap.set("n", "<leader>sg", fzflua.live_grep)
      vim.keymap.set("n", "<leader>/", fzflua.lgrep_curbuf)
      vim.keymap.set("n", "<leader>sh", fzflua.help_tags)
      vim.keymap.set("n", "<leader>sk", fzflua.keymaps)
      vim.keymap.set("n", "<leader><leader>", fzflua.buffers)
    end,
  },
  {
    "neo-tree.nvim",
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
      }
      vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>")
    end,
  },
  {
    "todo-comments.nvim",
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
      }
    end,
  },
  {
    "mini.nvim",
    after = function()
      require("mini.ai").setup { n_lines = 500 }
      require("mini.surround").setup {}
      local statusline = require "mini.statusline"
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_fileinfo = function(args)
        local filetype = vim.bo.filetype
        if filetype == "" then
          return ""
        end

        local icon, iconhl = require("nvim-web-devicons").get_icon(vim.fn.expand "%:t", nil, { default = true })
        filetype = string.format("%%#%s#%s %s%%#MiniStatuslineFileinfo#", iconhl, icon, filetype)

        if MiniStatusline.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then
          return filetype
        end

        local encoding = vim.bo.fileencoding or vim.bo.encoding
        local format = vim.bo.fileformat

        local size = ""
        local _size = vim.fn.getfsize(vim.fn.getreg "%")
        if _size < 1024 then
          size = string.format("%dB", _size)
        elseif _size < 1048576 then
          size = string.format("%.2fKiB", _size / 1024)
        else
          size = string.format("%.2fMiB", _size / 1048576)
        end

        return string.format("%s %s[%s] %s", filetype, encoding, format, size)
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },
  {
    "treesj",
    keys = "<space>j",
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
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require("lspconfig.configs.jdtls").default_config.root_dir,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,

        -- Where are the config and workspace dirs for a project?
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

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {} },
        -- Can set this to false to disable main class scan, which is a performance killer for large project
        dap_main = {},
        test = true,
        settings = {
          java = {
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
          },
        },
      }

      -- Find the extra bundles that should be passed on the jdtls command-line
      -- if nvim-dap is enabled with java debug/test.
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

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          settings = opts.settings,
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        }, opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = attach_jdtls,
      })

      -- Setup keymap and dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      -- https://neovim.io/doc/user/lsp.html#LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            -- local wk = require "which-key"
            -- wk.add {
            --   {
            --     mode = "n",
            --     buffer = args.buf,
            --     { "<leader>cx", group = "extract" },
            --     { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
            --     { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
            --     { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
            --     { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
            --     { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
            --   },
            -- }
            -- wk.add {
            --   {
            --     mode = "v",
            --     buffer = args.buf,
            --     { "<leader>cx", group = "extract" },
            --     {
            --       "<leader>cxm",
            --       [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
            --       desc = "Extract Method",
            --     },
            --     {
            --       "<leader>cxv",
            --       [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
            --       desc = "Extract Variable",
            --     },
            --     {
            --       "<leader>cxc",
            --       [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
            --       desc = "Extract Constant",
            --     },
            --   },
            -- }

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
}

require("lz.n").load(plugins)
