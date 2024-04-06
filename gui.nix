with builtins;
{ lib, mmm, pkgs, ... }:
  let l = lib; p = pkgs; in mmm
  { imports =
      [ ./alacritty.nix
        ./my-modules/i3.nix
        ./my-modules/i3status.nix
      ];

    environment.systemPackages =
      with p;
      [ audacity
        brave
        feh
        gimp
        gnome.cheese
        gnome.nautilus # for seeing images
        gparted
        hexgui
        nix-du
        obs-studio
        openshot-qt
        pavucontrol
        peek
        qbittorrent
        qemu
        signal-desktop
        spectacle
        tdesktop
        tor-browser-bundle-bin
        vlc
        xorg.xev
      ]
      ++ flake-packages-gui;

    hardware.pulseaudio.enable = true;

    my-modules =
      { hm.home.pointerCursor =
          let
            cursor =
              p.runCommand "Breeze" {}
              ''
               mkdir -p $out/share/icons/Breeze
               cp -r ${p.icons.breeze.cursors.breeze}/. $_
              '';
          in
          { name = cursor.name;
            package = cursor;

            # the size seems to increment in large jumps
            # this is the biggest number before the next jump
            size = 30;
          };

        i3.hm =
          { enable = true;
            config =
              { fonts =
                  { names = [ "sans" ];
                    size = l.mkDefault 12.75;
                  };

                keybindings = {};
                modes = {};
                bars = [];
              };

            extraConfig = readFile ./i3-base-config;
          };

        packages-extra =
          with p;
          [ { pkg = v4l-utils;

              functions.white-balance =
                "v4l2-ctl -c white_balance_automatic=0,white_balance_temperature=$1
";
            }

            { pkg = xclip;

              aliases =
                { xclipc = "xclip -selection clipboard";
                  xclipng = "xclip -t image/png -selection clipboard";
                };
            }
          ];
      };

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
            exportConfiguration = true;

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
  }
