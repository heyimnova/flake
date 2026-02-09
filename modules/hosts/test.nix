{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.test = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [
      self.nixosModules.host_test
    ];
  };

  # Test host configuration module
  flake.nixosModules.host_test = {
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    system.stateVersion = "25.11";

    imports = [
      # Allow this configuration to be built as a vm
      "${modulesPath}/virtualisation/qemu-vm.nix"
      "${modulesPath}/installer/scan/not-detected.nix"
    ];

    users.users.nova = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      initialPassword = "test";
    };

    environment.systemPackages = with pkgs; [
      fastfetch
      neovim
    ];
  };
}
