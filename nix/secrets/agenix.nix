{ config, lib, ... }:
  let l = lib; t = l.types; in
  { options.agenix.enable =
      l.mkOption
        { type = t.bool;
          default = true;
        };

    config =
      l.mkIf config.agenix.enable
        { age.secrets.netrc.file = ./netrc.age;
          nix.extraOptions = "netrc-file = ${config.age.secrets.netrc.path}";
          services.openssh.enable = true;
        };
  }
