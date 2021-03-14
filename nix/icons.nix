{ pkgs, cursor }: with pkgs;
  { gtk =
      writeTextDir "/settings.ini"
        ''
        [Settings]
        gtk-cursor-theme-name=${cursor.name}
        '';

    icons =
      let
        default =
          writeTextDir "/index.theme"
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
              ln -s ${default} default
              '';
          };
  }
