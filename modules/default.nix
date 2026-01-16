{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    ./auto-upgrade.nix
    ./backup.nix
    ./devenv.nix
    ./git.nix
    ./hosts
    ./jujutsu.nix
    ./keyboards
    ./neovim
    ./papis
    ./pentest.nix
    ./power
    ./sops.nix
    ./tailscale.nix
    ./vm.nix
    ./yubikey.nix
    ./gaming.nix
  ];
  systems = [ "x86_64-linux" ];
}
