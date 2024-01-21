with builtins;
{ mkOverlayableNeovim, pkgs }:
  let  p = pkgs; in
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
            let
              extra-plugins = import ./extra-plugins.nix p;
            in
            with p.vimPlugins;
            [ # CoC
              coc-nvim
              # coc-rust-analyzer

              # Dhall
              LanguageClient-neovim
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
              gruvbox
              # extra-plugins.match
              markdown-preview-nvim
              vim-surround
              vim-commentary
              vim-eunuch
            ];
        };
    }
