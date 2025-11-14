p:
let inherit (p.lib) getExe; in
p.lib.mapAttrsToList p.writeShellScriptBin
  { bevel-delete =
      ''
      ${getExe p.sqlite} ~/.local/share/bevel/history.sqlite3 "DELETE FROM command WHERE text LIKE '$1'"
      ${getExe p.sqlite} ~/.local/share/bevel/history.sqlite3 "DELETE FROM command WHERE text LIKE 'bevel-delete%'"
      '';

    hc =
      let
        character-references =
          p.fetchurl
            { url = "https://html.spec.whatwg.org/entities.json";
              hash = "sha256-10HYd6x3xBlMStUmtbShmu+N/kEauECkZokc27nzYuY=";
            };
      in
      ''
      ${getExe p.jq} -r '."&'$1';".characters' ${character-references} |
        tr -d '\n' |
        ${getExe p.xclip} -selection clipboard
      '';

    prefetch-nixpkgs =
      ''
      url=https://github.com/NixOS/nixpkgs/archive/$1.tar.gz
      nix-prefetch-url $url --type sha256 --unpack 2> /dev/null | {
        read hash

        echo "\
      (fetchTarball
         { url = \"$url\";
           sha256 = \"$hash\";
         }
      )"
      }
      '';

    unsymlink =
      ''
      set -e
      tmp=$(mktemp)
      cp -r "$1" $tmp
      rm "$1"
      cp -Lr $tmp "$1"
      rm $tmp

      if [ -d "$1" ]; then
        chmod 755 "$1"
      else
        chmod 666 "$1"
      fi
      '';
  }
