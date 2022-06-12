with builtins;
{ lib, nixpkgs, pkgs, ... }:
  let l = lib; p = pkgs; in
  { environment =
      { shellAliases =
          { cal = "cal -m";
            rebuild = "nixos-rebuild --use-remote-sudo";
            repl = ''nix repl --arg pkgs '(builtins.getFlake "${./.}").inputs.nixpkgs.legacyPackages.x86_64-linux' ${./repl.nix}'';
          };

        systemPackages =
          with pkgs;
          [ git ];
      };

    networking =
      { networkmanager.enable = true;

        # The global useDHCP flag is deprecated, therefore explicitly set to false here.
        # Per-interface useDHCP will be mandatory in the future, so this generated config
        # replicates the default behaviour.
        useDHCP = false;
      };

    nix =
      { extraOptions = "experimental-features = nix-command flakes";
        registry.nixpkgs.flake = nixpkgs;
        settings.trusted-users = [ "mason" "root" ];
      };

    programs.bash.interactiveShellInit = "shopt -s globstar";

    services =
      { openssh =
          { enable = true;
            # passwordAuthentication = false;
          };
      };

    # time.timeZone = "America/Toronto";

    users =
      { mutableUsers = false;

        users =
          { mason =
              { createHome = true;
                description = "Mason Mackaman";
                extraGroups = [ "networkmanager" "wheel" ];
                isNormalUser = true;
                password = "";
              };

            root =
              { extraGroups = [ "root" ];
                password = "";
              };
          };
      };
  }
