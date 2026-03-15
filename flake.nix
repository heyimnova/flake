{
  description = "My NixOS and home-manager config using flake-parts";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Recursively import Nix modules in a directory
    import-tree.url = "github:vic/import-tree";

    # Rolling sources
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stable sources
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.11";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    disko-stable = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    # Import all flake-parts modules in the modules directory
    (inputs.import-tree ./modules);
}
