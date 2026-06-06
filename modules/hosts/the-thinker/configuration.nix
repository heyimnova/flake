{
  self,
  inputs,
  ...
}: let
  # host is the name of the directory
  host = baseNameOf ./.;
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [
      # Disk config
      inputs.disko-stable.nixosModules.disko
      self.diskoConfigurations.${host}

      # Secrets management
      inputs.sops-nix-stable.nixosModules.sops
      self.nixosModules.secrets

      # Impermanence config (enable preservation)
      self.nixosModules.preservation

      # Host config
      self.nixosModules.${host}

      # GNOME desktop config
      self.nixosModules.gnome
    ];
  };

  flake.nixosModules.${host} = {pkgs, ...}: {
    imports = [
      # Import base host config
      self.nixosModules.nixos
      # Import preservation module
      self.nixosModules."${host}Preservation"
    ];

    system.stateVersion = "26.05";

    networking.hostName = host;

    hardware = {
      # Hardware report
      facter.reportPath = ./facter.json;

      # Don't auto enable bluetooth
      bluetooth.settings = {
        Policy = {
          AutoEnable = false;
        };
      };
    };

    # Use zram for swap
    zramSwap.enable = true;

    # Localization
    console.keyMap = "us";

    services = {
      openssh.enable = true;
      # Fix Intel CPU throttling
      throttled.enable = true;
    };

    environment.systemPackages = with pkgs; [
      watchmate
    ];

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Files to preserve on this host
  flake.nixosModules."${host}Preservation" = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.preservation.enable {
      preservation.preserveAt."/persist" = {
        directories = [
          # Bluetooth device config
          "/var/lib/bluetooth"

          # rfkill state
          "/var/lib/systemd/rfkill"
        ];

        users.${config.settings.user}.directories = [
          # Audio state
          ".local/state/wireplumber"
        ];
      };
    };
  };
}
