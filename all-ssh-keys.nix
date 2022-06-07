with builtins;
concatMap
  (a: attrValues ((import (./systems + "/${a}/info.nix")).ssh-keys or {}))
  (attrNames (readDir ./systems))
