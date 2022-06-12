{ inputs =
    { hours =
        { flake = false;
          url = "github:Quelklef/hours";
        };

      nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    };

  outputs =
    { hours
    , nixos-unstable
    , nixpkgs
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
                  { hours = import hours { inherit system; };

                    inherit (nixos-unstable.legacyPackages.${system})
                      nix
                      tmux;
                  }
                )
              ];
          };
    in
    { nixosConfigurations =
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
                   ]
                   ++ modules;
               }
          )
          { do-nixos-0 = []; };
    };
}
