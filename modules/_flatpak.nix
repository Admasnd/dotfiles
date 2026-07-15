{ inputs, ... }: {
  flake.nixosModules.laptop = { pkgs, ... }: {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

    environment.systemPackages = [ pkgs.xkeyboard-config ];

    services.flatpak = {
      enable = true;
      overrides =
        let
          xkbPath = "/run/current-system/sw/share/X11/xkb";
        in
        {
          "com.orcaslicer.OrcaSlicer" = {
            Environment = {
              XKB_CONFIG_ROOT = xkbPath;
            };
            Context = {
                filesystems = [
                  "${xkbPath}:ro"
                ];
            };
          };
        };
      packages = [ "com.orcaslicer.OrcaSlicer" ];
      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Default value
      };
    };
  };
}
