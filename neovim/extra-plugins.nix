with builtins;
p:
  let
    l = p.lib;
    inherit (p.vimUtils) buildVimPlugin;

    build = name: url: rev:
      buildVimPlugin
        { inherit name;
          src = fetchGit { inherit url rev; };
        };
  in
  { ftplugin =
      buildVimPlugin
        { name = "ftplugin";

          src =
            p.runCommand "ftplugin-src" {}
              "mkdir $out; ln -s ${./ftplugin} $out/ftplugin";
        };

    match =
      build "vim-match"
        "https://github.com/ursi/vim-match.git"
        "8e401c1b0ae9baab5090c415f21be0ec1c575c8b";
  }
