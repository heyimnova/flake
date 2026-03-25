# Config for all desktops
{
  flake.nixosModules.desktop = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ghostty
      mullvad-browser
    ];
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
