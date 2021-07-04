let
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
{ battery =
    [ disk
      memory
      volume
      battery
      time
    ];

  no-battery =
    [ disk
      memory
      volume
      time
    ];
}
