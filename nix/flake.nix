{ inputs =
    { breeze.url = "github:ursi/breeze";
      brightness.url = "github:ursi/brightness";
      flake-make.url = "github:ursi/flake-make";
      json-format.url = "github:ursi/json-format";
      localVim.url = "github:ursi/nix-local-vim";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      ssbm.url = "github:djanatyn/ssbm-nix";
    };

  outputs =
    { nixpkgs
    , utils
    , breeze
    , brightness
    , flake-make
    , json-format
    , localVim
    , ssbm
    , ...
    }:
    let
      system = "x86_64-linux";

      pkgs =
        import nixpkgs
          { inherit system;
            config = { allowUnfree = true; };

            overlays =
              [ (_: super:
                  { alacritty =
                      super.writeScriptBin "alacritty"
                        ''
                        if [[ $@ = *--config-file* ]]; then
                          ${super.alacritty}/bin/alacritty $@;
                        else
                          ${super.alacritty}/bin/alacritty --config-file ${../alacritty.yml} $@;
                        fi
                        '';

                    icons = { breeze = breeze.packages.${system}; };

                    flakePackages =
                      utils.defaultPackages system
                        { inherit brightness flake-make json-format; };
                  }
                )
                ssbm.overlay
              ];
          };

      neovim =
        import ./neovim.nix
          { inherit (localVim) mkOverlayableNeovim;
            inherit (nixpkgs.legacyPackages.${system}) neovim vimPlugins;
          };

      make-app = pkg: exe:
        { type = "app";
          program = "${pkg}/bin/${exe}";
        };
    in
    { apps.${system} =
        { alacritty = pkgs.alacritty;
          neovim = make-app neovim "nvim";
        };

      devShell.${system} =
        pkgs.mkShell
          { shellHook =
              ''
              nixos-work-test() {
                sudo nixos-rebuild test \
                  && git restore flake.lock
              }

              nixos-work-switch() {
                sudo nixos-rebuild switch \
                  && git restore flake.lock
              }
              '';
          };

    nixosConfigurations = with nixpkgs.lib;
        mapAttrs
          (_: modules:
             nixosSystem
               { inherit pkgs system;
                 modules =
                   [ ./configuration.nix
                     ssbm.nixosModule
                     ./icons.nix
                   ]
                   ++ modules;
               }
          )
          { desktop-2019 = [ ./desktop-2019 ];
            hp-envy = [ ./hp-envy ];
          };

      packages.${system} =
        { inherit (pkgs) alacritty;
          inherit neovim;
        };
    };
}
