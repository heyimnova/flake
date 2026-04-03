# Config for all desktops
{
  flake.nixosModules.desktop = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ghostty
      mullvad-browser
    ];

    services.mullvad-vpn = {
      enable = true;
      # Use GUI mullvad app
      package = pkgs.mullvad-vpn;
    };
  };

  flake.homeModules.desktop = {pkgs, ...}: {
    home.packages = with pkgs; [
      bitwarden
      caligula
      protonmail-desktop
      qbittorrent
      tor-browser-bundle-bin
    ];
  };
}
