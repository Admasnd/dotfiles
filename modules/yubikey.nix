{
  den.aspects.yubikey = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          yubioath-flutter
          yubikey-manager
        ];
      };
    nixos =
      { pkgs, lib, ... }:
      {
        services.yubikey-agent.enable = true;

        # enable use of Smart card mode (CCID) of Yubikey
        services.pcscd.enable = true;
        services.udev.packages = [ pkgs.yubikey-personalization ];
        security.pam.u2f = {
          enable = true;
          settings = {
            pinverification = 1;
            userpresence = 1;
            authfile = lib.mkDefault null;
            interactive = true;
          };
        };

        security.pam.services = {
          login.u2fAuth = true;
          gdm.u2fAuth = true;
          sudo.u2fAuth = true;
          gdm-password.u2fAuth = true;
        };

      };
  };
}
