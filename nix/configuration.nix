{ pkgs, ... }:
  let p = pkgs; in
  { environment =
      { systemPackages = with pkgs;
          [ alacritty
            brave
            gimp
            git
            graphviz
            imagemagick
            ix
            jq
            ncdu
            (neovim.override { withNodeJs = true; })
            nix-du
            ntfs3g
            parted
            pavucontrol
            spectacle
            tmate
            trash-cli
            unzip
            xclip
            w3m
          ];

        variables = { EDITOR = "nvim"; };
      };

    fonts.fonts = [ (p.nerdfonts.override {fonts = [ "Cousine" ]; }) ];

    hardware =
      { keyboard.zsa.enable = true;
        pulseaudio.enable = true;
      };

    icons.users.mason =
      { cursor = p.icons.breeze.cursors.breeze;
        mutableIcons = false;
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
        package = p.nixUnstable;

        registry =
          { nixpkgs =
              { from =
                  { id = "nixpkgs";
                    type = "indirect";
                  };

                to =
                  { owner = "NixOS";
                    repo = "nixpkgs";
                    ref = "nixpkgs-unstable";
                    type = "github";
                  };
              };

            utils =
              { from =
                  { id = "utils";
                    type = "indirect";
                  };

                to =
                  { owner = "ursi";
                    repo = "flake-utils";
                    type = "github";
                  };
              };
          };

        trustedUsers = [ "mason" "root" ];
      };

    programs =
      { bash.shellAliases =
          { nix-use = "nix-env -if nix.nix";
            nix-remove = "nix-env -e nix";
            nixbuild = "nix build -f .";
            nixshell = "nix develop -f shell.nix";
          };

        nm-applet.enable = true;
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

    system.autoUpgrade.enable = true;
    time.timeZone = "America/Toronto";

    users =
      { mutableUsers = false;

        users =
          { mason =
              { createHome = true;
                description = "Mason Mackaman";
                extraGroups = [ "networkmanager" "plugdev" "wheel" ];
                isNormalUser = true;

                packages = with pkgs;
                  let
                    communication =
                      [ discord
                        mattermost-desktop
                        signal-desktop
                        zulip
                      ];

                    editor =
                      let
                        elm = with elmPackages;
                          [ elm-language-server
                            elm-format
                          ];

                        haskell = with haskellPackages;
                          [ haskell-language-server ];

                        node = with nodePackages;
                          [ purty
                            purescript-language-server
                          ];
                      in
                        elm ++ haskell ++ node;
                  in
                    [ gnome3.nautilus # for seeing images
                      nodePackages.node2nix
                      (writeShellScriptBin
                        "snowball"
                        "bash <( curl https://gitlab.com/fresheyeball/snowball/-/raw/master/generator.sh )"
                      )
                      slippi-netplay
                      wally-cli
                    ]
                      ++ communication
                      ++ editor
                      ++ flakePackages;

                password = "";
              };

            root =
              { extraGroups = [ "root" ];
                password = "";
              };
          };
      };
  }
