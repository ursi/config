{ pkgs, lib, config, ...}:
  let
    b = builtins; l = lib; p = pkgs; t = l.types;
    annotated = import ./annotated.nix p;
    null-or = import ./null-or.nix p;

    formats =
      { ini = p.formats.ini {};
        json = p.formats.json {};
        toml = p.formats.toml {};
        yaml = p.formats.yaml {};
      };

    conversions =
      l.mapAttrs
        (format: v:
           { convert = v.generate format;
             type = v.type;
           }
        )
        formats
      // l.mapAttrs
           (type: convert:
              { inherit convert;
                type = t.${type};
              }
           )
           { lines = p.writeText "lines";
             package = l.id;
             str = p.writeText "str";
           };

    path-set = type:
      t.addCheck
        (t.attrsOf type)
        (set: b.all t.path.check (b.attrNames set))
      // { description = "set of ${type.name} with attributes that are paths"; };

    conversion-set = type:
      let ann-plus-conv = [ "annotated" ] ++ b.attrNames conversions; in
      t.addCheck
        (t.attrsOf type)
        (set: b.all (l.flip b.elem ann-plus-conv) (b.attrNames set))
      // { description = "set of ${type.name} with attributes that are one of '${b.concatStringsSep ", " ann-plus-conv}'"; };

    all-attrs = pred: set: b.all l.id (l.mapAttrsToList pred set);

    conversion-options =
      l.mapAttrs
        (type: v:
           l.mkOption
             { type = path-set (null-or v.type);
               default = {};
             }
        )
        conversions;

    link-options =
      l.mkOption
        { type =
            t.submodule
              { options =
                  { annotated =
                      l.mkOption
                        { type = path-set (null-or annotated);
                          default = {};
                        };

                    users =
                      l.mkOption
                        { type = t.attrsOf (t.submodule { options = conversion-options; });
                          default = {};
                        };
                  }
                  // conversion-options;
              };
            # t.addCheck
            #   (conversion-set
            #      (path-set
            #          (null-or t.anything
            #             # (t.addCheck
            #             #    annotated
            #             #    (v:
            #             #       if v != null then
            #             #         b.elem v.type (b.attrNames conversions)
            #             #       else
            #             #         true
            #             #    )
            #             # )
            #          )
            #      )
            #   )
            #   (v:
            #      all-attrs
            #        (type: path-set:
            #           all-attrs
            #             (_: value:
            #                if value == null then
            #                  true
            #                else if type == "annotated" then
            #                  annotated.check value
            #                else
            #                  annotated.check { inherit type value; }
            #             )
            #             path-set
            #        )
            #        v
            #   );

              # (t.addCheck
              #    conversion-set (null-or t.anything)
              #    (v:
              #       b.all l.id
              #         (l.mapAttrsToList
              #            (type: value:
              #               annotated.check { inherit type value; }
              #            )
              #            v
              #         )
              #    )
              # );

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

          # apply = links:
          #   links
          #   // { list =
          #          l.mapAttrsToList
          #            (path: target:
          #               { inherit path;
          #                 target =
          #                   l.mapNullable
          #                     (targ: conversions.${targ.type} targ.value)
          #                     target;
          #               }
          #            )
          #            links.annotated;
          #      };
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
          # l.listToAttrs
            (l.mapAttrs'
               (unescaped-path: value:
                  let
                    path = l.escapeShellArg unescaped-path;
                    dir = l.escapeShellArg (b.dirOf unescaped-path);
                    target =
                      l.mapNullable
                        (v: conversions.${v.type}.convert v.value)
                        value;
                  in
                  l.nameValuePair
                    ("derivation-links-" + unescaped-path)
                    ''
                    ${p.trash-cli}/bin/trash-put -f ${path}

                    if [[ ! -e ${dir} ]]; then
                      mkdir -p ${dir}
                    fi

                    ${if target != null then
                        "ln -s ${target} ${path}"
                      else
                        ""
                    }
                    ''
               )
               config.links.annotated
            );

        links.annotated =
          let
            make-annotated =
              l.mapAttrsToList
                (type: path-set:
                   l.mapAttrs
                     (_: l.mapNullable (value: { inherit type value; }))
                     path-set
                );
          in
          l.mkMerge
            ((make-annotated (b.removeAttrs config.links [ "annotated" "users" ]))
             ++ (b.concatLists
                   (l.mapAttrsToList
                      (user: type-set:
                         b.map
                           (l.mapAttrs'
                              (path: v:
                                 l.nameValuePair
                                   (config.users.users.${user}.home + path)
                                   v
                              )
                           )
                           (make-annotated type-set)
                      )
                      config.links.users
                   )
                )
            );
      };
  }
