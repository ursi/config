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
       if ! [ -a "_$1" ]; then
         cp --no-preserve=mode "$1" "_$1"
         mv "_$1" "$1"
       else
         echo "'_$1' exists"
       fi;
       ''
    )
  ]
