{ config, ... }:
  { age.secrets.netrc.file = ./netrc.age;
    nix.extraOptions = "netrc-file = ${config.age.secrets.netrc.path}";
    services.openssh.enable = true;
  }
