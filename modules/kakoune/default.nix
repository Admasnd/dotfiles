{ inputs, moduleWithSystem, ... }:{
    flake.nixosModules.laptop = moduleWithSystem (
    {config, ...}:
    {...}:{
        environment.systemPackages = [config.packages.myKakoune];
   });
    perSystem = { pkgs, ... }: let
      myConfigDir = pkgs.runCommand "kak-xdg-config" {} ''
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
            env.XDG_CONFIG_HOME = "${myConfigDir}";
        };
    };
}
