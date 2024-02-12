with builtins;
{ lib, mmm, pkgs, ... }:
  let l = lib; p = pkgs; in mmm
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
        onboard
        xorg.xdpyinfo
      ];

    hardware.microsoft-surface.firmware.surface-go-ath10k.replace = true;

    my-modules =
      { i3 =
          { backlight-adjust-percent = 5;

            hm =
              { config.fonts =
                  { names = [ "sans" ];
                    size = 20.25;
                  };

                extraConfig = "exec --no-startup-id onboard";
              };
          };

        i3status.battery = true;
      };

    networking.interfaces.wlp1s0.useDHCP = true;
    programs.alacritty.config.font.size = 10;

    remote-builder =
      { enable = true;
        user = "mason";
      };

    services =
      { picom.backend = "glx";

        xserver =
          { dpi = 144; # 1.5x the default
            libinput.touchpad.accelSpeed = "1"; # guess this is the highest it can be set
          };
      };

    # don't change - man configuration.nix
    system.stateVersion = "21.11";

    # this option cause the build to fail
    systemd.services.iptsd = l.mkForce {};
  }
