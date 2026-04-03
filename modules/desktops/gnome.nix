{
  flake.nixosModules.gnome = {
    lib,
    pkgs,
    ...
  }: {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      gnome = {
        # Exclude some gnome applications
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        (writeShellScriptBin "xdg-terminal-exec" ''
          # Use ghostty for gtk-launch
          exec ${lib.getExe pkgs.ghostty} -e "$*"
        '')
      ];

      # Exclude some more gnome applications
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
      dconf.enable = true;

      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };
  };

  flake.homeModules.gnome = {
    lib,
    pkgs,
    ...
  }: let
    # Enabled gnome extensions
    extensions = with pkgs.gnomeExtensions; [
      alphabetical-app-grid
      appindicator
      blur-my-shell
      caffeine
      clipboard-indicator
      grand-theft-focus
      hot-edge
      status-area-horizontal-spacing
    ];
  in {
    home.packages = with pkgs;
      [
        mousai
        warp
      ]
      ++ extensions;

    dconf.settings = {
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
        sleep-inactive-ac-timeout = 1800;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 1800;
      };

      # Some gnome extension settings
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
        tab-width = 2;
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
  };
}
