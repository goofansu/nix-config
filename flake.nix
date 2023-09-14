{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixOS/nixpkgs/nixpkgs-23.05-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, darwin, home-manager, ... }: {
    darwinConfigurations.jamess-macbook-pro = darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.james = import ./home.nix;
          home-manager.extraSpecialArgs = {
            pkgs-stable = nixpkgs-stable.legacyPackages.${system};
          };
        }
      ];
    };
  };
}
