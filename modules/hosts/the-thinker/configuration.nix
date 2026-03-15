{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.the-thinker = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [
      self.nixosModules.the-thinker-nixos

      inputs.disko-stable.nixosModules.disko
      self.diskoConfigurations.the-thinker
    ];
  };

  flake.nixosModules.the-thinker-nixos = {pkgs, ...}: {
    imports = [];

    networking.hostName = "the-thinker";

    # Hardware configuration
    hardware.facter.reportPath = ./facter.json;

    # Localization
    console.keyMap = "us";
    i18n.defaultLocale = "en_GB.UTF-8";

    environment.systemPackages = with pkgs; [
      fastfetch
      helix
    ];

    # So I can run nixos-anywhere on this machine while testing
    security.sudo.wheelNeedsPassword = false;
    services.openssh.enable = true;

    boot = {
      #initrd.systemd.enable = true;

      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    users.users.nova = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      initialPassword = "test";
    };

    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      auto-optimise-store = true;

      experimental-features = [
        "flakes"
        "nix-command"
      ];
    };

    system.stateVersion = "25.11";
  };
}
