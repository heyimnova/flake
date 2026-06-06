# Modules for impermanent systems
{self, ...}: {
  # Preservation to manage persistent files
  flake.nixosModules.preservation = {
    # Enables all relevant preservation modules
    preservation.enable = true;

    # Mount persistent subvolume at boot
    fileSystems."/persist".neededForBoot = true;

    # Import impermanence module
    imports = [self.nixosModules.btrfsImpermanence];
  };

  # Handle wiping root on boot
  flake.nixosModules.btrfsImpermanence = {
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
