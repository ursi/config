{ imports = [ ./hardware-configuration.nix ];
  networking.hostName = "desktop";
  nix.buildCores = 3;
  services.picom.backend = "glx";
}

