{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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
