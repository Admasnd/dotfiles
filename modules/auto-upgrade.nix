{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        upgrade = pkgs.writeShellApplication {
          name = "nixos-upgrade";

          runtimeInputs = with pkgs; [
            git
            mktemp
          ];
          text = ''
            FLAKE_LOCK=$(mktemp)
            REPO_PATH=/home/antwane/dev/dotfiles

            cleanup() {
              rm -f "$FLAKE_LOCK"
            }
            trap cleanup EXIT INT TERM

            cd "$REPO_PATH"
            nix flake update --output-lock-file "$FLAKE_LOCK"
            if cmp --silent -- "$FLAKE_LOCK" "flake.lock"; then
              exit 0
            fi
            nix flake check --reference-lock-file "$FLAKE_LOCK"
            chown "$(stat -c '%U:%G' flake.lock)" "$FLAKE_LOCK"
            chmod "$(stat -c '%a' flake.lock)" "$FLAKE_LOCK"
            mv "$FLAKE_LOCK" flake.lock
            git add flake.lock
            git commit --author "root <root@localhost>" -m "flake: update"
            nixos-rebuild switch --flake .
          '';
        };
      };
    };
}
