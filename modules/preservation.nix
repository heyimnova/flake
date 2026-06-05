# Modules for impermanent systems
{self, ...}: {
  # Preservation to manage persistent files
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

          # sudo lectured users
          {
            directory = "/var/db/sudo/lectured";
            mode = "0700";
            configureParent = true;
            parent.mode = "0711";
          }
        ];

        users.${self.user} = {
          commonMountOptions = [
            # Hide bind mounts in user home
            "x-gvfs-hide"
          ];

          files = [];

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

          # Backup root subvolume
          if [[ -e /btrfs_tmp/@ ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          # Delete expired root subvolumes
          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
            delete_subvolume_recursively "$i"
          done

          # Create new root subvolume
          btrfs subvolume create /btrfs_tmp/@
          umount /btrfs_tmp
        '';
      };
    };
  };
}
