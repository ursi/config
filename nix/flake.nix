{
  inputs = {
    brightness.url = "github:ursi/brightness";
    json-format.url = "github:ursi/json-format";
  };

  outputs =
    {
      self, nixpkgs,
      utils,
      brightness, json-format,
    }:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            (utils.mkFlakePackages system { inherit brightness json-format; })
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
