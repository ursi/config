{ ssbm }:
  { environment.systemPackages = [ ssbm.slippi-netplay ];
    programs.steam.enable = true;
  }
