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
      { system.activationScripts =
          l.mapAttrs'
            (name: v:
               let
                 inherit (v) cursor;

                 gtk =
                   { path = "${home}/.config/gtk-3.0";

                     drv =
                       p.writeTextDir "/settings.ini"
                         ''
                         [Settings]
                         gtk-cursor-theme-name=${cursor.name}
                         '';
                   };

                 home = config.users.users.${name}.home;

                 icons =
                   { path = "${home}/.local/share/icons";

                     drv =
                       let
                         default =
                           p.writeTextDir "/index.theme"
                             ''
                             [icon theme]
                             Inherits=${cursor.name}
                             '';
                       in
                       p.runCommand "icons" {}
                         ''
                         mkdir $out
                         cd $out
                         ln -s ${cursor} ${cursor.name}
                         ln -s ${default} default
                         '';
                   };
               in
               l.nameValuePair
                 ("icons-" + name)
                 ''
                 ${if config.icons.users.${name}.mutableIcons then ""
                   else "rm -rf ${gtk.path} ${icons.path}"
                 }

                 ${if cursor != null then
                     ''
                     ln -s ${gtk.drv} ${gtk.path}
                     ln -s ${icons.drv} ${icons.path}
                     ''
                   else
                      ""
                 }
                 ''
            )
            config.icons.users;
      };
  }
