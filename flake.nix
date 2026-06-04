{
  description = "My NixOS config using flake-parts";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Recursively import Nix modules in a directory
    import-tree.url = "github:vic/import-tree";

    # Persist files on impermanent systems
    preservation.url = "github:nix-community/preservation";

    # Rolling sources
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stable sources
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-26.05";

    disko-stable = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix-stable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    # Import all flake-parts modules in the modules directory
    (inputs.import-tree ./modules);
}
