# Secrets management
{self, ...}: {
  flake.nixosModules.secrets = {
    sops = {
      #defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age = {
        # Admin key file
        # If any keys fail to load secrets will not be loaded !!
        #keyFile = "/persist/home/${self.user}/.config/sops/age/keys.txt";
        # Import ssh host key as an age key
        sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
      };

      secrets."user-password-hash" = {
        sopsFile = ../secrets/${self.host}/secrets.yaml;
        # Make sure user password hash is loaded before user creation
        neededForUsers = true;
      };
    };
  };
}
