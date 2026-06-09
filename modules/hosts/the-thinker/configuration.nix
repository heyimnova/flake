{
  self,
  inputs,
  ...
}: let
  # host is the name of the directory
  host = baseNameOf ./.;
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      # Disk config
      inputs.disko.nixosModules.disko
      self.diskoConfigurations.${host}

      # Impermanence config (enable preservation)
      self.modules.nixos.preservation

      # home-manager
      self.modules.nixos.home

      # Host config
      self.modules.nixos.${host}

      # GNOME desktop config
      self.modules.nixos.gnome
    ];
  };

  flake.modules.nixos.${host} = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Import base host config
    imports = [self.modules.nixos.base];

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

    # Files to preserve on this host
    preservation.preserveAt."/persist".directories = lib.mkIf config.preservation.enable [
      # Bluetooth device config
      "/var/lib/bluetooth"

      # rfkill state
      "/var/lib/systemd/rfkill"
    ];
  };
}
