{ inputs =
    { breeze.url = "github:ursi/breeze";
      brightness.url = "github:ursi/brightness";
      flake-make.url = "github:ursi/flake-make";
      json-format.url = "github:ursi/json-format";
      localVim.url = "github:ursi/nix-local-vim";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

  outputs =
    { self
    , nixpkgs
    , utils
    , breeze
    , localVim
    , brightness
    , flake-make
    , json-format
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

                      flakePackages =
                        utils.defaultPackages system
                          { inherit brightness flake-make json-format; };
                    }
                  )
                ];
            };

        neovim =
          import ./neovim.nix
            { inherit (localVim) mkOverlayableNeovim;
              inherit (nixpkgs.legacyPackages.${system}) neovim vimPlugins;
            };
      in
        { nixosConfigurations = with nixpkgs.lib;
            mapAttrs
              (_: modules:
                nixosSystem
                  { inherit pkgs system;
                    modules = [ ./configuration.nix ] ++ modules;
                  }
              )
              { desktop-2019 = [ ./desktop-2019 ];
                hp-envy = [ ./hp-envy ];
              };

          packages.${system} =
            { inherit (pkgs) alacritty;
              inherit neovim;

              icons =
                import ./icons.nix
                  { inherit pkgs;
                    cursor = breeze.packages.${system}.cursors.breeze;
                  };
            };
        };
}
