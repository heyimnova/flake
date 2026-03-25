{self, ...}: {
  # Config for all nixos hosts
  flake.nixosModules.nixos = {pkgs, ...}: {
    console.font = "Lat2-Terminus16";
    time.timeZone = "Europe/London";
    documentation.nixos.enable = false;

    # Create the user
    users.users.${self.user} = {
      description = self.userDescription;
      isNormalUser = true;
      extraGroups = ["wheel"];
      initialPassword = "test";
    };

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

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };

    services = {
      cron.enable = true;
      fwupd.enable = true;
    };

    programs.nano.enable = false;

    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = ["flakes" "nix-command"];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
    };
  };
}
