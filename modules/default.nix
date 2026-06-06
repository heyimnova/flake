# flake-parts config
{inputs, ...}: {
  # Define supported systems
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  flake.nixosModules.base = {
    config,
    lib,
    ...
  }: {
    imports = [
      # Most modules need options.preservation.enable to be defined
      inputs.preservation.nixosModules.default
    ];

    # User settings
    options.settings = {
      user = lib.mkOption {
        default = "nova";
        type = lib.types.str;
      };

      userDescription = lib.mkOption {
        default = "Nova";
        type = lib.types.str;
      };

      userHome = lib.mkOption {
        default = "/home/${config.settings.user}";
        type = lib.types.str;
      };
    };

    # Nix and nixpkgs config
    config = {
      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        auto-optimise-store = true;
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        trusted-users = [
          "root"
          config.settings.user
        ];
      };
    };
  };
}
