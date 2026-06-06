{self, ...}: {
  # Config for all NixOS hosts
  flake.nixosModules.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      # Base module for all hosts
      self.nixosModules.base
      # User config for all hosts
      self.nixosModules.users
      # Preservation module for all hosts
      self.nixosModules.nixosPreservation
    ];

    console.font = "Lat2-Terminus16";
    time.timeZone = "Europe/London";
    documentation.nixos.enable = false;
    programs.nano.enable = false;

    environment = {
      # Packages installed on all nixos hosts
      systemPackages = with pkgs; [
        bat
        curl
        eza
        pciutils
        unzip
      ];

      sessionVariables = rec {
        XDG_BIN_HOME = "$HOME/.local/bin";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";

        PATH = [XDG_BIN_HOME];

        # Recommendations from xdg-ninja
        ANDROID_HOME = "${XDG_DATA_HOME}/android";
        CARGO_HOME = "${XDG_DATA_HOME}/cargo";
        CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
        GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
        INPUTRC = "${XDG_DATA_HOME}/readline/inputrc";
        _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java";
        LESSHISTFILE = "${XDG_DATA_HOME}/less/history";
        NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
        WINEPREFIX = "${XDG_DATA_HOME}/wine";
        XCOMPOSECACHE = "${XDG_CACHE_HOME}/X11/xcompose";
      };
    };

    # Localization
    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };
    };

    services = {
      cron.enable = true;
      fwupd.enable = true;

      # ssh server config
      openssh = lib.mkIf config.services.openssh.enable {
        # We will provide host keys
        generateHostKeys = false;
        authorizedKeysFiles = [config.sops.secrets."ssh-authorized-key".path];

        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [config.settings.user];
        };
      };
    };
  };

  # Files to preserve on all hosts
  flake.nixosModules.nixosPreservation = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.preservation.enable {
      preservation.preserveAt."/persist" = {
        files = [
          # ssh host keys (provide these on installation)
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            how = "symlink";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            how = "symlink";
          }

          # Host machine-id (see systemd config below)
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];

        directories = [
          # NixOS user state
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }

          # systemd timer units
          "/var/lib/systemd/timers"

          # Battery state
          "/var/lib/upower"

          # fwupd state
          "/var/lib/fwupd"

          # sudo lectured users
          {
            directory = "/var/db/sudo/lectured";
            mode = "0700";
            configureParent = true;
            parent.mode = "0711";
          }
        ];

        users.${config.settings.user} = {
          commonMountOptions = [
            # Hide bind mounts in user home
            "x-gvfs-hide"
          ];

          directories = [
            # Default system flake location
            ".config/flake"

            # sops keys
            ".config/sops"

            # nix user state
            ".local/state/nix"
          ];
        };
      };

      # Let service commit machine id to persistent subvolume
      systemd.services.systemd-machine-id-commit = {
        unitConfig.ConditionPathIsMount = [
          ""
          "/persist/etc/machine-id"
        ];

        serviceConfig.ExecStart = [
          ""
          "systemd-machine-id-setup --commit --root /persist"
        ];
      };
    };
  };
}
