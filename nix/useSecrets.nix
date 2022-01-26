{ config, lib, ... }:
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key.pub" ];
    secrets = {
      ardana-cachix-auth = {
        group = "wheel";
        mode = "0040";
        file = secrets/ardana-cachix-auth.age;
      };
    };
  };
  nix.extraOptions = ''
    netrc-file = ${config.age.secrets.ardana-cachix-auth.path}
  '';
}
