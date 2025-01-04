{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-24.11-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { darwin, home-manager, ... }:
    {
      darwinConfigurations = {
        jamess-macbook-pro = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.james = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
