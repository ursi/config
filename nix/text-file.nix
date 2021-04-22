{ pkgs, lib, config, ...}:
  let
    b = builtins; l = lib; p = pkgs; t = l.types;
    ini = p.formats.ini { listsAsDuplicateKeys = true; };

    make-link-type = content-option:
      t.listOf
        (t.submodule
           { options =
               { path = l.mkOption { type = t.path; };

                 preserve =
                   l.mkOption
                     { type = t.bool;
                       default = true;
                     };
               }
               // content-option;
           }
        );

    make-link-type' = content-options:
      make-link-type
        (l.mapAttrs
           (_: type:
              l.mkOption
                { type = t.nullOr type;
                  default = null;
                }
           )
           content-options
        );

    make-link-option = content-options:
      l.mkOption
        { type = make-link-type content-options;
          default = {};
        };

    make-link-option' = content-options:
      l.mkOption
        { type = make-link-type' content-options;
          default = {};
        };

    make-ini-file-type =
      make-link-type
        { text =
            l.mkOption
              { type = t.nullOr ini.type;
                default = null;
              };
        };

    make-derivation-type =
      make-link-type
        { target =
            l.mkOption
              { type = t.nullOr t.package;
                default = null;
              };
        };

    make-text-file-type =
      make-link-type
        { text =
            l.mkOption
              { type = t.nullOr t.str;
                default = null;
              };
        };

    make-user-version = option:
      l.mkOption
        { type = t.attrsOf option.type;
          default = {};
        };

    link-options =
      { derivations = make-link-option' { target = t.package; };

        other =
          make-link-option
            { map =
                l.mkOption
                  { type = t.anything;
                    default = l.id;
                  };

              to-target =
                l.mkOption
                  { type = t.nullOr t.anything;
                    default = null;
                  };
            };

        # text-files = make-link-option' { text = t.str; };

        text-files =
          l.mkOption
            { type =
                t.listOf
                  (t.submodule
                     { options =
                         { text =
                             l.mkOption
                               { type = t.nullOr t.str;
                                 default = null;
                               };

                           path = l.mkOption { type = t.path; };

                           preserve =
                             l.mkOption
                               { type = t.bool;
                                 default = true;
                               };
                         };
                     }
                  );

              default = {};

              apply =
                b.map
                  (link:
                     b.removeAttrs link [ "text" ]
                     // { target = l.mapNullable link.text (p.writeText link.path); }
                  );
            };
      };

    user-link-options =
      l.mapAttrs
        (_: option:
           l.mkOption
             { type = t.attrsOf option.type;
               default = {};
             }
        )
        link-options;
  in
  { options.links =
      { users =
          l.mkOption
            { type = t.attrsOf (t.submodule { options = link-options; });
              default = {};
            };
      }
      // link-options;
    /*
    links.users."path to file" =
      { value = <anything>
        type = <string or implied>
        path = ...
        preserve = ...
      }
    */

    config =
      let
        process-user-links = user-links:
          b.concatLists
            (l.mapAttrsToList
               (user: links:
                  b.map
                    (link: link // { path = config.users.users.${user}.home + link.path; })
                    links
               )
               user-links
            );
      in
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
               config.links.derivations
            );

        links.derivations =
          b.concatLists
            (l.mapAttrsToList
               (user: links:
                  b.map
                    (link: link // { path = config.users.users.${user}.home + link.path; })
                    links.derivations
               )
               config.links.users
            )
          ++ config.links.text-files;
          # process-user-links config.links.users
          # ++ b.map
          #      (link:
          #         b.removeAttrs link [ "text" ]
          #         // { target =
          #                if link.text == null then null
          #                else p.writeText link.path link.text;
          #            }
          #      )
          #      config.text-file-links;

        links.users =
          l.mapAttrs
            (_: links:
               links
               // { derivations =
                      with links;
                      derivations
                      // text-files;
                  }
            )
            config.links.users;
      };
  }
      # { derivation-links =
      #     l.mkOption
      #       { type = make-derivation-type;
      #         default = {};
      #       };

      #   user-derivation-links =
      #     l.mkOption
      #       { type = t.attrsOf make-derivation-type;
      #         default = {};
      #       };

      #   other-links =
      #     l.mkOption
      #       { type =
      #           make-link-type
      #             { map =
      #                 l.mkOption
      #                   { type = t.anything;
      #                     default = l.id;
      #                   };

      #               to-target =
      #                 l.mkOption
      #                   { type = t.nullOr t.anything;
      #                     default = null;
      #                   }
      #             }
      #       };

      #   ini-file-links =
      #     l.mkOption
      #       { type = make-text-file-type;
      #         default = {};
      #       };

      #   text-file-links =
      #     l.mkOption
      #       { type = make-text-file-type;
      #         default = {};
      #       };

      #   user-text-file-links =
      #     l.mkOption
      #       { type = t.attrsOf make-text-file-type;
      #         default = {};
      #       };
      # };
