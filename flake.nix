{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixOS/nixpkgs/nixpkgs-24.05-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    in {
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
              home-manager.extraSpecialArgs = { inherit pkgs-stable; };
            }
          ];
        };
      };
    };
}
