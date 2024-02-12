{ config, lib, mmm, ... }:
with builtins;
let
  l = lib; t = l.types;
  inherit (l) mkOption;

  battery =
    { name = "battery 1";

      config =
        { format = "%status %percentage %remaining";
          status_chr = "⚡";
          status_bat = "🔋";
          status_full = "☻";
          path = "/sys/class/power_supply/BAT%d/uevent";
          low_threshold = "15";
          integer_battery_capacity = "true";
        };
    };

  cpu =
    { name = "cpu_usage";
      config.format = "🖥️ %usage";
    };

  disk =
    { name = "disk /";
      config.format = "%avail";
    };

  memory =
    { name = "memory";
      config.format = "%available";
    };

  time =
    { name = "time";
      config.format = "%H:%M %a %d";
    };

  volume =
    { name = "volume default";

      config =
        { format = "🔊 %volume";
          format_muted = "🔈 (%volume)";
          align = "center";
        };
    };
in
{ options.my-modules.i3status =
    { status-bar = mkOption
        { type = t.listOf (t.submodule
            { options =
                { name = mkOption { type = t.str; };
                  config = mkOption { type = t.attrsOf t.str; };
                };
            });

          default = [];
        };

      battery = l.mkEnableOption "enable battery status";
    };

  config =
    let cfg = config.my-modules.i3status; in mmm
    { my-modules =
        { hm.programs.i3status =
            { enable = true;
              enableDefault = false;
              general.output_format = "i3bar";
              modules =
               listToAttrs
                 (l.imap
                    (i: v:
                       { inherit (v) name;
                         value =
                           { enable = true;
                             position = i;
                             settings = v.config;
                           };
                       })
                    cfg.status-bar);
            };

          i3status.status-bar =
            [ cpu
              disk
              memory
              volume
            ]
            ++ l.optionals cfg.battery [ battery ]
            ++ [ time ];
        };
    };
}
