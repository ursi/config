pkgs:
  let inherit (pkgs) writeShellScriptBin; in
  [ (writeShellScriptBin "prefetch-nixpkgs"
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
       ''
    )

    (writeShellScriptBin "unsymlink"
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
       ''
    )
  ]
