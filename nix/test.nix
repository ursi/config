{ config, lib, pkgs, ... }:
  let
    b = builtins; l = lib; p = pkgs; t = l.types;
    ini = p.formats.ini {};
    json = p.formats.json {};

    annotated = import ./annotated.nix p;
    null-or = import ./null-or.nix p;
  in
  { options =
      { test-option =
          l.mkOption
            { type = annotated;
            };

        test-option-2 =
          l.mkOption
            { type = t.anything;
              default = null;
            };
      };

    config =
      { test-option-2 = config.test-option.value;
      };
  }
