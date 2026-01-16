{ inputs, lib, ... }:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types) str path nullOr;
  pathNotInStore = lib.mkOptionType {
    name = "pathNotInStore";
    description = "path not in the Nix store";
    descriptionClass = "noun";
    check = x: !lib.path.hasStorePathPrefix (/. + x);
    merge = lib.mergeEqualOption;
  };
in
{
  flake.modules.nixos.sops =
    { config, ... }:
    let
      cfg = config.admasnd.dotfiles.sops;
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      options.admasnd.dotfiles.sops = {
        enable = mkEnableOption "sops";
        defaultSopsFile = mkOption {
          type = path;
          description = ''
            Sets sops file that contains encrypted secrets.

            This option sets `sops.defaultSopsFile` that comes from
            `github:Mic92/sops-nix` flake.
          '';
        };
        keyFile = mkOption {
          type = nullOr pathNotInStore;
          default = null;
          description = ''
            Sets the location of the encryption key to decrypt items 
            in your sops secret file.

            This option sets `sops.age.keyFile` that comes from
            `github:Mic92/sops-nix` flake.
          '';

        };
      };
      config = mkIf cfg.enable {
        sops.defaultSopsFile = mkDefault cfg.defaultSopsFile;
        sops.age.keyFile = mkDefault cfg.keyFile;
      };
    };
}
