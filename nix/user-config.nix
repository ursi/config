{ pkgs, lib, config, ...}:
  let
    b = builtins; l = lib; p = pkgs; t = l.types;
    ini = p.formats.ini {};

    make-file-option = content-type:
      l.mkOption
        { type =
            t.submodule
              { options =
                  { content =
                      l.mkOption
                        { type = t.nullOr content-type;
                          default = null;
                        };

                    preserve =
                      l.mkOption
                        { type = t.bool;
                          default = true;
                        };
                  }
              };

          default = {};
        };

    helper = options:
      l.mkOption
        { type =
            t.submodule
              { options = l.mapAtters (opt: make-file-option) options; };

          default = {};
        };
  in
  { options =
      { user-config =
          l.mkOption
            { type =
                t.attrsOf
                  (t.submodule
                     { options =
                         { "gtk-3.0" =
                             helper { settings = ini.type; };
                         }
                     };
                  );

              default = {};
            }
      };

    config =
      { user-derivation-links =
          l.mapAttrs
            (_: conf:
               let
                 if-in = set: attribute: f:
                   if set?${attribute} then
                     f set.${attribute}
                   else
                     [];
               in
               if-in conf "gtk-3.0"
                 (files:
                    let cfg = conf."gtk-3.0"; in
                    if-in files "settings"
                      (settings:
                         [ { target = ini.generate "settings.ini" cfg.settings.content;
                             path = "/.config/gtk-3.0/settings.ini";
                             inherit (cfg.settings) preserve;
                           }
                         ]
                      )
                 )
            )
            config.user-config;
      };
  }
