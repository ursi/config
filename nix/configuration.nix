{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/disk/by-id/ata-WDC_WD10EZEX-08M2NA0_WD-WCC3FE0JTJMX";
  };

  environment = {
    systemPackages = with pkgs; [
      brave
      git
      (neovim.override { withNodeJs = true; })
      ntfs3g
      parted
      pavucontrol
      spectacle
      trash-cli
      unzip
      xclip
      xfce.xfce4-terminal
      w3m
    ];

    variables = { EDITOR = "nvim"; };
  };

  fonts.fonts = with pkgs; [ (nerdfonts.override {fonts = [ "Cousine" ]; }) ];
  hardware.pulseaudio.enable = true;

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
    # wireless.enable = true; # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";

    binaryCaches = [
      "https://nixcache.reflex-frp.org"
      "https://cache.nixos.org"
      "https://shpadoinkle.cachix.org"
    ];

    binaryCachePublicKeys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "shpadoinkle.cachix.org-1:aRltE7Yto3ArhZyVjsyqWh1hmcCf27pYSmO1dPaadZ8="
    ];
  };

  programs.nm-applet.enable = true;

  services = {
    picom = {
      backend = "glx";
      enable = true;
      vSync = true;
    };

    udev.extraRules = ''
      # Teensy rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      #GameCube Controller Adapter
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", TAG+="uaccess"

      #Mayflash DolphinBar
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0306", TAG+="uaccess"
    '';

    xserver = {
      enable = true;

      # Disable mouse acceleration
      libinput = {
        enable = true;
        accelProfile = "flat";
        accelSpeed = "0";
      };

      windowManager.i3.enable = true;
    };
  };

  sound.enable = true;

  system = {
    autoUpgrade.enable = true;

    # don't change - man configuration.nix
    stateVersion = "20.03";
  };

  users = {
    mutableUsers = false;

    users = {
      mason = {
        createHome = true;
        description = "Mason Mackaman";
        extraGroups = [ "networkmanager" "wheel" ];
        isNormalUser = true;

        packages = with pkgs;
          let
            communication = [
              discord
              mattermost-desktop
              signal-desktop
              zulip
            ];

            editor =
              let
                elm = with elmPackages; [
                  elm-language-server
                  elm-format
                ];

                node = with nodePackages; [
                  purty
                  purescript-language-server
                ];
              in
                elm ++ node;
          in
            [
              gnome3.nautilus # for seeing images
              go-sct
              nodePackages.node2nix
              wally-cli
            ]
              ++ communication
              ++ editor
              ++ flakePackages;

        password = "";
      };

      root = {
        extraGroups = [ "root" ];
        password = "";
      };
    };
  };
}
