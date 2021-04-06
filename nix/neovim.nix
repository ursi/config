{ neovim, mkOverlayableNeovim, vimPlugins }: with vimPlugins;
  mkOverlayableNeovim
    (neovim.override { withNodeJs = true; })
    { packages.myPackage =
        { start =
            [ gruvbox
              vim-surround
              vim-commentary
              #vim-match

              # CoC
              coc-nvim
              #vim-jsonc

              ale

              # Elm
              vim-elm-syntax

              # JavaScript
              vim-javascript

              # JSX
              vim-jsx-pretty

              # Pug
              vim-pug

              # PureScript
              purescript-vim

              # Dhall
              LanguageClient-neovim
              dhall-vim

              # Nix
              vim-nix
            ];
        };

      customRC = builtins.readFile ../neovim/config/init.vim;
    }
