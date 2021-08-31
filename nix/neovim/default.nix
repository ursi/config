with builtins;
{ mkOverlayableNeovim, pkgs }:
# { neovim, mkOverlayableNeovim, vimPlugins, vimUtils }:
  let l = p.lib; p = pkgs; in
  mkOverlayableNeovim
    (p.neovim.override { withNodeJs = true; })
    { customRC =
        let
          coc-settings =
            p.runCommand "coc-settings" {}
            "mkdir $out; ln -s ${./coc-settings.json} $out/coc-settings.json";
        in
        readFile ./init.vim
        + ''
          let g:coc_config_home = '${coc-settings}'"

          " noremap <Leader>v :tabedit ${toString ./init.vim}<CR>

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
              extra-plugins.match
              markdown-preview-nvim
              vim-surround
              vim-commentary
            ];
        };

      # for some reason when this is used here, it fixes an issue with trailing whitespace highlighting
      plug.plugins = [ p.vimPlugins.gruvbox ];
    }
