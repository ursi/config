{ inputs =
    { agenix.url = "github:ryantm/agenix";
      breeze.url = "github:ursi/breeze";
      brightness.url = "github:ursi/brightness";
      flake-make.url = "github:ursi/flake-make";

      hours =
        { flake = false;
          url = "github:ursi/hours";
        };

      im-home.url = "github:ursi/im-home";
      json-format.url = "github:ursi/json-format";
      localVim.url = "github:ursi/nix-local-vim";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
      ssbm.url = "github:djanatyn/ssbm-nix";
      z.url = "github:ursi/z-nix";
    };

  outputs =
    { agenix
    , breeze
    , brightness
    , flake-make
    , hours
    , im-home
    , json-format
    , localVim
    , nixpkgs
    , nixpkgs-stable
    , ssbm
    , utils
    , z
    , ...
    }:
    with builtins;
    let
      l = nixpkgs.lib; p = pkgs;
      system = "x86_64-linux";

      pkgs =
        import nixpkgs
          { inherit system;
            config = { allowUnfree = true; };

            overlays =
              [ (_: super:
                  { hours = import hours { pkgs = super; inherit system; };
                    icons = { breeze = breeze.packages.${system}; };

                    flake-packages =
                      utils.defaultPackages system
                        { inherit agenix brightness flake-make json-format; };

                    neovim =
                      import ./neovim
                        { inherit (localVim) mkOverlayableNeovim;
                          pkgs = super;
                        };

                    inherit (nixpkgs-stable.legacyPackages.${system})
                      formats
                      torbrowser;
                  }
                )

                ssbm.overlay
                z.overlay
              ];
          };

      make-app = pkg: exe:
        { type = "app";
          program = "${pkg}/bin/${exe}";
        };
    in
    { apps.${system}.neovim.neovim = make-app p.neovim "nvim";

      nixosConfigurations =
        mapAttrs
          (_: modules:
             l.nixosSystem
               { inherit pkgs system;
                 modules =
                   [ { _module.args = { inherit nixpkgs; }; }
                     ./configuration.nix
                     agenix.nixosModules.age
                     ssbm.nixosModule
                     z.nixosModule
                   ]
                   ++ attrValues im-home.nixosModules
                   ++ modules;
               }
          )
          { desktop-2019 = [ ./desktop-2019 ];
            hp-envy = [ ./hp-envy ];
          };

      packages.${system} =
        { inherit (p) alacritty;
          inherit neovim;
        };
    };
}
