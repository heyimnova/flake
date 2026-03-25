{
  flake.diskoConfigurations.${baseNameOf ./.} = {
    disko.devices = {
      disk.root = {
        device = "/dev/disk/by-id/ata-Crucial_CT256MX100SSD1_14420D8A5609";
        type = "disk";
        name = "root";

        # Disk partitions
        content = {
          type = "gpt";

          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              name = "boot";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            cryptroot = {
              size = "100%";
              name = "cryptroot";

              # LUKS container
              content = {
                type = "luks";
                name = "root";
                # This needs to be created on the target machine
                passwordFile = "/tmp/cryptroot.key";
                settings.allowDiscards = true;

                # Filesystem
                content = {
                  type = "btrfs";

                  subvolumes = {
                    "@" = {
                      mountpoint = "/";

                      mountOptions = [
                        "compress=zstd"
                        "discard=async"
                        "noatime"
                      ];
                    };

                    "@home" = {
                      mountpoint = "/home";

                      mountOptions = [
                        "compress=zstd"
                        "discard=async"
                        "noatime"
                      ];
                    };

                    "@nix" = {
                      mountpoint = "/nix";

                      mountOptions = [
                        "compress=zstd"
                        "discard=async"
                        "noatime"
                      ];
                    };

                    "@swap" = {
                      mountpoint = "/var/swap";
                      swap.swapfile.size = "4G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
