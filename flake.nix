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
      localVim.url = "github:ursi/nix-local-vim";
      nixos-hardware.url = "github:ursi/nixos-hardware/microsoft-surface-wifi";
      nixpkgs.url = "github:NixOS/nixpkgs/fa76c9801d0ad7b6a8bd0092202e5bfb102b318a";
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
    , localVim
    , nixos-hardware
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
                  { hours = import hours { inherit system; };
                    icons = { breeze = breeze.packages.${system}; };

                    flake-packages =
                      utils.defaultPackages system
                        { inherit agenix brightness flake-make; };

                    neovim =
                      import ./neovim
                        { inherit (localVim) mkOverlayableNeovim;
                          pkgs = super;
                        };

                    inherit (nixpkgs-stable.legacyPackages.${system})
                      formats
                      torbrowser
                      wxcam;
                  }
                )

                z.overlay
              ];
          };

      make-app = pkg: exe:
        { type = "app";
          program = "${pkg}/bin/${exe}";
        };
    in
    { apps.${system}.neovim = make-app p.neovim "nvim";

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
          { desktop-2019 = [ gaming ];
            hp-envy = [ gaming ];
            surface-go = [ nixos-hardware.nixosModules.microsoft-surface ];
          };

      packages.${system} = { inherit (p) neovim; };
    };
}
