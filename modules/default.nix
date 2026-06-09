# flake-parts config
{
  self,
  inputs,
  lib,
  ...
}: {
  # Import flake parts flakeModules
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.disko.flakeModules.disko
    inputs.home-manager.flakeModules.home-manager
  ];

  # Flake user settings
  options.flake.settings = with lib;
    mkOption {
      description = "User settings shared between modules";
      type = types.submodule {
        options = {
          user = mkOption {type = types.str;};
          userDescription = mkOption {type = types.str;};
          userHome = mkOption {type = types.str;};
        };

        # Default user settings
        config = {
          user = mkDefault "nova";
          userDescription = mkDefault "Nova";
          userHome = mkDefault "/home/${self.settings.user}";
        };
      };
    };

  config = {
    # Define supported systems
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    # Shared nixpkgs config
    flake.modules.generic.nixpkgsConfig = {
      nixpkgs = {
        config.allowUnfree = true;

        # Nix User Repository overlay
        overlays = [
          inputs.nur.overlays.default
        ];
      };
    };
  };
}
