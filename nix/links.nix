{ pkgs, lib, config, ...}:
  let
    b = builtins; l = lib; p = pkgs; t = l.types;
    ini = p.formats.ini { listsAsDuplicateKeys = true; };

    annotated = import ./annotated.nix p;
    null-or = import ./null-or.nix p;

    conversions =
      { ini = ini.generate "ini";
        lines = p.writeText "lines";
        package = l.id;
        str = p.writeText "str";
      };

    link-options =
      l.mkOption
        { type =
            t.attrsOf
              (null-or
                 (t.addCheck
                    annotated
                    (v:
                       if v != null then
                         b.elem v.type (b.attrNames conversions)
                       else
                         true
                    )
                 )
              );
              # (t.submodule
              #    ({ name, ... }:
              #       { options =
              #           { path = l.mkOption { path = t.path; };

              #             target =
              #           };

              #         config.path = l.mkDefault name
              #       }
              #    )
              # );

          default = {};

          apply =
            l.mapAttrsToList
              (path: target:
                 if t.path.check path then
                   { inherit (path);
                     target =
                       l.mapNullable
                         (targ: conversions.${targ.type} targ.value)
                         target;
                   }
                 else
                   b.throw "${path} did not pass 'types.path.check'"
              );
        };

    # user-link-options =
    #   l.mapAttrs
    #     (_: option:
    #        l.mkOption
    #          { type = t.attrsOf option.type;
    #            default = {};
    #          }
    #     )
    #     link-options;
  in
  { options.links =
      # { users =
      #     l.mkOption
      #       { type = t.attrsOf (t.submodule { options = link-options; });
      #         default = {};
      #       };
      # }
     link-options;
    /*
    links.users."path to file" =
      { value = <anything>
        type = <string or implied>
        path = ...
        preserve = ...
      }
    */

    config =
      { system.activationScripts =
          l.listToAttrs
            (b.map
               (link:
                  let
                    path = l.escapeShellArg link.path;
                    dir = l.escapeShellArg (b.dirOf link.path);

                    link-drv-cmd =
                      if link.target != null then
                        ''
                        rm -fr ${path}
                        ln -s ${link.target} ${path}
                        ''
                      else
                        ":";
                  in
                  l.nameValuePair
                    ("derivation-links-" + link.path)
                    ''
                    ${if link.target == null && !link.preserve then
                        "rm -fr ${path}"
                      else
                        ""
                    }

                    if [[ ! -e ${dir} ]]; then
                      mkdir -p ${dir}
                    fi

                    if [[ -e ${path} ]]; then
                      ${if !link.preserve then
                          link-drv-cmd
                        else
                          ":"
                      }
                    else
                      ${link-drv-cmd}
                    fi
                    ''
               )
               config.links
            );
      };
  }
