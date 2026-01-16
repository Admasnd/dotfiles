{
  flake.modules.homeManager.jujutsu =
    { pkgs, ... }:
    let
      jjPush = pkgs.writeShellApplication {
        name = "jujutsu-push";
        runtimeInputs = with pkgs; [ jujutsu ];
        text = ''
          SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock jj git push
          jj git push --remote rad
        '';
      };
    in
    {
      # tool for verifying commits have conventional commit format,
      # bumping semantic versioning, and generating changelog
      home.packages = with pkgs; [ cocogitto ];
      programs.jujutsu = {
        enable = true;
        settings = {
          aliases = {
            bm = [
              "bookmark"
              "move"
              "master"
            ];
            gp = [
              "util"
              "exec"
              "${jjPush}/bin/jujutsu-push"
            ];
          };
          ui = {
            default-command = "log";
            editor = "nvim";
            diff-editor = "vimdirdiff";
            merge-editor = "vimdiff";
            # TODO add vimdirdiff tool
          };
          user = {
            # TODO generalize over name and email
            # using home manager option
            name = "Antwane Mason";
            email = "git@aimai.simplelogin.com";
          };
          merge-tools.vimdiff = {
            diff-invocation-mode = "file-by-file";
            merge-tool-edits-conflict-markers = true;
          };
          templates.draft_commit_description = ''
            builtin_draft_commit_description
            ++
            "JJ: Commit Message Template
            JJ: 
            JJ: Format: <type>(<scope>): <subject>
            JJ: 
            JJ: Types: feat, fix, style, build, refactor, ci, test, perf, chore, revert, docs
            JJ: Scope: component/module affected (optional)
            JJ: Subject: brief description (50 chars max)
            JJ: 
            JJ: Example: feat(auth): add user login validation
            JJ: 
            JJ: Detailed description (wrap at 72 characters):
            JJ: 

            JJ: Breaking changes (if any):
            JJ: 
            JJ: Issues closed: #
            JJ: Related PRs: #\n" 
            ++
            indent("JJ: ", diff.git())
          '';
        };
      };
      programs.jjui.enable = true;
      # Added jujutsu dynamic completion
      programs.bash.bashrcExtra = ''
        . <(COMPLETE=bash jj)
      '';
    };
}
