# flake-parts config
{inputs, ...}: {
  # Define supported systems
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  # Import flakeModules
  imports = with inputs; [
    home-manager.flakeModules.home-manager
  ];

  # Set user settings
  flake = rec {
    user = "nova";
    userDescription = "Nova";
    userHome = "/home/${user}";
  };
}
