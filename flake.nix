{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:nixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs-unstable,
      darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations = {
        jamess-macbook-pro = darwin.lib.darwinSystem {
          system = system;
          modules = [
            ./configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.james = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit pkgs-unstable;
              };
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
