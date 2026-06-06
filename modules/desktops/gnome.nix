{self, ...}: {
  flake.nixosModules.gnome = {
    lib,
    pkgs,
    ...
  }: let
    # Enabled GNOME extensions
    extensions = with pkgs.gnomeExtensions; [
      alphabetical-app-grid
      appindicator
      blur-my-shell
      caffeine
      clipboard-indicator
      grand-theft-focus
      hot-edge
      night-theme-switcher
      status-area-horizontal-spacing
    ];
  in {
    imports = [
      # Import base desktop config
      self.nixosModules.desktop
      # Import preservation module
      self.nixosModules.gnomePreservation
    ];

    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      gnome = {
        # Exclude some GNOME applications
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };

    environment = {
      systemPackages =
        (with pkgs; [
          mousai
          warp

          (writeShellScriptBin "xdg-terminal-exec" ''
            # Use ghostty for gtk-launch
            exec ${lib.getExe pkgs.ghostty} -e "$*"
          '')
        ])
        ++ extensions;

      # Exclude some more GNOME applications
      gnome.excludePackages = with pkgs; [
        epiphany
        geary
        gnome-connections
        gnome-console
        gnome-music
        gnome-tour
        gnome-user-docs
        yelp
      ];
    };

    programs = {
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };

      dconf = {
        enable = true;

        profiles.user.databases = [
          {
            settings = {
              "org/gnome/calculator" = {
                currency-display = "both";
                favorite-currencies = ["GBP" "SEK"];
                show-thousands = true;
              };

              "org/gnome/desktop/interface" = {
                clock-format = "12h";
                clock-show-weekday = true;
                # Using hot edge instead of hot corners
                enable-hot-corners = false;
                # Disable middle-click paste
                gtk-enable-primary-paste = false;
                show-battery-percentage = true;
              };

              "org/gnome/desktop/session" = {
                # Screen timeout after 10 mins
                idle-delay = lib.gvariant.mkUint32 600;
              };

              "org/gnome/desktop/wm/preferences" = {
                button-layout = ":close";
              };

              "org/gnome/GWeather4" = {
                tempurature-unit = "centigrade";
              };

              "org/gnome/mutter" = {
                center-new-windows = true;
                dynamic-workspaces = true;
                workspaces-only-on-primary = true;
              };

              "org/gnome/nautilus/icon-view".captions = ["size" "none" "none"];

              "org/gnome/nautilus/preferences" = {
                show-create-link = true;
                show-delete-permanently = true;
                show-directory-item-counts = "always";
                show-image-thumbnails = "always";
              };

              # Suspend after 30 mins only on battery power
              "org/gnome/settings-daemon/plugins/power" = {
                sleep-inactive-ac-timeout = lib.gvariant.mkInt32 1800;
                sleep-inactive-ac-type = "nothing";
                sleep-inactive-battery-timeout = lib.gvariant.mkInt32 1800;
              };

              # Some GNOME extension settings
              "org/gnome/shell/extensions/alphabetical-app-grid".folder-order-position = "end";
              "org/gnome/shell/extensions/caffeine".enable-fullscreen = false;
              "org/gnome/shell/extensions/hotedge".show-animation = false;

              "org/gnome/shell" = {
                enabled-extensions =
                  map (pkg: pkg.extensionUuid)
                  (extensions ++ [pkgs.gnomeExtensions.gsconnect]);

                favorite-apps = [
                  "org.gnome.Nautilus.desktop"
                  "com.mitchellh.ghostty.desktop"
                  "spotify.desktop"
                  "mullvad-browser.desktop"
                  "firefox.desktop"
                  "signal.desktop"
                  "stoat-desktop.desktop"
                  "freetube.desktop"
                  "proton-mail.desktop"
                  "dev.zed.Zed.desktop"
                  "com.collaboraoffice.Office.desktop"
                  "steam.desktop"
                  "com.heroicgameslauncher.hgl.desktop"
                  "net.lutris.Lutris.desktop"
                  "org.prismlauncher.PrismLauncher.desktop"
                  "bitwarden.desktop"
                ];
              };

              "org/gnome/TextEditor" = {
                restore-session = false;
                tab-width = lib.gvariant.mkUint32 2;
              };

              "org/gtk/gtk4/settings/file-chooser" = {
                clock-format = "12h";
                sort-directories-first = true;
              };

              "org/gtk/settings/file-chooser" = {
                clock-format = "12h";
                sort-directories-first = true;
              };

              "system/locale" = {
                region = "en_GB.UTF-8";
              };
            };
          }
        ];
      };
    };
  };

  # Files to preserve on GNOME desktops
  flake.nixosModules.gnomePreservation = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.preservation.enable {
      preservation.preserveAt."/persist".users.${config.settings.user}.directories = [
        # dconf database
        ".config/dconf"

        # gsconnect keys
        ".config/gsconnect"
      ];
    };
  };
}
