{ inputs, ... }:
{
  den.aspects.iso.nixos =
    { pkgs, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
      ];

      nixpkgs.config.allowUnfree = true;

      networking.hostName = "iso";

      environment.systemPackages = with pkgs; [
        neovim
        borgbackup
        bitwarden-desktop
        brave
        git
        disko
        nixos-anywhere
      ];

      isoImage.contents = [
        {
          source = /home/antwane/dev/dotfiles;
          target = "/home/nixos/dotfiles";
        }
        {
          source = /home/antwane/dev/private-dotfiles;
          target = "/home/nixos/private-dotfiles";
        }
      ];
    };
}
