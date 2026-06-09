{
  self,
  inputs,
  ...
}: {
  # Standalone home-manager configuration
  flake.homeConfigurations.${self.settings.user} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
    modules = [self.modules.homeManager.nonNixos];
  };

  # Standalone home-manager configuration for Nvidia hosts
  flake.homeConfigurations."${self.settings.user}-nvidia" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {system = "x86_64-linux";};

    modules = [
      self.modules.homeManager.nonNixos
      {
        # You need to fetch the Nvidia driver that host is using (cat /proc/driver/nvidia/version)
        nixpkgs.config.nvidia.acceptLicense = true;

        # nix store prefetch-file \
        #   https://download.nvidia.com/XFree86/Linux-x86_64/{version}/NVIDIA-Linux-x86_64-{version}.run
        targets.genericLinux.gpu.nvidia = {
          enable = true;
          version = "610.43.02";
          sha256 = "sha256-MDSgVLtM33dS/43CclZMsQVROAS/9TU4lFkBsWyndGM=";
        };
      }
    ];
  };

  # Import home with extra config for non NixOS home-manager
  flake.modules.homeManager.nonNixos = {
    imports = with self.modules; [
      generic.nixpkgsConfig
      homeManager.home
    ];

    home = {
      username = self.settings.user;
      homeDirectory = self.settings.userHome;
    };

    # Let home-manager manage itself
    programs.home-manager.enable = true;

    # Remember to run non-nixos-gpu-setup
    targets.genericLinux.enable = true;
  };

  # Import home and configure home-manager on NixOS
  flake.modules.nixos.home = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${self.settings.user} = self.modules.homeManager.home;
    };
  };
}
