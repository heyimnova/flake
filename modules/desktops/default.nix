# Base desktop config
{self, ...}: {
  flake.modules.nixos.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    nixpkgs.config.permittedInsecurePackages = [
      # Needed by bitwarden-desktop
      "electron-39.8.10"
    ];

    # Packages for the user
    users.users.${self.settings.user}.packages = with pkgs; [
      bitwarden-desktop
      protonmail-desktop
      qbittorrent
    ];

    # Packages for all users
    environment.systemPackages = with pkgs; [
      caligula
      ghostty
      mullvad-browser
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

    # Files to preserve on all desktops
    preservation.preserveAt."/persist" = lib.mkIf config.preservation.enable {
      directories = [
        # Network configurations
        "/etc/NetworkManager/system-connections"

        # Mullvad VPN config
        "/etc/mullvad-vpn"
      ];

      users.${self.settings.user} = {
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

          # Desktop apps state
          ".config/Bitwarden"
          ".config/Proton Mail"
          ".config/qBittorrent"
          # Mullvad VPN GUI config
          ".config/Mullvad VPN"

          ".config/autostart"
          ".local/share/keyrings"
          ".local/state/wireplumber"
        ];
      };
    };
  };
}
