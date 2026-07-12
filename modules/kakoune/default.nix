{ inputs, moduleWithSystem, ... }: {
  flake.nixosModules.laptop = moduleWithSystem (
    { config, ... }:
    { lib, ... }: {
      environment.systemPackages = [ config.packages.myKakoune ];
      environment.sessionVariables = {
          EDITOR = "kak";
      };
    }
  );
  perSystem =
    { lib, pkgs, ... }:
    let
      myConfigDir = pkgs.runCommand "kak-xdg-config" { } ''
        mkdir -p $out/kak/autoload/stdlib
        ln -s ${./kak/kakrc} $out/kak/kakrc
        for f in ${pkgs.kakoune}/share/kak/autoload/*; do
          ln -s "$f" $out/kak/autoload/stdlib/$(basename "$f")
        done
        for f in ${./kak/autoload}/*; do
          ln -s "$f" $out/kak/autoload/$(basename "$f")
        done
      '';
    in
    {
      packages.myKakoune = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.kakoune;
        runtimePkgs = with pkgs; [
          bat
          ripgrep
          tmux
        ];
        env.XDG_CONFIG_HOME = "${myConfigDir}";
        runShell = [
          ''
            exec tmux new-session -- ${lib.getExe pkgs.kakoune} "$@"
          ''
        ];
      };
    };
}
