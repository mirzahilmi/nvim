{
  description = "i just want to code";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    blink-cmp.url = "github:Saghen/blink.cmp/v1.1.1";
    "plugins-showkeys" = {
      url = "github:nvzone/showkeys";
      flake = false;
    };
    "plugins-cord-nvim" = {
      url = "github:vyfor/cord.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = "${./.}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

    extra_pkg_config = {};

    dependencyOverlays = [
      (utils.standardPluginOverlay inputs)
    ];

    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkNvimPlugin,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        default = with pkgs; [
          alejandra
          fzf
          lua-language-server
          luajitPackages.jsregexp
          nixd
          ripgrep
          stylua
          yaml-language-server
          texlivePackages.scheme-medium
        ];
      };

      startupPlugins = {
        default = with pkgs.vimPlugins; [
          inputs.blink-cmp.packages.${pkgs.system}.default
          # comment-nvim
          fidget-nvim
          fzf-lua
          gitsigns-nvim
          lazydev-nvim
          lualine-nvim
          luasnip
          lz-n
          mini-nvim
          neotest
          noice-nvim
          nvim-dap
          nvim-lspconfig
          nvim-tree-lua
          nvim-treesitter.withAllGrammars
          snacks-nvim
          todo-comments-nvim
          vimtex
          vim-fugitive
          vim-sleuth
          vscode-nvim
          pkgs.neovimPlugins.cord-nvim
        ];
      };

      optionalPlugins = {
        default = with pkgs.vimPlugins; [
          conform-nvim
          go-nvim
          highlight-undo-nvim
          neotest-java
          nui-nvim
          nvim-autopairs
          nvim-dap-ui
          nvim-dap-virtual-text
          nvim-jdtls
          nvim-nio
          nvim-web-devicons
          plenary-nvim
          treesj
          trouble-nvim
          pkgs.neovimPlugins.showkeys
        ];
      };
    };

    packageDefinitions = {
      nvim = {pkgs, ...}: {
        settings.wrapRc = false;
        categories.default = true;
      };
    };
    defaultPackageName = "nvim";
  in
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = utils.mkAllWithDefault defaultPackage;

      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      nixosModule = utils.mkNixosModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      homeModule = utils.mkHomeModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
