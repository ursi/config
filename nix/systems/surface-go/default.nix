with builtins;
{ lib, pkgs, ... }:
  let l = lib; p = pkgs; in
  { imports =
      [ ./hardware-configuration.nix
        ../../remote-builder.nix
      ];

    boot.loader =
      { systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

    environment.systemPackages =
      with p;
      [ brightnessctl
        xorg.xdpyinfo
      ];

    hardware =
      { microsoft-surface.firmware.surface-go-ath10k.replace = true;
        video.hidpi.enable = true;
      };

    networking =
      { hostName = "surface-go";
        interfaces.wlp1s0.useDHCP = true;
      };

    programs.alacritty.config.font.size = 10;

    # required for the wifi driver
    nixpkgs.config.allowUnfree = true;

    remote-builder =
      { enable = true;
        user = "mason";
      };

    services =
      { picom.backend = "glx";

        xserver =
          { dpi = 144; # 1.5x the default
          };
      };

    # don't change - man configuration.nix
    system.stateVersion = "21.11";

    # this option cause the build to fail
    systemd.services.iptsd = l.mkForce {};

    users.users.mason =
      { i3 =
          { backlight-adjust-percent = 5;
            font.size = 27;
          };

        i3status.status-bar = (import ../../i3status.nix).battery;
      };
  }
