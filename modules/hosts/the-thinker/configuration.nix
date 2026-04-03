{
  inputs,
  self,
  ...
}: let
  # host is the name of the directory
  host = baseNameOf ./.;
in {
  flake.host = host;

  flake.nixosConfigurations.${host} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [
      # Host config
      self.nixosModules.${host}

      # Disk config
      inputs.disko-stable.nixosModules.disko
      self.diskoConfigurations.${host}

      # Stable home-manager
      inputs.home-manager-stable.nixosModules.home-manager

      # Secrets management
      inputs.sops-nix-stable.nixosModules.sops
    ];
  };

  flake.nixosModules.${host} = {
    imports = with self.nixosModules; [
      nixos
      desktop
      gnome
    ];

    system.stateVersion = "25.11";

    networking.hostName = host;

    # Hardware report
    hardware.facter.reportPath = ./facter.json;

    # Localization
    console.keyMap = "us";
    i18n.defaultLocale = "en_US.UTF-8";

    # So I can run nixos-anywhere on this machine while testing
    security.sudo.wheelNeedsPassword = false;
    services.openssh.enable = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Fix Intel CPU throttling
    services.throttled.enable = true;

    # Import host home-manager module
    home-manager.users.${self.user}.imports = [self.homeModules.${host}];
  };

  flake.homeModules.${host} = {pkgs, ...}: {
    imports = with self.homeModules; [
      gnome
    ];

    home = {
      stateVersion = "25.11";

      packages = with pkgs; [
        watchmate
      ];
    };
  };
}
