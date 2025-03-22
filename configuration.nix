with builtins;
{ inputs, nixpkgs, pkgs, mmm, ... }:
  let p = pkgs; in mmm
  { imports =
      [ ./git.nix
        ./my-modules/packages-extra.nix
        ./secrets/agenix.nix
      ];

    documentation.nixos.enable = false;

    environment =
      { etc =
          { "tmux.conf".source = ./tmux.conf;
            "postgresql/psqlrc".text = ''\x auto'';
          };

        shellAliases =
          { cal = "cal -m";
          };

        systemPackages =
          with p;
          [ btop
            deadnix
            entr
            file
            fx
            gh
            git
            git-lfs
            glab
            glow
            graphviz
            hexedit
            imagemagick
            ix
            killall
            moreutils
            ncdu
            neofetch
            nix-tree
            ntfs3g
            pciutils
            sl
            statix
            tmate
            tree
            unzip
            usbutils
            wally-cli
            w3m
          ]
          ++ flake-packages
          ++ (import ./shell-scripts.nix p);


        variables =
          rec
          { EDITOR = VISUAL;
            VISUAL = "nvim";
          };
      };

    hardware.keyboard.zsa.enable = true;

    my-modules =
      { hm =
          { imports = [ inputs.bevel.homeManagerModules.${p.system}.default ];
            home.stateVersion = "23.11";
            programs =
              { bash =
                  { enable = true;
                    bashrcExtra = readFile ./.bashrc;
                    historyControl = [ "erasedups" "ignoredups" ];
                  };

                bevel =
                  { enable = true;
                    harness.bash =
                      { enable = true;
                        bindings = true;
                      };
                  };
              };
          };

        packages-extra =
          with p;
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

            # { pkg = j;
            #   aliases.j = "jconsole";
            # }

            { pkg = jq;
              functions.jql = ''jq -C "$1" "$2" | less -r'';
            }

            { pkg = qrencode;
              functions.qrcode = ''qrencode -t ANSI "$1"'';
            }

            { pkg = mosh;
              aliases.mosh = "mosh -a";
              env.MOSH_ESCAPE_KEY = "~";
            }

            { pkg = neovim;
              aliases."e" = "nvim";
              functions.note = ''nvim ~/notes/"''${1:-notes}".txt'';
            }

            { pkg = "nix";

              aliases =
                { check = "nix flake check";
                  fui = "nix flake lock --update-input";
                  nix = "nix -L --allow-import-from-derivation --ignore-try";
                  nixpkgs-unstable = ''echo $(nix eval --impure --raw --expr '(fetchGit { url = "https://github.com/NixOS/nixpkgs"; ref = "nixpkgs-unstable"; }).rev')'';
                  rebuild = "nixos-rebuild -L --use-remote-sudo";
                  repl = ''nix repl --arg pkgs '(builtins.getFlake "${./.}").inputs.nixpkgs.legacyPackages.x86_64-linux' --file ${./repl.nix}'';
                };

              functions =
                { run = ''nix run ".#\"$1\"" -- "''${@:2}"'';
                  shell = "nix shell nixpkgs#$1";
                };
            }

            { pkg = nodePackages.http-server;
              aliases.http-server = "http-server -c-1";
            }

            { pkg = sssnake;
              aliases.snake = "sssnake -x 32 -y 32 -s 16 -l full -z";
            }

            { pkg = "tar";

              functions =
                { targz =
                    ''
                    local dir=$(basename "$1")
                    tar -czf "$dir".tar.gz "$dir"
                    '';

                  untargz =
                    ''
                    set -e
                    tar -xzf "$1"
                    trash "$1"
                    '';
               };
            }

            (let
               e-ink =
                let
                  gitconfig =
                    toFile "e-ink-gitconfig"
                      ''
                      [color "diff"]
                        old = ul
                        new = bold
                      '';
                in
                "E_INK=1 GIT_CONFIG_SYSTEM=${gitconfig} tmux -L e-ink";
             in
             { pkg = tmux;
               aliases = { inherit e-ink; };

               functions =
                 { e-inkn = ''${e-ink} new -n "$1" -s "$1"'';
                   tmuxn = ''tmux new -n "$1" -s "$1"'';
                 };
             }
            )

            { pkg = trash-cli;
              aliases.trash = "trash-put";
            }

            { pkg = uiua-unstable;
              aliases.ur = "uiua repl";
            }

            { pkg = yt-dlp;
              aliases.youtube-dl = "yt-dlp";
            }
          ];
      };

    networking =
      { firewall.enable = false;
        networkmanager.enable = true;

        # The global useDHCP flag is deprecated, therefore explicitly set to false here.
        # Per-interface useDHCP will be mandatory in the future, so this generated config
        # replicates the default behaviour.
        useDHCP = false;
      };

    nix =
      { extraOptions = "experimental-features = nix-command flakes";
        registry.nixpkgs.flake = nixpkgs;

        settings =
          { connect-timeout = 5;
            keep-outputs = true;
            trusted-users = [ "mason" "root" ];
            warn-dirty = false;
          };
      };

    programs =
      { bash.interactiveShellInit =
          ''
          set -o vi
          stty -ixon
          '';

        ssh.extraConfig =
          foldl'
            (acc: system:
               let info = import (./systems + "/${system}/info.nix"); in
               if info?ip then
                 ''
                 ${acc}

                 Host ${system}
                 Hostname ${info.ip}
                 ${if length (attrNames info.ssh-keys or {}) == 1
                   then "User ${head (attrNames info.ssh-keys)}"
                   else ""
                 }
                 ''
               else
                 acc
            )
            ""
            (attrNames (readDir ./systems));
      };

    services =
      { ntp.enable = true;

        openssh =
          { enable = true;
            settings.PasswordAuthentication = false;
          };
      };

    time.timeZone = "America/Toronto";

    users =
      { mutableUsers = false;

        users =
          { mason =
              { description = "Mason Mackaman";
                extraGroups = [ "networkmanager" "plugdev" "wheel" ];
                # im-home.links.path."/.config/nix" = null;
                isNormalUser = true;
                openssh.authorizedKeys.keys = import ./all-ssh-keys.nix;
                password = "";
              };

            root =
              { password = "";
                # im-home.links.path."/.config/nix" = null;
              };
          };
      };
  }
