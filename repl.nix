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

       inherit l p pkgs;
       inherit (p) lib;

       search = text: attrset:
         let
           change-case = f:
             let chars = l.stringToCharacters text; in
             l.concatStrings ([ (f (head chars)) ] ++ tail chars);
         in
         filter
           (a:
              l.hasInfix (change-case l.toLower) a
              || l.hasInfix (change-case l.toUpper) a
           )
           (attrNames attrset);

       system = "x86_64-linux";
     }
