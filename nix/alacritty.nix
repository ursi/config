with builtins;
{ config, lib, pkgs, ... }:
  let
    l = lib; p = pkgs; t = l.types;
    yaml = p.formats.yaml {};
  in
  { options.programs.alacritty =
      { enable = l.mkEnableOption "Enable alacritty";

        config =
          l.mkOption
            { type = yaml.type;
              default = {};
            };
      };

    config =
      { environment.systemPackages =
          let
            cfg = config.programs.alacritty;
            config-file = yaml.generate "alacritty.yaml" cfg.config;
          in
          l.mkIf cfg.enable
            [ (p.writeScriptBin "alacritty"
                 ''
                 if [[ "$@" = *--config-file* ]]; then
                   ${p.alacritty}/bin/alacritty "$@";
                 else
                   ${p.alacritty}/bin/alacritty \
                     --config-file ${config-file} "$@";
                 fi
                 ''
              )
            ];

        programs.alacritty.config =
          { colors =
              { primary =
                  { background = "#000000";
                    foreground = "#ffffff";
                  };

                normal =
                  { black = "#000000";
                    red = "#ff3333";
                    green = "#00ff00";
                    yellow = "#ffff00";
                    blue = "#3388ff";
                    magenta = "#ff00ff";
                    cyan = "#00ffff";
                    white = "#ffffff";
                  };
              };

            font.size = l.mkDefault 12;

            key_bindings =
              [ { key = "PageUp"; action = "ScrollPageUp"; }
                { key = "PageDown"; action = "ScrollPageDown"; }
                { key = "Home"; mods = "Control"; action = "ScrollToTop"; }
                { key = "End"; mods = "Control"; action = "ScrollToBottom"; }
                { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
                { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
                { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
                { key = "N"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
                { key = "C"; mods = "Alt"; action = "Copy"; }
              ];

            mouse_bindings = [ { mouse = "Right"; action = "Copy"; } ];
          };
      };
  }
