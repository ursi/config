{ pkgs, cursor }: with pkgs; with lib;
  { gtk =
      writeTextDir "/settings.ini"
        ''
        [Settings]
        gtk-cursor-theme-name=${cursor.name}
        '';

    icons =
      let
        index =
          writeText "index.theme"
            ''
            [icon theme]
            Inherits=${cursor.name}
            '';
      in
        stdenv.mkDerivation
          { name = "icons";
            dontUnpack = true;

            installPhase =
              ''
              mkdir $out
              cd $out
              ln -s ${cursor} ${cursor.name}
              mkdir default
              ln -s ${index} default/index.theme
              '';
          };
  }
