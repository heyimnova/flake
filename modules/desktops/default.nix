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

    boot = {
      # Boot options time out after 1 second
      loader.timeout = 1;

      # Splash screen on boot
      plymouth = {
        enable = true;
        theme = "blahaj";
        themePackages = with pkgs; [
          plymouth-blahaj-theme
        ];
      };

      # Only show errors on boot
      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };

  flake.nixosModules.desktopPreservation = {
    preservation.preserveAt."/persist" = {
      directories = [
        # Network configurations
        "/etc/NetworkManager/system-connections"

        # Mullvad VPN config
        "/etc/mullvad-vpn"
      ];

      users.${self.user} = {
        files = [
          ".local/share/qBittorrent/logs/qbittorrent.log"
        ];

        directories = [
          # XDG directories (Downloads and Desktop not preserved)
          "Documents"
          "Music"
          "Pictures"
          "Projects"
          "Public"
          "Templates"
          "Videos"

          ".config/autostart"
          ".local/share/keyrings"

          # Desktop apps state
          ".config/Bitwarden"
          ".config/Proton Mail"
          ".config/qBittorrent"
          # Mullvad VPN GUI config
          ".config/Mullvad VPN"
        ];
      };
    };
  };
}
