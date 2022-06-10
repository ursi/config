with builtins;
{ lib, nixpkgs, pkgs, ... }:
  let l = lib; p = pkgs; in
  { imports = [ ./alacritty.nix ];

    environment =
      { packages-extra =
          with pkgs;
          [ { pkg = xclip;

              aliases =
                { xclipc = "xclip -selection clipboard";
                  xclipng = "xclip -t image/png -selection clipboard";
                };
            }
          ];


        systemPackages =
          with pkgs;
          [ audacity
            brave
            discord
            gimp
            gnome3.nautilus # for seeing images
            gparted
            mattermost-desktop
            pavucontrol
            peek
            qbittorrent
            qemu
            signal-desktop
            spectacle
            tor-browser-bundle-bin
            vlc
            wxcam
            zulip
          ]
          ++ flake-packages-gui;
      };

    fonts.fonts = [ (p.nerdfonts.override {fonts = [ "Cousine" ]; }) ];
    hardware.pulseaudio.enable = true;

    programs =
      { alacritty.enable = true;
        dconf.enable = true;
        nm-applet.enable = true;

        xss-lock =
          { enable = true;
            lockerCommand = "${p.i3lock}/bin/i3lock -fc 440000";
          };
      };

    services =
      { picom =
          { enable = true;
            vSync = true;
          };

        xserver =
          { enable = true;
            autoRepeatInterval = 33;
            autoRepeatDelay = 250;

            libinput =
              let
                no-accell =
                  { accelProfile = "flat";
                    accelSpeed = l.mkDefault "0";
                  };
              in
              { enable = true;

                mouse = no-accell;

                touchpad =
                  no-accell
                  // { naturalScrolling = true; };
              };

            windowManager.i3.enable = true;
          };
      };

    sound.enable = true;

    ssbm =
      { cache.enable = true;

        # gcc =
        #   { oc-kmod.enable = true;
        #     rules.enable = true;
        #   };
      };

    users.users.mason =
      { im-home =
          { i3 =
              { font =
                  { font = "pango:sans";
                    size = l.mkDefault 17;
                  };

                extra-config = readFile ./i3-base-config;
              };

            icons.cursor = p.icons.breeze.cursors.breeze;
          };
      };
  }

