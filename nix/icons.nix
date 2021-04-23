{ pkgs, lib, config, ...}:
  let l = lib; p = pkgs; t = l.types; in
  { options =
      { icons.users =
          l.mkOption
            { type =
                t.attrsOf
                  (t.submodule
                     { options =
                         { cursor =
                             l.mkOption
                               { type = t.nullOr t.package;
                                 default = null;
                               };

                           mutableIcons =
                             l.mkOption
                               { type = t.bool;
                                 default = true;
                               };
                         };
                     }
                  );

              default = {};
            };
      };

    config =
      { links.users =
          l.mapAttrs
            (_: submod:
               let bindCursor = f: l.mapNullable f submod.cursor; in
               { ini =
                   { "/.config/gtk-3.0/settings.ini" =
                       bindCursor
                         (cursor:
                            { Settings = { gtk-cursor-theme-name = cursor.name; }; }
                         );

                     "/.local/share/icons/default/index.theme" =
                        bindCursor
                          (cursor:
                             { "icon theme" = { Inherits = cursor.name; }; }
                          );
                   };

                 package =
                   let inherit (submod) cursor; in
                   if cursor != null then
                     { "/.local/share/icons/${cursor.name}" = cursor; }
                   else
                     {};
               }
            )
            config.icons.users;
      };
  }
