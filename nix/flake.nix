{
  inputs = {
    brightness.url = "github:ursi/brightness";
    flake-make.url = "github:ursi/flake-make";
    json-format.url = "github:ursi/json-format";

    localVim.url = "github:ursi/nix-local-vim";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self, nixpkgs,
      utils, localVim,
      brightness, flake-make, json-format,
    }:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            (_: _: {
              flakePackages = utils.defaultPackages system {
                inherit brightness flake-make json-format;
              };
            })
          ];
        };

        neovim = import ./neovim.nix {
          inherit (localVim) mkOverlayableNeovim;
          inherit (nixpkgs.legacyPackages.${system}) neovim vimPlugins;
        };
      in
        {
          packages.${system}.neovim = neovim;

          nixosConfigurations.desktop =
            nixpkgs.lib.nixosSystem
              { inherit pkgs system;

                modules =
                  [ ./configuration.nix
                    ./desktop
                  ];
              };
        };
}
