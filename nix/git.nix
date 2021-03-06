{ pkgs, ... }:
  let
    graph-all = "ga";
    show-stash = "$(git reflog show --format=%H stash 2> /dev/null)";
  in
  { programs.bash.shellAliases.${graph-all} = "git ${graph-all} ${show-stash}";

    users.users.mason.git =
      { config =
          { alias =
              { cloners = "clone --recurse-submodules";
                co = "checkout";
                dc = "diff --cached";
                ${graph-all} = "log --oneline --abbrev=0 --graph --all";
                graph = "log --oneline --abbrev=0 --graph";
                wd = "diff --word-diff";
                wdc = "diff --word-diff --cached";
              };

            core =
              { editor = "${pkgs.neovim}/bin/nvim";
                pager = "less -x1,5";
              };

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
