# Modules for impermanent systems
{self, ...}: {
  # Preservation to manage persisted files
  flake.nixosModules.preservation = {
    # Mount persistent subvolume at boot
    fileSystems."/persist".neededForBoot = true;

    preservation = {
      enable = true;

      # Files to keep on reboot on all hosts
      preserveAt."/persist" = {
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
        ];

        users.${self.user} = {
          files = [];

          directories = [
            # sops keys
            ".config/sops"

            # nix user state
            ".local/state/nix"
          ];
        };
      };
    };

    systemd = {
      # Let service commit machine id to persistent subvolume
      services.systemd-machine-id-commit = {
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

  # Handle wiping root on boot
  flake.nixosModules.impermanence = {
    boot = {
      # Wipe /tmp on boot
      tmp.cleanOnBoot = true;

      # systemd service to wipe root subvolume on boot
      initrd.systemd.services.clean-root = {
        description = "Create new empty root subvolume (keep old roots for 7 days)";
        wantedBy = ["initrd.target"];

        # After disk has been decrypted
        after = ["systemd-cryptsetup@crypt.service"];

        # Before /sysroot is mounted
        before = ["sysroot.mount"];

        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir /btrfs_tmp
          mount -o compress=zstd,noatime /dev/mapper/crypt /btrfs_tmp

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          # Save a read only snapshot of the current root subvolume
          if [[ -e /btrfs_tmp/@ ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
            btrfs subvolume snapshot -r /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
            delete_subvolume_recursively /btrfs_tmp/@
          fi

          # Delete expired root subvolumes
          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
            btrfs subvolume delete "$i"
          done

          # Create new root subvolume
          btrfs subvolume create /btrfs_tmp/@
          umount /btrfs_tmp
        '';
      };
    };
  };
}
