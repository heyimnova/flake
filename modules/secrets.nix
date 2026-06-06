# Secrets management
{
  flake.nixosModules.secrets = {config, ...}: {
    sops = {
      defaultSopsFile = ../secrets/${config.networking.hostName}.yaml;
      defaultSopsFormat = "yaml";

      age.sshKeyPaths = [
        # Import ssh host key as an age key
        "/etc/ssh/ssh_host_ed25519_key"
        # Key will be in /persist on impermanent hosts
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];

      secrets = {
        # Make sure user password hash is loaded before user creation
        "user-password-hash".neededForUsers = true;

        # Key to be added to authorized_keys
        "ssh-authorized-key" = {
          mode = "0600";
          owner = config.users.users.${config.settings.user}.name;
          group = config.users.users.${config.settings.user}.group;
        };
      };
    };
  };
}
