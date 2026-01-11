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
    "plugins-duck-nvim" = {
      url = "github:tamton-aquib/duck.nvim";
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

    dependencyOverlays = [(utils.standardPluginOverlay inputs)];

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
          hadolint
          kdePackages.qtdeclarative
          lemminx
          lua-language-server
          luajitPackages.jsregexp
          nixd
          python313Packages.cfn-lint
          ripgrep
          stylua
          texlab
          yaml-language-server
        ];
      };

      startupPlugins = {
        default = with pkgs.vimPlugins; [
          lz-n
          mini-nvim
          no-clown-fiesta-nvim
          nvim-lspconfig
          rustaceanvim
          vim-sleuth
          vscode-nvim

          inputs.blink-cmp.packages.${pkgs.system}.default
        ];
      };

      optionalPlugins = {
        default = with pkgs.vimPlugins; [
          cellular-automaton-nvim
          conform-nvim
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
          nvim-dap
          nvim-dap-view
          nvim-dap-virtual-text
          nvim-jdtls
          nvim-lint
          nvim-nio
          nvim-treesitter.withAllGrammars
          nvim-web-devicons
          oil-nvim
          plenary-nvim
          snacks-nvim
          snipe-nvim
          todo-comments-nvim
          treesj
          trouble-nvim

          pkgs.neovimPlugins.cord-nvim

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
    };

    packageDefinitions = {
      nvim = {...}: {
        settings.wrapRc = false;
        categories.default = true;
      };
      precompiled = {...}: {
        settings.wrapRc = true;
        categories.default = true;
        settings.aliases = ["nvim"];
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
