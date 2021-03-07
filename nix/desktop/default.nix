{ imports = [ ./hardware-configuration.nix ];

  boot.loader.grub =
      { enable = true;
        version = 2;
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-08M2NA0_WD-WCC3FE0JTJMX";
      };

  networking =
    { hostName = "desktop";
      interfaces.eno1.useDHCP = true;
    };

  nix.buildCores = 3;
  services.picom.backend = "glx";
}

