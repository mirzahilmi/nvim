{
  description = "I just want to code in peace.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  inputs.wrappers.inputs.nixpkgs.follows = "nixpkgs";
  inputs.plugins-lze = {
    url = "github:BirdeeHub/lze";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = extraModule: wrappers.lib.evalModules {modules = [module extraModule];};
  in {
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        neovim = (wrapper {}).config.wrap {inherit pkgs;};
        default = self.packages.${system}.neovim;
        neovim-static = (wrapper {config.settings.config_directory = nixpkgs.lib.mkForce ./.;})
          .config.wrap {inherit pkgs;};
      }
    );
  };
}
