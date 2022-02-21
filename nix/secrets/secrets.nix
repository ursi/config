with builtins;
let
  all-keys =
    concatMap
      (a: attrValues (import (../systems + "/${a}/ssh-keys.nix")))
      (attrNames (readDir ../systems));
in
{ "netrc.age".publicKeys = all-keys; }
