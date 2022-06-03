with builtins;
let
  all-keys =
    concatMap
      (a: attrValues (import (../systems + "/${a}/info.nix")).ssh-keys)
      (attrNames (readDir ../systems));
in
{ "netrc.age".publicKeys = all-keys; }
