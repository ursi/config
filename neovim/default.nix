with builtins;
{ mkOverlayableNeovim, pkgs }:
  let
    p = pkgs;

    remove-indent = plugin:
      p.runCommand plugin.name {}
        ''
        mkdir $out; cd $_
        cp -r ${plugin}/. .
        chmod -R +w .
        rm indent -rf
        '';
  in
  mkOverlayableNeovim
    (p.neovim.override { withNodeJs = true; })
    { customRC =
        readFile ./init.vim
        + ''
          set shell=${p.bashInteractive}/bin/bash

          let g:coc_config_home = '${./.}'

          function! Init(type)
              let lnum = line(".")
              let lines =readfile(findfile(a:type . ".init", '${./init}'))
              let first_line = lines[0]
              let rest = lines[1:]
              call setline(lnum, first_line)
              call append(lnum, rest)
          endfunction
          '';

      packages.myPlugins =
        { start =
            let extra-plugins = import ./extra-plugins.nix p; in
            map remove-indent
              (with p.vimPlugins;
               [ # CoC
                 coc-nvim
                 # coc-rust-analyzer

                 # Dhall
                 # LanguageClient-neovim
                 dhall-vim

                 # Elm
                 vim-elm-syntax

                 # JavaScript
                 vim-javascript

                 # Pug
                 vim-pug

                 # PureScript
                 purescript-vim

                 # Nix
                 vim-nix

                 # Misc
                 extra-plugins.ftplugin
                 extra-plugins.uiua
                 gruvbox-community
                 # extra-plugins.match
                 markdown-preview-nvim
                 vim-surround
                 vim-commentary
                 vim-eunuch
               ]
              );
        };
    }
