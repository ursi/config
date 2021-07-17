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
                       aliases = l.mkOption { type = t.attrsOf t.str; };
                     };
                 }
              );

          default = {};
        };

    config =
      let cfg = config.environment.pkgs-with-aliases; in
      { environment.systemPackages = map (pa: pa.pkg) cfg;

        programs.bash.shellAliases =
          foldl'
            (acc: pa:
               acc // pa.aliases
            )
            {}
            cfg;
      };
  }
