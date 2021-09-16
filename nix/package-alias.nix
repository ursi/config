with builtins;
{ config, lib, pkgs, ... }:
  let l = lib; p = pkgs; t = lib.types; in
  { options.environment.pkgs-with-aliases =
      l.mkOption
        { type =
            t.listOf
              (t.submodule
                 { options =
                     { pkg = l.mkOption { type = t.package; };

                       aliases =
                         l.mkOption
                           { type = t.attrsOf t.str;
                             default = {};
                           };

                       functions =
                         l.mkOption
                           { type = t.attrsOf t.str;
                             default = {};
                           };
                     };
                 }
              );

          default = {};
        };

    config =
      let cfg = config.environment.pkgs-with-aliases; in
      { environment.systemPackages = map (a: a.pkg) cfg;

        programs.bash =
          { shellAliases = foldl' (acc: a: acc // a.aliases) {} cfg;

            promptInit =
              let
                functions =
                  concatStringsSep "\n"
                    (l.mapAttrsToList
                       (name: value:
                          ''
                          ${name}() {
                            ${value}
                          }
                          ''
                       )
                       (foldl' (acc: a: acc // a.functions) {} cfg)
                    );
              in
              ''
              if shopt expand_aliases > /dev/null; then
                shopt -u expand_aliases
                ${functions}
                shopt -s expand_aliases
              else
                ${functions}
              fi
              '';
          };
      };
  }
