with builtins;
{ pkgs, ... }:
  let
    neovim = "${pkgs.neovim}/bin/nvim";
    graph-all = "ga";
    show-stash = "$(git reflog show --format=%H stash 2> /dev/null)";
  in
  { environment.shellAliases =
      let ga-command = "git ${graph-all} ${show-stash}"; in
      { gd = "git diff -w";
        ${graph-all} = ga-command;
        ${graph-all + "f"} = "${ga-command} --first-parent";
        gs = "git status";
      };

    users.users.mason.git =
      { config =
          { alias =
              let
                make-function = str:
                  ''"!f() { ${replaceStrings [ "\"" ] [ ''\"'' ] str}; }; f"'';
              in
              { cloners = "clone --recurse-submodules";
                co = "checkout";
                dc = "diff --cached";
                exp = make-function ''git lfp $1^..$1^2 "''${@:2}"'';
                expand = make-function ''git log $1^..$1^2 "''${@:2}"'';
                ${graph-all} = "log --oneline --abbrev=0 --graph --all";
                graph = "log --oneline --abbrev=0 --graph";
                lfp = "log --oneline --abbrev=0 --first-parent";
                wd = "diff --word-diff";
                wdc = "diff --word-diff --cached";
              };

            core =
              { editor = neovim;
                pager = "less -FX -x1,5";
              };

            diff.algorithm = "histogram";
            merge.ff = false;
            pager.blame = "${neovim} -R";
            pull.ff = "only";

            user =
              { email = "masondeanm@aol.com";
                name = "Mason Mackaman";
              };

            "filter \"lfs\"" =
              { clean = "git-lfs clean -- %f";
                smudge = "git-lfs smudge -- %f";
                process = "git-lfs filter-process";
                required = "true";
              };
          };

        ignore =
          ''
          *.swp
          *.vim
          result
          '';
      };
  }
