with builtins;
{ mmm, pkgs, ... }:
  let
    neovim = "${pkgs.neovim}/bin/nvim";
    graph-all = "ga";
    show-stash = "$(git reflog show --format=%H stash 2> /dev/null)";
  in mmm
  { environment =
      { shellAliases =
          let ga-command = "git ${graph-all} ${show-stash}"; in
          { gd = "git diff -w";
            gg = "git grep";
            ${graph-all} = ga-command;
            ${graph-all + "f"} = "${ga-command} --first-parent";
            gs = "git status";
          };

        systemPackages = [ pkgs.git-filter-repo ];
      };

    my-modules.hm.programs.git =
      { enable = true;
        extraConfig =
          { alias =
              let make-function = str: "!f() { ${str}; }; f"; in
              { cloners = "clone --recurse-submodules";
                co = "checkout";
                cp = "cherry-pick";
                dc = "diff --cached";
                delete-branch =
                  make-function ''git push -d "$1" "$2"; git branch -D "$2"'';
                exp = make-function ''git lfp $1^..$1^2 "''${@:2}"'';
                expand = make-function ''git log $1^..$1^2 "''${@:2}"'';
                ${graph-all} = "log --oneline --abbrev=0 --graph --all";
                graph = "log --oneline --abbrev=0 --graph";
                lfp = "log --oneline --abbrev=0 --first-parent";
                wd = "diff --color-words";
                wdc = "diff --cached --color-words";
              };

            clean.requireForce = false;

            core =
              { editor = neovim;
                pager = "less -FX -x1,5";
              };

            commit.verbose = 2;
            diff.algorithm = "histogram";
            grep.lineNumber = true;

            merge =
              { conflictStyle = "zdiff3";
                ff = false;
              };

            pager.blame = "${neovim} -R";
            pull.ff = "only";

            user =
              { email = "masondeanm@aol.com";
                name = "Mason Mackaman";
              };
          };

        ignores =
          [ "*.swp"
            "result"
          ];
      };

    programs.git =
      { enable = true;
        lfs.enable = true;
      };
  }
