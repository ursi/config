with builtins;
{ config, lib, pkgs, ... }:
  let l = lib; p = pkgs; t = lib.types; in
  { options.environment.packages-extra =
      l.mkOption
        { type =
            t.listOf
              (t.submodule
                 { options =
                     { pkg = l.mkOption { type = t.either t.package t.str; };

                       aliases =
                         l.mkOption
                           { type = t.attrsOf t.str;
                             default = {};
                           };

                       env =
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
      let cfg = config.environment.packages-extra; in
      { environment =
          { systemPackages =
              l.pipe cfg [ (filter (a: !isString a.pkg)) (map (a: a.pkg)) ];

            variables = foldl' (acc: { env, ... }: acc // env) {} cfg;
          };

        programs.bash =
          { shellAliases = foldl' (acc: a: acc // a.aliases) {} cfg;

            interactiveShellInit =
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
