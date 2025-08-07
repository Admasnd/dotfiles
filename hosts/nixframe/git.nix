{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Antwane Mason";
    userEmail = "git@aimai.simplelogin.com";
    aliases = let
      fzf = x: ''        !f() { if [ $# -gt 0 ]; then git ${x} "$@"; else git branch --sort=-committerdate | 
                         fzf | xargs git ${x}; fi; }; f'';
    in {
      lol = "log --oneline --decorate";
      graph = "log --oneline --decorate --graph";
      rel = "reflog --date=iso";
      ref = "reflog --date=iso --pretty";
      di = "diff --word-diff";
      dc = "diff --word-diff --cached";
      bla = "blame -C -C -C"; # does a better job in determining source of change at the expense of speed
      ca = "commit --amend --no-edit";
      ci = "commit --verbose";
      fp = "push --force-with-lease";
      fpstack = ''        !git log --decorate=short --pretty='format:%D' origin/master.. |
                          sed 's/, /\\n/g; s/HEAD -> //' |
                          grep -Ev '/|^$' | xargs git push --force-with-lease origin'';
      prb = "pull --rebase";
      rc = "rebase --continue";
      rb = ''        !f() { if [ $# -eq 0 ]; then set -- origin/master; git fetch origin master; fi && 
                     git rebase "$@"; }; f'';
      ri = ''        !f() { if [ $# -eq 0 ]; then set -- origin/main; fi; 
                     git rebase --interactive --keep-base "$@"; }; f'';
      st = "status --short";
      sw = fzf "switch";
      me = fzf "merge";
      bd = fzf "branch -d";
    };
    extraConfig = {
      rerere.enable = true; # record resolved conflicts to reuse
      merge.conflictstyle = "diff3"; # give context of original in addition to conflicting changes
      core.eol.text = "auto"; # auto detect end-of-line
      pull.ff = "only"; # only do fast forward merges on pull
      rebase.updateRefs = true; # enables rebasing whole branch stack with one command
      grep = {
        lineNumber = true;
        patternType = "perl"; # use perl style regex
      };
    };
  };
}
