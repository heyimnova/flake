# User config for all hosts
{
  flake.nixosModules.users = {config, ...}: {
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
        ${config.settings.user} = {
          description = config.settings.userDescription;
          home = config.settings.userHome;
          isNormalUser = true;
          extraGroups = ["wheel"];
          hashedPasswordFile = config.sops.secrets."user-password-hash".path;
        };
      };
    };
  };
}
