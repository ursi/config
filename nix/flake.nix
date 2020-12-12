{
  inputs = {
    brightness.url = "github:ursi/brightness";
    json-format.url = "github:ursi/json-format";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-signal.url = "github:NixOS/nixpkgs/22148780509c003bf5288bba093051a50e738ce9";
  };

  outputs =
    {
      self, nixpkgs,
      utils,
      brightness, json-format,
      nixpkgs-signal
    }:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            (utils.mkFlakePackages system { inherit brightness json-format; })
            (_: _: { inherit (nixpkgs-signal.legacyPackages.${system}) signal-desktop; })
          ];
        };
      in
        {
           nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
             inherit pkgs system;
             modules = [ ./configuration.nix ];
           };
        };
}
