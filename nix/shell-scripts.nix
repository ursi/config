pkgs:
  let inherit (pkgs) writeShellScriptBin; in
  [ (writeShellScriptBin
       "prefetch-nixpkgs"
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
  ]
