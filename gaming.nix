{ ssbm }:
{ mmm, ... }:
  with builtins; mmm
  { imports = [ ssbm.nixosModules.default ];

    my-modules.hm =
      { imports = [ ssbm.homeManagerModules.default ];
        slippi-launcher =
          { netplayHash = "sha256-iCBdlcBPSRT8m772sqI+gSfNmVNAug0SfkSwVUE6+fE=";
            isoPath = "";
            launchMeleeOnPlay = false;
          };
      };

    programs.steam.enable = true;

    # ssbm =
    #   { cache.enable = true;

    #     gcc =
    #       { oc-kmod.enable = true;
    #         rules.enable = true;
    #       };
    #   };
  }
