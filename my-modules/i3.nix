{ config, mmm, pkgs, ... }:
with builtins;
let
  p = pkgs; l = p.lib; t = l.types;
  inherit (l) mkOption;
in
{ options.my-modules.i3 =
    { backlight-adjust-percent = mkOption
        { type = t.nullOr (t.either t.int t.float);
          default = null;
        };
    };

  config =
    let
      bap = config.my-modules.i3.backlight-adjust-percent;
      bctl = "${p.brightnessctl}/bin/brightnessctl";
    in mmm
    { my-modules.i3.hm.extraConfig =
        l.optionalString (bap != null)
          ''
          bindcode 232 exec --no-startup-id ${bctl} set ${toString bap}%-
          bindcode 233 exec --no-startup-id ${bctl} set ${toString bap}%+
          '';
    };
}
