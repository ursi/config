{ ssbm }:
{ lib, ... }:
  let l = lib; in
  { options.gaming.enable = l.mkEnableOption "Set the system up for gaming";

    config =
      { environment.systemPackages = [ ssbm.slippi-netplay ];
        programs.steam.enable = true;
      };
  }
