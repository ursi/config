with builtins;
{ config, lib, ... }:
  let l = lib; t = l.types; in
  { options =
      { users.users =
          l.mkOption
            { type =
              let global-cfg = config; in
              t.attrsOf
                (t.submodule
                   ({ config, ... }:
                      { options.remote-builder =
                          { enable = l.mkEnableOption "Become a remote builder";
                            keys = l.mkOption { type = t.listOf t.str; default = []; };
                          };

                        config =
                          let cfg = config.remote-builder; in
                          l.mkIf cfg.enable
                            { openssh.authorizedKeys = { inherit (cfg) keys; }; };
                      }
                   )
                );
            };

        remote-builder =
          { enable = l.mkEnableOption "Use a remote builder";
            user = l.mkOption { type = t.str; default = ""; };
          };
      };

    config =
      let
        server-ip = "159.65.254.51";
        ssh-port = head config.services.openssh.ports;
        special-port = "42069";
        setup-host = "remote-builder-setup";

        builder-condition =
          any
            ({ value, ... }: value.remote-builder.enable)
            (l.mapAttrsToList l.nameValuePair config.users.users);
      in
      # using an if expression causes an infinite recursion apparently
      l.mkMerge
        [ (l.mkIf builder-condition
             { programs.ssh.extraConfig =
                 ''
                 Host ${setup-host}
                 Hostname ${server-ip}
                 RemoteForward ${special-port} localhost:${toString ssh-port}
                 '';
             }
          )

          (l.mkIf (config.remote-builder.enable)
             { programs.ssh.extraConfig =
                 ''
                 Host ${setup-host}
                 Hostname ${server-ip}
                 LocalForward ${special-port} localhost:${special-port}

                 Host builder
                 Hostname localhost
                 Port ${special-port}
                 User ${config.remote-builder.user}
                 '';
             }
          )
        ];
  }
