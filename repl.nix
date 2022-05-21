with builtins;
{ pkgs }:
  let l = p.lib; p = pkgs; in
  builtins
  // { get-flake =
         let
           get-flake = getFlake "github:ursi/get-flake";

           f =
             mapAttrs
               (_: v:
                  if isAttrs v then
                    if v?${currentSystem}
                    then v.${currentSystem}
                    else f v
                  else
                    v
               );
         in
         a: f (get-flake a);

       inherit l p;
     }
