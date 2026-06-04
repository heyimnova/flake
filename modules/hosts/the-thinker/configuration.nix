{
  inputs,
  self,
  ...
}: let
  # host is the name of the directory
  host = baseNameOf ./.;
in {
  # TODO: This will become a problem when I add more hosts
  flake.host = host;

  flake.nixosConfigurations.${host} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [
      # Disk config
      inputs.disko-stable.nixosModules.disko
      self.diskoConfigurations.${host}

      # Impermanence config
      inputs.preservation.nixosModules.default
      self.nixosModules.preservation
      self.nixosModules.impermanence

      # Secrets management
      inputs.sops-nix-stable.nixosModules.sops
      self.nixosModules.secrets

      # Base host config
      self.nixosModules.nixos

      # Host config
      self.nixosModules.${host}

      # Users config
      self.nixosModules.users

      # Base desktop config
      self.nixosModules.desktop

      # GNOME desktop config
      self.nixosModules.gnome
    ];
  };

  flake.nixosModules.${host} = {pkgs, ...}: {
    system.stateVersion = "26.05";

    networking.hostName = host;

    # Hardware report
    hardware.facter.reportPath = ./facter.json;

    # Use zram for swap
    zramSwap.enable = true;

    # Localization
    console.keyMap = "us";

    services = {
      # Fix Intel CPU throttling
      throttled.enable = true;

      openssh = {
        enable = true;
        # We will provide host keys
        generateHostKeys = false;
      };
    };

    environment.systemPackages = with pkgs; [
      watchmate
    ];

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Extra files to persist on this host
    preservation.preserveAt."/persist" = {
      directories = [
        # Bluetooth device config
        "/var/lib/bluetooth"

        # rfkill state
        "/var/lib/systemd/rfkill"
      ];

      users.${self.user}.directories = [
        # Audio state
        ".local/state/wireplumber"
      ];
    };
  };
}
