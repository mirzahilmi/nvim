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

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")
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
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      local servers = {
        basedpyright = {},
        nixd = {},
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
  { "fidget.nvim" },
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
      require("mini.surround").setup()
      local statusline = require "mini.statusline"
      statusline.setup { use_icons = vim.g.have_nerd_font }
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
    keys = "<C-k>",
    after = function()
      local showkeys = require "showkeys"
      showkeys.setup {}
      vim.keymap.set("n", "<C-k>", showkeys.toggle)
    end,
  },
}

require("lz.n").load(plugins)
