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

            crypt = {
              size = "100%";
              name = "crypt";

              # LUKS container
              content = {
                type = "luks";
                name = "crypt";
                # This needs to be created on the target machine
                passwordFile = "/tmp/crypt.key";
                settings.allowDiscards = true;

                # Filesystem
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "crypt" "-f"];

                  subvolumes = {
                    # Root subvolume is wiped on boot
                    "@" = {
                      mountpoint = "/";

                      mountOptions = [
                        "compress=zstd:2"
                        "noatime"
                      ];
                    };

                    "@nix" = {
                      mountpoint = "/nix";

                      mountOptions = [
                        "compress=zstd:2"
                        "noatime"
                      ];
                    };

                    # Persistent files managed with preservation here
                    "@persist" = {
                      mountpoint = "/persist";

                      mountOptions = [
                        "compress=zstd:2"
                        "noatime"
                      ];
                    };

                    # System logs are preserved here
                    "@log" = {
                      mountpoint = "/var/log";

                      mountOptions = [
                        "compress=zstd:2"
                        "noatime"
                      ];
                    };

                    # Subvolume for /tmp so it avoids root snapshots (cleaned on boot separately)
                    "@tmp" = {
                      mountpoint = "/tmp";

                      mountOptions = [
                        "compress=zstd:2"
                        "noatime"
                      ];
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
