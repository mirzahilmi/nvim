inputs: {
  wlib,
  config,
  pkgs,
  lib,
  ...
}: let
  neovimPlugins = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
in {
  imports = [wlib.wrapperModules.neovim];

  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input: let
            name = lib.removePrefix prefix input;
          in {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    # Makes plugins autobuilt from our inputs available with
    # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  config = {
    settings.config_directory = lib.generators.mkLuaInline "vim.fn.stdpath('config')";
    extraPackages = with pkgs; [
      alejandra
      fzf
      hadolint
      lemminx
      lua-language-server
      luajitPackages.jsregexp
      nixd
      python313Packages.cfn-lint
      ripgrep
      stylua
      yaml-language-server
    ];

    specs.default = with pkgs.vimPlugins; [
      mini-nvim
      nvim-lspconfig
      rustaceanvim
      vim-sleuth
      vscode-nvim

      neovimPlugins.lze
    ];

    specs.optional.lazy = true;
    specs.optional.data = with pkgs.vimPlugins; [
      blink-cmp
      cellular-automaton-nvim
      cloak-nvim
      conform-nvim
      cord-nvim
      friendly-snippets
      fzf-lua
      gitsigns-nvim
      go-nvim
      highlight-undo-nvim
      luasnip
      neotest
      neotest-java
      noice-nvim
      nui-nvim
      nvim-autopairs
      nvim-colorizer-lua
      nvim-dap
      nvim-dap-view
      nvim-dap-virtual-text
      nvim-jdtls
      nvim-lint
      nvim-nio
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      plenary-nvim
      snacks-nvim
      snipe-nvim
      todo-comments-nvim
      treesj
      trouble-nvim

      (roslyn-nvim.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "seblyng";
          repo = "roslyn.nvim";
          rev = "0c4a6f5b64122b51a64e0c8f7aae140ec979690e";
          sha256 = "sha256-tZDH6VDRKaRaoSuz3zyeN/omoAwOf5So8PGUXHt2TLk=";
        };
      })
    ];
  };
}
