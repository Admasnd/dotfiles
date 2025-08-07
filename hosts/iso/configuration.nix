{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "iso";

  environment.systemPackages = with pkgs; [
    neovim
    borgbackup
    bitwarden
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
}
