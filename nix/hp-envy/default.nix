{ imports = [ ./hardware-configuration.nix ];

  boot.loader =
    { systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

  networking =
    { hostName = "hp-envy";
      interfaces.enp1s0.useDHCP = true;
    };

  nix.buildCores = 7;
}

