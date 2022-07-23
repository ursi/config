{ ssbm }:
  { environment.systemPackages = [ ssbm.slippi-netplay ];
    programs.steam.enable = true;

    ssbm =
      { cache.enable = true;

        gcc =
          { oc-kmod.enable = true;
            rules.enable = true;
          };
      };

  }
