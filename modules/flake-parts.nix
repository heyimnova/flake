# flake-parts config
{
  # Define supported systems
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  # User settings
  flake = rec {
    user = "nova";
    userDescription = "Nova";
    userHome = "/home/${user}";
  };
}
