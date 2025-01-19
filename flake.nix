{
  description = "i just want to code";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    "plugins-showkeys" = {
      url = "github:nvzone/showkeys";
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
          nixd
          ripgrep
          stylua
          yaml-language-server
        ];
      };

      startupPlugins = {
        default = with pkgs.vimPlugins; [
          blink-cmp
          comment-nvim
          cord-nvim
          fidget-nvim
          fzf-lua
          gitsigns-nvim
          gruvbox-material
          lazydev-nvim
          lz-n
          mini-nvim
          neo-tree-nvim
          nui-nvim
          nvim-dap
          nvim-dap-ui
          nvim-lspconfig
          nvim-nio
          nvim-treesitter.withAllGrammars
          nvim-web-devicons
          plenary-nvim
          todo-comments-nvim
          vim-sleuth
        ];
      };

      optionalPlugins = {
        default = with pkgs.vimPlugins; [
          conform-nvim
          highlight-undo-nvim
          nvim-autopairs
          treesj
          pkgs.neovimPlugins.showkeys
        ];
      };
    };

    packageDefinitions = {
      nvim = {pkgs, ...}: {
        categories = {
          default = true;
        };
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
