with builtins;
{ lib, nixpkgs, pkgs, ... }:
  let l = lib; p = pkgs; in
  { imports =
      [ ./git.nix
        ./package-alias.nix
        ./secrets/agenix.nix
      ];

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

            { pkg = qrencode;
              functions.qrcode = ''qrencode -t ANSI "$1"'';
            }

            { pkg = neovim;
              functions.note = ''nvim ~/notes/"''${1:-notes}".txt'';
            }

            { pkg = "nix";

              aliases =
                { fui = "nix flake lock --update-input";
                  nix = "nix -L";
                  nixpkgs-unstable = ''echo $(nix eval --impure --raw --expr '(fetchGit { url = "https://github.com/NixOS/nixpkgs"; ref = "nixpkgs-unstable"; }).rev')'';
                  rebuild = "nixos-rebuild --use-remote-sudo";
                  repl = ''nix repl --arg pkgs '(builtins.getFlake "${./.}").inputs.nixpkgs.legacyPackages.x86_64-linux' ${./repl.nix}'';
                };

              functions.shell = "nix shell nixpkgs#$1";
            }

            { pkg = nodePackages.http-server;
              aliases.http-server = "http-server -c-1";
            }

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
          [ entr
            file
            git
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
            tmate
            tmux
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
    im-home.links.path."/etc/tmux.conf" = ./tmux.conf;

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
        settings.trusted-users = [ "mason" "root" ];
      };

    programs =
      { bash.interactiveShellInit = "shopt -s globstar";

        ssh.extraConfig =
          ''
          Host do-nixos-0
          Hostname ${(import ./systems/do-nixos-0/info.nix).ip}
          '';

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
