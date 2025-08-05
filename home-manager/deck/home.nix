{pkgs, ...}: {
  programs.home-manager.enable = true;
  home.username = "deck";
  home.homeDirectory = "/home/deck";
  home.packages = with pkgs; [
    bitwarden
    tailscale
    moonlight-qt
  ];
}
