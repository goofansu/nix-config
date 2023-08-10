{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, darwin, home-manager, ... }: {
    darwinConfigurations.jamess-macbook-pro = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ home-manager.darwinModules.home-manager ./darwin.nix ];
    };
  };
}
