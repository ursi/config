{
  inputs.brightness.url = "github:ursi/brightness";

  outputs = { self, nixpkgs, brightness }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ (self: super: { brightness = brightness.defaultPackage.${system}; }) ];
      };
    in
      {
         nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
           inherit pkgs system;
           modules = [ ./configuration.nix ];
         };
      };
}
