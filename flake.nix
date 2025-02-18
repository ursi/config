{ inputs =
    { agenix.url = "github:montchr/agenix/flake-outputs-current";
      bevel = { url = "github:NorfairKing/bevel/development";
                inputs = { home-manager.follows = "home-manager";
                           nixpkgs.follows = "nixpkgs";
                         };
              };
      breeze.url = "github:ursi/breeze";
      brightness.url = "github:ursi/brightness";
      flake-make.url = "github:ursi/flake-make";
      hours.url = "github:ursi/hours";
      home-manager = { url = "github:nix-community/home-manager/release-24.11";
                       inputs.nixpkgs.follows = "nixpkgs";
                     };
      localVim.url = "github:ursi/nix-local-vim";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      slippi-nix = { url = "github:lytedev/slippi-nix";
                     inputs = { home-manager.follows = "home-manager";
                                nixpkgs.follows = "nixpkgs";
                              };
                   };
      z.url = "github:ursi/z-nix";
    };

  outputs = { nixpkgs, z, ... }@inputs: with builtins;
    let
      l = nixpkgs.lib; p = pkgs;
      system = "x86_64-linux";

      pkgs =
        let default-packages = l.mapAttrsToList (_: v: v.packages.${system}.default); in
        import nixpkgs
          { inherit system;
            config.allowUnfree = true;

            overlays =
              [ (_: _:
                  { hours = inputs.hours.packages.${system}.default;
                    icons = { breeze = inputs.breeze.packages.${system}; };

                    flake-packages =
                      default-packages
                        { inherit (inputs) agenix flake-make; };

                    flake-packages-gui =
                      default-packages
                        { inherit (inputs) brightness; };

                    inherit
                      (import inputs.nixos-unstable
                         { inherit system; config.allowUnfree = true; })
                      brave
                      hexgui
                      neovim
                      signal-desktop
                      tmux
                      tor-browser-bundle-bin
                      vimPlugins;
                  }
                )

                (_: prev:
                   { neovim =
                      import ./neovim
                        { inherit (inputs.localVim) mkOverlayableNeovim;
                          pkgs = prev;
                        };
                   }
                )

                z.overlay
              ];
          };

      make-app = pkg: bin-and-flags:
        { type = "app";

          program =
            (p.writeScript "wrapped-tmux"
               ''
               ${pkg}/bin/${bin-and-flags} "$@";
               ''
            ).outPath;
        };
    in
    { apps.${system} =
        { neovim = make-app p.neovim "nvim";
          tmux = make-app p.tmux "tmux -f ${./tmux.conf}";
        };

      nixosConfigurations =
        let gaming = import ./gaming.nix { ssbm = inputs.slippi-nix; }; in
        mapAttrs
          (hostName: modules:
             l.nixosSystem
               { inherit pkgs system;
                 modules =
                   [ { _module.args =
                        { inherit inputs nixpkgs; };
                       networking = { inherit hostName; };
                     }

                     inputs.home-manager.nixosModules.home-manager
                     { home-manager =
                         { useGlobalPkgs = true;
                           useUserPackages = true;
                         };
                     }

                     ./configuration.nix
                     (./systems + "/${hostName}")
                     inputs.agenix.nixosModules.age
                     z.nixosModule
                   ]
                   ++ modules;

                 specialArgs.mmm = import ./my-modules/mmm.nix l;
               }
          )
          { desktop-2019 = [ gaming ./gui.nix ];
            do-nixos-0 = [];
            hp-envy = [ gaming ./gui.nix ];

            surface-go =
              [ ./gui.nix
                inputs.nixos-hardware.nixosModules.microsoft-surface-go
              ];
          };

      packages.${system} = { inherit (p) neovim; };
    };
}
