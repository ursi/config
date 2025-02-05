with builtins;
{ mmm, pkgs, ... }:
  let p = pkgs; in mmm
  { imports =
      [ ./hardware-configuration.nix
        ../../remote-builder.nix
      ];

    hardware =
      { bluetooth.enable = true;
        graphics =
          { enable = true;
            extraPackages = [ p.intel-ocl ];
          };
      };

    boot =
      { kernelPackages = p.linuxPackages_latest;

        loader =
          { systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
      };

    environment.systemPackages = [ p.quickemu ];
    my-modules.i3.hm.extraConfig = "exec --no-startup-id blueman-applet";
    networking.interfaces.enp1s0.useDHCP = true;
    nix.settings.cores = 7;
    programs.mosh.enable = true;

    services =
      { blueman.enable = true;
        borgbackup.jobs.backup-1 =
          { encryption.mode = "none";
            paths = "/home/mason/misc";
            persistentTimer = true;
            removableDevice = true;
            repo = "/backup/1/borg";
            startAt = "daily";
          };

        picom.backend = "glx";
      };

    # don't change - man configuration.nix
    system.stateVersion = "20.09";

    users.users.mason =
      { remote-builder =
          { enable = true;
            keys = attrValues (import ../surface-go/info.nix).ssh-keys;
          };
      };
  }
