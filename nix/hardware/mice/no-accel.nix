{ speed ? 0 }:
  { services.xserver.libinput =
      { enable = true;

        mouse =
          { accelProfile = "flat";
            accelSpeed = toString speed;
          };
      };
  }
