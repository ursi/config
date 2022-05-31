{ imports = [ ./hardware-configuration.nix ];
  agenix.enable = false;

  boot.loader.grub =
      { enable = true;
        version = 2;
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-08M2NA0_WD-WCC3FE0JTJMX";
      };

  networking.interfaces.eno1.useDHCP = true;
  nix.buildCores = 3;
  services.picom.backend = "glx";
  # don't change - man configuration.nix
  system.stateVersion = "20.03";
  users.users.mason.im-home.i3status.status-bar = (import ../../i3status.nix).no-battery;
}

