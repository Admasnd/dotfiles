{
  description = "Flake for dotfiles including NixOS and home-manager configuration";

  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    golf-vim = {
      url = "github:vuciv/golf";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    one-small-step-for-vimkind = {
      url = "github:jbyuki/one-small-step-for-vimkind";
      flake = false;
    };
    private-dotfiles.url = "git+file:///home/antwane/dev/private-dotfiles";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixframe = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixframe/configuration.nix
            inputs.private-dotfiles.nixosModules.tailscale
            inputs.private-dotfiles.nixosModules.backup
            inputs.private-dotfiles.nixosModules.pam
            inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
            inputs.disko.nixosModules.disko
            ./hosts/nixframe/nixframe-disko.nix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.antwane = ./hosts/nixframe/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
          specialArgs = { inherit inputs; };
        };
        nixjoy = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixjoy/configuration.nix
            inputs.private-dotfiles.nixosModules.tailscale
          ];
        };
        iso = lib.nixosSystem {
          inherit system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            ./hosts/iso/configuration.nix
          ];
        };
      };
      devShells."${system}".pentest =
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        pkgs.mkShell {
          name = "pentest-env";

          packages = with pkgs; [
            nmap
            wireshark
            metasploit
            putty
          ];
        };
      checks.${system} = nixpkgs.lib.genAttrs (builtins.attrNames self.nixosConfigurations) (
        host: self.nixosConfigurations.${host}.config.system.build.toplevel
      );
      packages.${system} = {
        upgrade = pkgs.writeShellApplication {
          name = "nixos-upgrade";

          runtimeInputs = with pkgs; [
            git
            mktemp
          ];
          text = ''
            FLAKE_LOCK=$(mktemp)
            REPO_PATH=/home/antwane/dev/dotfiles

            cleanup() {
              rm -f "$FLAKE_LOCK"
            }
            trap cleanup EXIT INT TERM

            cd "$REPO_PATH"
            nix flake update --output-lock-file "$FLAKE_LOCK"
            if cmp --silent -- "$FLAKE_LOCK" "flake.lock"; then
              exit 0
            fi
            nix flake check --reference-lock-file "$FLAKE_LOCK"
            chown "$(stat -c '%U:%G' flake.lock)" "$FLAKE_LOCK"
            chmod "$(stat -c '%a' flake.lock)" "$FLAKE_LOCK"
            mv "$FLAKE_LOCK" flake.lock
            git add flake.lock
            git commit --author "root <root@localhost>" -m "flake: update"
            nixos-rebuild switch --flake .
          '';
        };
      };
    };
}
