{ inputs =
    { agenix.url = "github:ryantm/agenix";
      breeze.url = "github:ursi/breeze";
      brightness.url = "github:ursi/brightness";
      flake-make.url = "github:ursi/flake-make";
      hours.url = "github:ursi/hours";
      im-home.url = "github:ursi/im-home";
      localVim.url = "github:ursi/nix-local-vim";
      nixos-hardware.url = "github:ursi/nixos-hardware/microsoft-surface-wifi";
      nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
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
    , localVim
    , nixos-hardware
    , nixos-unstable
    , nixpkgs
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
            config.allowUnfree = true;

            overlays =
              [ (_: _:
                  { hours = hours.packages.${system}.default;
                    icons = { breeze = breeze.packages.${system}; };

                    flake-packages =
                      utils.defaultPackages system
                        { inherit agenix flake-make; };

                    flake-packages-gui =
                      utils.defaultPackages system
                        { inherit brightness; };

                    inherit
                      (import nixos-unstable
                         { inherit system; config.allowUnfree = true; }
                      )
                      brave
                      discord
                      neovim
                      nix
                      nix-du
                      tmux
                      vimPlugins
                      zulip;
                  }
                )

                (_: prev:
                   { neovim =
                      import ./neovim
                        { inherit (localVim) mkOverlayableNeovim;
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
        let gaming = import ./gaming.nix { ssbm = ssbm.packages.${system}; }; in
        mapAttrs
          (hostName: modules:
             l.nixosSystem
               { inherit pkgs system;
                 modules =
                   [ { _module.args = { inherit nixpkgs; };
                       networking = { inherit hostName; };
                     }

                     ./configuration.nix
                     (./systems + "/${hostName}")
                     agenix.nixosModules.age
                     ssbm.nixosModule
                     z.nixosModule
                   ]
                   ++ attrValues im-home.nixosModules
                   ++ modules;
               }
          )
          { desktop-2019 = [ gaming ./gui.nix ];
            do-nixos-0 = [];
            hp-envy = [ gaming ./gui.nix ];

            surface-go =
              [ ./gui.nix
                nixos-hardware.nixosModules.microsoft-surface
              ];
          };

      packages.${system} = { inherit (p) neovim; };
    };
}
