{ pkgs, lib, config, ...}:
  let b = builtins; l = lib; p = pkgs; t = l.types; in
  { imports = [ ./create-text-file.nix ];

    options =
      { user-files =
          l.mkOption
            { type =
                t.attrsOf config.options.create-text-file;
                  # (t.attrsOf
                  #    (t.submodule
                  #       { options =
                  #           { text =
                  #               l.mkOption
                  #                 { type = t.nullOr t.str;
                  #                   default = null;
                  #                 };

                  #             overwrite-existing =
                  #               l.mkOption
                  #                 { type = t.bool;
                  #                   default = false;
                  #                 };

                  #             remove-if-null =
                  #               l.mkOption
                  #                 { type = t.bool;
                  #                   default = false;
                  #                 };
                  #           };
                  #       }
                  #    )
                  # );

              default = {};
            };
      };

    config =
      { create-text-file =
          b.foldl'
            (acc: v: acc // v)
            {}
            (b.attrValues
               (l.mapAttrs
                  (user: files:
                     l.mapAttrs'
                       (path: file:
                          l.nameValuePair
                            "${config.users.users.${user}.home}/${path}"
                            file
                       )
                       files
                  )
                  config.user-files
               )
            );
      };
  }
