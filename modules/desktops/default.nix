# Base desktop config
{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bitwarden-desktop
      caligula
      ghostty
      mullvad-browser
      protonmail-desktop
      qbittorrent
      tor-browser
    ];

    services.mullvad-vpn = {
      enable = true;
      # Use GUI mullvad app
      package = pkgs.mullvad-vpn;
    };

    # Extra files to persist on desktops
    preservation.preserveAt."/persist" = {
      directories = [
        # Network configurations
        "/etc/NetworkManager/system-connections"
      ];

      users.${self.user} = {
        files = [
          ".local/share/qBittorrent/logs/qbittorrent.log"
        ];

        directories = [
          # XDG directories
          "Documents"
          "Music"
          "Pictures"
          "Templates"
          "Videos"

          # User keyrings
          ".local/share/keyrings"

          ".config/Bitwarden"
          ".config/Proton Mail"
          ".config/qBittorrent"
          ".config/Mullvad VPN"
        ];
      };
    };
  };
}
