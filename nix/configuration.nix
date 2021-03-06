{ pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/disk/by-id/ata-WDC_WD10EZEX-08M2NA0_WD-WCC3FE0JTJMX";
  };

  environment = {
    systemPackages = with pkgs; [
      brave
      gimp
      git
      graphviz
      imagemagick
      jq
      ncdu
      (neovim.override { withNodeJs = true; })
      nix-du
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

  hardware = {
    keyboard.zsa.enable = true;
    pulseaudio.enable = true;
  };

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
    extraOptions = "experimental-features = nix-command flakes";
    package = pkgs.nixFlakes;
  };

  programs.nm-applet.enable = true;

  services = {
    picom = {
      enable = true;
      vSync = true;
    };

    udev.extraRules = ''
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

        mouse = {
          accelProfile = "flat";
          accelSpeed = "0";
        };
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
        extraGroups = [ "networkmanager" "plugdev" "wheel" ];
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
              lxappearance
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
