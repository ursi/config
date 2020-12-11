{
  inputs.brightness.url = "github:ursi/brightness";

  outputs =
    {
      self, nixpkgs,
      utils,
      brightness
    }:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            (utils.mkFlakePackages system { inherit brightness; })
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
