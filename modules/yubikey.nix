{
  flake.nixosModules.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib)
        mkEnableOption
        mkIf
        mkMerge
        mkOption
        ;
      inherit (lib.types) str;
      cfg = config.admasnd.dotfiles.yubikey;
    in
    {
      options.admasnd.dotfiles.yubikey = {
        enable = mkEnableOption "yubikey";
        pamSecretPath = mkOption {
          type = str;
          description = ''
            path in YAML secrets file where PAM authfile is stored.
            This authfile associates a yubikey public key to a user account.

            Sets `security.pam.u2f.settings.authfile`.
          '';
          example = "path/to/authfile";
        };
      };

      config = mkMerge [
        {
          environment.systemPackages = with pkgs; [
            yubioath-flutter
            yubikey-manager
          ];
        }
        (mkIf (config.admasnd.dotfiles.sops.enable && cfg.enable) {
          sops.secrets.${cfg.pamSecretPath}.neededForUsers = true;

          security.pam.u2f.enable = true;
          security.pam.u2f.settings = {
            # set the following two values so that pam authfile is portable between devices
            origin = "pam://yubikey";
            appid = "pam://yubikey";
            cue = true;
            authfile = config.sops.secrets.${cfg.pamSecretPath}.path;
            pinverification = 1;
            userpresence = 1;
            interactive = true;
          };
          services.yubikey-agent.enable = true;

          # enable use of Smart card mode (CCID) of Yubikey
          services.pcscd.enable = true;
          services.udev.packages = [ pkgs.yubikey-personalization ];

          security.pam.services = {
            login.u2fAuth = true;
            gdm.u2fAuth = true;
            sudo.u2fAuth = true;
            gdm-password.u2fAuth = true;
          };
        })
      ];
    };
}
