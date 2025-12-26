vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.vimtex_quickfix_enabled = 0
vim.g.loaded_sql_completion = 0
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

vim.opt.relativenumber = true
vim.opt.mouse = "a"
-- Default tab to 4 space, see https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
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
-- Silent deprecation message
---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end
vim.opt.cursorline = false
vim.opt.swapfile = false
-- Char-limit border
vim.opt.colorcolumn = "100"

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
--- see https://www.reddit.com/r/neovim/comments/1fq0y8u/comment/lp2ez92
vim.keymap.set({ "x" }, "y", '"+y', { noremap = true, silent = true })

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

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.filetype.add {
  pattern = {
    [".*/*.cf.yaml"] = "cloudformation",
  },
}

local plugins = {
  { "nvim-web-devicons", lazy = true },
  { "nvim-nio", lazy = true },
  { "plenary.nvim", lazy = true },
  { "nui.nvim", lazy = true },
  { "LuaSnip", lazy = true },
  {
    "nvim-treesitter",
    lazy = true,
    cmd = "NvimTreeToggle",
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
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = [[
                  let
                    flake = builtins.getFlake "/home/mirza/.config/nixfiles/";
                  in import flake.inputs.nixpkgs {
                    overlays = builtins.attrValues flake.outputs.overlays;
                  }
                ]],
              },
              options = {
                nixos = {
                  expr = '(builtins.getFlake "/home/mirza/.config/nixfiles").nixosConfigurations."t4nix".options',
                },
                home_manager = {
                  expr = '(builtins.getFlake "/home/mirza/.config/nixfiles").homeConfigurations."mirza@t4nix".options',
                },
              },
            },
          },
        },
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
              validate = false,
              hover = true,
              completion = true,
              format = {
                enable = true,
                bracketSpacing = true,
              },
              schemaStore = {
                enable = true,
              },
            },
          },
        },
        elp = {},
        texlab = {
          settings = {
            texlab = {
              build = {
                onSave = true,
                forwardSearchAfter = true,
              },
              forwardSearch = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
              },
            },
          },
        },
        protols = {},
        terraformls = {},
        qmlls = {
          cmd = { "qmlls", "-E" },
        },
        r_language_server = {},
        gopls = {
          settings = {
            gopls = {
              semanticTokens = true,
            },
          },
        },
      }

      -- tried changing it to use the new api vim.lsp.enable but it
      -- just doesnt work, i think it got to do with missing default
      -- config value
      for server, config in pairs(servers) do
        require("lspconfig")[server].setup(config)
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
        sources = {
          default = { "lsp", "path", "snippets", "omni", "buffer" },
        },
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
          tex = { "latexindent" },
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
      require("lz.n").trigger_load { "nvim-nio" }
    end,
    after = function()
      local dap = require "dap"
      local dap_view = require "dap-view"

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

      vim.keymap.set("n", "<F5>", dap.continue)
      vim.keymap.set("n", "<F7>", dap_view.toggle)
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
    end,
  },
  {
    "nvim-dap-view",
    after = function()
      require("dap-view").setup {
        auto_toggle = true,
        winbar = { controls = { enabled = true } },
      }
    end,
  },
  {
    "nvim-dap-virtual-text",
    lazy = true,
    after = function()
      require("nvim-dap-virtual-text").setup {}
    end,
  },
  {
    "lazydev.nvim",
    enabled = false,
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
    -- enabled = false,
    priority = 1000,
    after = function()
      require("vscode").setup {
        underline_links = false,
      }
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
    keys = { "u", "<C-r>" },
    after = function()
      require("highlight-undo").setup {}
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
    "trouble.nvim",
    keys = "<C-t>",
    before = function()
      require("lz.n").trigger_load "nvim-web-devicons"
    end,
    after = function()
      require("trouble").setup {
        auto_preview = false,
        warn_no_results = false,
        -- win = { wo = { wrap = true } },
      }
      vim.keymap.set("n", "<C-t>", ":Trouble diagnostics toggle<CR>", { noremap = true, silent = true })
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
    "go.nvim",
    ft = { "go", "gomod" },
    after = function()
      require("go").setup {
        -- lsp_keymaps = false,
        icons = false,
      }
    end,
  },
  {
    "rustaceanvim",
    lazy = false,
    after = function()
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.rs",
        callback = function()
          local cwd = vim.lsp.buf.list_workspace_folders()
          if not (cwd == null) then
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
    "oil.nvim",
    lazy = false,
    after = function()
      require("oil").setup {
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        use_default_keymaps = false,
        delete_to_trash = true,
        keymaps = {
          ["H"] = { "actions.toggle_hidden", mode = "n" },
          ["<CR>"] = "actions.select",
          ["<Esc>"] = { "actions.close", mode = "n" },
          ["-"] = { "actions.parent", mode = "n" },
        },
        win_options = {
          winbar = "%#@attribute.builtin#%{substitute(v:lua.require('oil').get_current_dir(), '^' . $HOME, '~', '')}",
        },
        view_options = { show_hidden = true },
      }
      -- see https://github.com/stevearc/oil.nvim/issues/384#issuecomment-2693662865
      vim.keymap.set("n", "-", function()
        if vim.bo.filetype == "oil" then
          require("oil.actions").close.callback()
        else
          vim.cmd "Oil"
        end
      end)
    end,
  },
  {
    "roslyn.nvim",
    after = function()
      require("roslyn").setup {}
    end,
  },
  {
    "nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
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
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
  {
    "no-clown-fiesta.nvim",
    priority = 1000,
  },
}

require("lz.n").load(plugins)

vim.cmd.colorscheme "vscode"
vim.cmd ":hi statusline guibg=NONE"
