{ pkgs, ... }:
  let p = pkgs; in
  { imports =
      [ ./hardware-configuration.nix
        ../../hardware/mice/simple-corsair.nix
        ../../secrets/agenix.nix
      ];

    boot =
      # 5.13 didn't fix the issue with my usb wifi, and the built in wifi crashes my system
      # 5.14 had the neovim glich with cursorcolumn
      # 5.15.4 doesn't fix the issues I had with 5.13, but the usb wifi problem *might* happen less often. I was using 5.15.0-rc7, for a while with no crashes, but after this started crashing, I went back to it and it still happened. Also my audio occasionally crashes. As I'm typing this I realize that in order to use 5.15.4 I had to update nixpkgs, so mabye that's what caused 5.15.0-rc7 to not work anymore.

      { kernelPackages = p.linuxKernel.packages.linux_5_15;

        loader =
          { systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
      };

    networking =
      { hostName = "hp-envy";
        interfaces.enp1s0.useDHCP = true;
      };

    nix.settings.cores = 7;
    services.picom.backend = "glx";
    # don't change - man configuration.nix
    system.stateVersion = "20.09";
    users.users.mason.i3status.status-bar = (import ../../i3status.nix).no-battery;
  }