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
          fidget-nvim
          fzf-lua
          gitsigns-nvim
          lazydev-nvim
          lz-n
          mini-nvim
          no-clown-fiesta-nvim
          noice-nvim
          nvim-dap
          nvim-dap-view
          nvim-lspconfig
          nvim-treesitter.withAllGrammars
          oil-nvim
          rustaceanvim
          snacks-nvim
          todo-comments-nvim
          vim-fugitive
          vim-sleuth
          vscode-nvim

          inputs.blink-cmp.packages.${pkgs.system}.default

          (roslyn-nvim.overrideAttrs {
            src = pkgs.fetchFromGitHub {
              owner = "seblyng";
              repo = "roslyn.nvim";
              rev = "0c4a6f5b64122b51a64e0c8f7aae140ec979690e";
              sha256 = "sha256-tZDH6VDRKaRaoSuz3zyeN/omoAwOf5So8PGUXHt2TLk=";
            };
          })

          pkgs.neovimPlugins.cord-nvim
          pkgs.neovimPlugins.duck-nvim
        ];
      };

      optionalPlugins = {
        default = with pkgs.vimPlugins; [
          cellular-automaton-nvim
          conform-nvim
          go-nvim
          highlight-undo-nvim
          luasnip
          neotest
          neotest-java
          nui-nvim
          nvim-autopairs
          nvim-dap-virtual-text
          nvim-jdtls
          nvim-lint
          nvim-nio
          nvim-web-devicons
          plenary-nvim
          snipe-nvim
          treesj
          trouble-nvim
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
