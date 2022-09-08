with builtins;
{ nixpkgs, pkgs, ... }:
  { imports =
      [ ./git.nix
        ./packages-extra.nix
        ./secrets/agenix.nix
      ];

    environment =
      { etc."tmux.conf".source = ./tmux.conf;

        packages-extra =
          with pkgs;
          [ { pkg = "bash";
              env.HISTCONTROL = "ignoredups";
            }

            { pkg = chez;
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

            { pkg = qrencode;
              functions.qrcode = ''qrencode -t ANSI "$1"'';
            }

            { pkg = mosh;
              aliases.mosh = "mosh -a";
              env.MOSH_ESCAPE_KEY = "~";
            }

            { pkg = neovim;
              functions.note = ''nvim ~/notes/"''${1:-notes}".txt'';
            }

            { pkg = "nix";

              aliases =
                { fui = "nix flake lock --update-input";
                  nix = "nix -L --allow-import-from-derivation --ignore-try";
                  nixpkgs-unstable = ''echo $(nix eval --impure --raw --expr '(fetchGit { url = "https://github.com/NixOS/nixpkgs"; ref = "nixpkgs-unstable"; }).rev')'';
                  rebuild = "nixos-rebuild -L --use-remote-sudo";
                  repl = ''nix repl --arg pkgs '(builtins.getFlake "${./.}").inputs.nixpkgs.legacyPackages.x86_64-linux' ${./repl.nix}'';
                };

              functions.shell = "nix shell nixpkgs#$1";
            }

            { pkg = nodePackages.http-server;
              aliases.http-server = "http-server -c-1";
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

            { pkg = yt-dlp;
              aliases.youtube-dl = "yt-dlp";
            }
          ];

        shellAliases =
          { cal = "cal -m";
          };

        systemPackages =
          with pkgs;
          [ deadnix
            entr
            file
            fx
            git
            git-lfs
            glow
            graphviz
            hexedit
            imagemagick
            ix
            ncdu
            neofetch
            nix-du
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
          ++ (import ./shell-scripts.nix pkgs);


        variables =
          rec
          { EDITOR = VISUAL;
            VISUAL = "nvim";
          };
      };

    hardware.keyboard.zsa.enable = true;

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
        settings.trusted-users = [ "mason" "root" ];
      };

    programs =
      { bash.interactiveShellInit =
          ''
          set -o vi
          shopt -s globstar
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
                 ''
               else
                 acc
            )
            ""
            (attrNames (readDir ./systems));

        z =
          { enable = true;
            cmd = "a";
          };
      };

    services =
      { ntp.enable = true;

        openssh =
          { enable = true;
            passwordAuthentication = false;
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

                im-home =
                  { links.path."/.bashrc" = ./.bashrc;
                    links.path."/.config/nix" = null;
                  };

                isNormalUser = true;
                openssh.authorizedKeys.keys = import ./all-ssh-keys.nix;
                password = "";
              };

            root =
              { extraGroups = [ "root" ];
                im-home.links.path."/.config/nix" = null;
                password = "";
              };
          };
      };
  }
