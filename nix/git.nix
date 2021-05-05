editor:
  { config =
      { alias =
          { cloners = "clone --recurse-submodules";
            co = "checkout";
            dc = "diff --cached";
            ga = "log --oneline --abbrev=0 --graph --all";
            graph = "log --oneline --abbrev=0 --graph";
            wd = "diff --word-diff";
            wdc = "diff --word-diff --cached";
          };

        core =
          { inherit editor;
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
  }
