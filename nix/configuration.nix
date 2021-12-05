with builtins;
{ lib, nixpkgs, pkgs, ... }:
  let l = lib; p = pkgs; in
  { imports = [ ./git.nix ./package-alias.nix ];

    environment =
      { pkgs-with-aliases =
          with pkgs;
          [ { pkg = chez;
              aliases.scheme = "scheme ${./prelude.ss}";
            }

            (let hours-alias = "hours -j ~/.hours"; in
             { pkg = hours;

               aliases =
                 { hours = hours-alias;

                   hours-stop =
                     "hours show | tail -n 2 && hours session stop && hours show";

                   hours-undo = "hours eventlog undo && hours show";
                 };

               functions.hours-start =
                 ''${hours-alias} session start -t "$1" && ${hours-alias} show'';
             }
            )

            { pkg = j;
              aliases.j = "jconsole";
            }

            { pkg = jq;
              functions.jql = ''jq -C "$1" "$2" | less -r'';
            }

            { pkg = nodePackages.http-server;
              aliases.http-server = "http-server -c-1";
            }

            { pkg = trash-cli;
              aliases.trash = "trash-put";
            }

            { pkg = xclip;

              aliases =
                { xclipc = "xclip -selection clipboard";
                  xclipng = "xclip -t image/png -selection clipboard";
                };
            }
          ];

        shellAliases =
          { cal = "cal -m";
            fui = "nix flake lock --update-input";
            nix-use = "nix-env -if nix.nix";
            nix-remove = "nix-env -e nix";
            nixbuild = "nix build -f .";
            nixpkgs-unstable = ''echo $(nix eval --impure --raw --expr '(fetchGit { url = "https://github.com/NixOS/nixpkgs"; ref = "nixpkgs-unstable"; }).rev')'';

            nixrepl =
              let
                file = p.writeText "" "{ p }: { l = p.lib; inherit p; } // builtins";
              in
              ''nix repl --arg p '(builtins.getFlake "${./.}").inputs.nixpkgs.legacyPackages.x86_64-linux' ${file}'';

            nixshell = "nix develop -f shell.nix";
          };

        systemPackages =
          with pkgs;
          [ alacritty
            audacity
            brave
            gimp
            git
            graphviz
            imagemagick
            ix
            ncdu
            neofetch
            neovim
            nix-du
            ntfs3g
            parted
            pavucontrol
            peek
            spectacle
            tmate
            unzip
            usbutils
            w3m
            wxcam
          ];

        variables.VISUAL = "nvim";
      };

    fonts.fonts = [ (p.nerdfonts.override {fonts = [ "Cousine" ]; }) ];

    hardware =
      { keyboard.zsa.enable = true;
        pulseaudio.enable = true;
      };

    networking =
      { firewall.enable = false;
        networkmanager.enable = true;
        # wireless.enable = true; # Enables wireless support via wpa_supplicant.

        # The global useDHCP flag is deprecated, therefore explicitly set to false here.
        # Per-interface useDHCP will be mandatory in the future, so this generated config
        # replicates the default behaviour.
        useDHCP = false;
      };

    nix =
      { extraOptions = "experimental-features = nix-command flakes";
        registry.nixpkgs.flake = nixpkgs;
        trustedUsers = [ "mason" "root" ];
      };

    programs =
      { dconf.enable = true;
        nm-applet.enable = true;
        steam.enable = true;

        xss-lock =
          { enable = true;
            lockerCommand = "${p.i3lock}/bin/i3lock -fc 440000";
          };

        z =
          { enable = true;
            cmd = "a";
          };
      };

    services =
      { picom =
          { enable = true;
            vSync = true;
          };

        xserver =
          { enable = true;

            # Disable mouse acceleration
            libinput =
              { enable = true;

                mouse =
                  l.mkDefault
                    { accelProfile = "flat";
                      accelSpeed = "0";
                    };
              };

            windowManager.i3.enable = true;
          };
      };

    sound.enable = true;

    ssbm =
      { cache.enable = true;

        gcc =
          { oc-kmod.enable = true;
            rules.enable = true;
          };
      };

    time.timeZone = "America/Toronto";

    users =
      { mutableUsers = false;

        users =
          { mason =
              { createHome = true;
                description = "Mason Mackaman";
                extraGroups = [ "networkmanager" "plugdev" "wheel" ];
                i3.extra-config = readFile ../i3/config;
                icons.cursor = p.icons.breeze.cursors.breeze;
                isNormalUser = true;

                packages = with pkgs;
                  let
                    communication =
                      [ discord
                        mattermost-desktop
                        signal-desktop
                        zulip
                      ];
                  in
                  [ gnome3.nautilus # for seeing images

                    (writeShellScriptBin
                       "prefetch-nixpkgs"
                       ''
                       url=https://github.com/NixOS/nixpkgs/archive/$1.tar.gz
                       nix-prefetch-url $url --type sha256 --unpack 2> /dev/null | {
                         read hash

                         echo "\
                       (fetchTarball
                          { url = \"$url\";
                            sha256 = \"$hash\";
                          }
                       )"
                       }
                       ''
                    )

                    qbittorrent
                    qemu

                    (writeShellScriptBin
                       "snowball"
                       "bash <( curl https://gitlab.com/fresheyeball/snowball/-/raw/master/generator.sh )"
                    )

                    slippi-netplay
                    torbrowser
                    vlc
                    wally-cli
                  ]
                  ++ communication
                  ++ flake-packages;

                password = "";
              };

            root =
              { extraGroups = [ "root" ];
                password = "";
              };
          };
      };
  }
