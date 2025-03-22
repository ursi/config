with builtins;
p:
  let
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
              "mkdir -p $out/after; ln -s ${./ftplugin} \${_}/ftplugin";
        };

    match =
      build "vim-match"
        "https://github.com/ursi/vim-match.git"
        "8e401c1b0ae9baab5090c415f21be0ec1c575c8b";

    uiua =
      build "uiua.vim"
        "https://github.com/sputnick1124/uiua.vim"
        "b6b5651d60b96825f60c9d598a39d1eae1069e45";
  }
