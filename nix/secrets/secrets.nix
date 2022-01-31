with builtins;
let
  hp-envy =
    { host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjLWvLvgY4VSV3rvihTjjLRtgHQIA50U43ALdl66IzO root@hp-envy";
      mason = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiC9a/2NVbF8Viqvq3kPdzIkQwAJUbK8btC54ovtMJa";
    };
in
{ "netrc.age".publicKeys = attrValues hp-envy; }
