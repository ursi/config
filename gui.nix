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
      [ anki-bin
        audacity
        brave
        cheese
        feh
        firefox
        gimp
        gparted
        hexgui
        nautilus # for seeing images
        nix-du
        obs-studio
        openshot-qt
        pavucontrol
        peek
        qbittorrent
        qemu
        signal-desktop
        tdesktop
        texliveMedium
        tor-browser-bundle-bin
        ungoogled-chromium
        vlc
        xorg.xev
        xorg.xkill
      ]
      ++ flake-packages-gui;

    my-modules =
      { hm =
          { home.pointerCursor =
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
                size = l.mkDefault 30;
              };

            services.flameshot =
              { enable = true;

                settings.General =
                  { buttons = ''@Variant(\0\0\0\x7f\0\0\0\vQList<int>\0\0\0\0\x12\0\0\0\0\0\0\0\x1\0\0\0\x2\0\0\0\x3\0\0\0\x4\0\0\0\x5\0\0\0\x6\0\0\0\x12\0\0\0\xf\0\0\0\x13\0\0\0\b\0\0\0\t\0\0\0\x10\0\0\0\n\0\0\0\v\0\0\0\x17\0\0\0\f\0\0\0\x11)'';
                    showStartupLaunchMessage = false;
                  };
              };
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
        i3lock.enable = true;
        nm-applet.enable = true;

        xss-lock =
          { enable = true;
            lockerCommand = "${l.getExe p.i3lock} -fc 440000";
          };
      };

    services =
      { libinput =
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

        picom =
          { enable = true;
            vSync = true;
          };

        xserver =
          { enable = true;
            autoRepeatInterval = 33;
            autoRepeatDelay = 250;
            exportConfiguration = true;
            windowManager.i3.enable = true;
          };
      };
  }
