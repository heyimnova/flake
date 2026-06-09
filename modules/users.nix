# User config for all hosts
{self, ...}: {
  flake.modules.nixos.users = {
    config,
    lib,
    ...
  }: {
    users = {
      mutableUsers = false;

      users = {
        root = {
          # Disable root user password
          hashedPassword = "!";
          # Disable passwordless root login on installer devices
          hashedPasswordFile = null;
        };

        # Create the user
        ${self.settings.user} = {
          description = self.settings.userDescription;
          home = self.settings.userHome;
          isNormalUser = true;
          extraGroups = ["wheel"];
          hashedPasswordFile = config.sops.secrets."user-password-hash".path;
        };
      };
    };

    preservation.preserveAt."/persist".users.${self.settings.user} = lib.mkIf config.preservation.enable {
      commonMountOptions = [
        # Hide bind mounts in user home
        "x-gvfs-hide"
      ];

      directories = [
        # Nix user state
        ".local/state/nix"

        # Default system flake location
        ".config/flake"

        # sops keys
        ".config/sops"

        # Spotify state
        ".config/spotify"
        ".cache/spotify"
      ];
    };
  };
}
