{
  config,
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.iso =
    { pkgs, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
        config.flake.modules.nixos.udev
      ];

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
      };

      environment.systemPackages = with pkgs; [
        borgbackup
        bitwarden-desktop
        brave
        git
        disko
        nixos-anywhere
        e2fsprogs # for ext4
      ];

      isoImage.squashfsCompression = "lz4";

      services.openssh.settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };

      users.users.nixos.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0WzxQnNqFO/PMwKwOT72jGTEEVHgOGmPhcmktb+Uz6"
      ];

      virtualisation.vmVariant.virtualisation = {
        cores = 2;
        memorySize = 8192; # 8 GiB
        diskSize = 20480; # 20 GiB
        # enable ssh into VM
        forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
    };

  perSystem =
    { pkgs, self', ... }:
    {
      packages.run-iso =
        let
          isoImage = self.nixosConfigurations.iso.config.system.build.isoImage;
        in
        pkgs.writeShellApplication {
          name = "run-iso";
          runtimeInputs = with pkgs; [
            qemu
            qemu-utils
          ];
          text = ''
            QEMU_DIR="$HOME/.config/qemu"
            VARS_DIR="$QEMU_DIR/ovmf"
            mkdir -p "$VARS_DIR"
            if [ ! -f "$VARS_DIR/OVMF_VARS.fd" ]; then
              cp "${pkgs.OVMF.variables}" "$VARS_DIR/OVMF_VARS.fd"
              chmod 0644 "$VARS_DIR/OVMF_VARS.fd"
            fi
            if [ ! -f "$QEMU_DIR/iso.qcow2" ]; then
              qemu-img create -f qcow2 "$QEMU_DIR/iso.qcow2" 20G  
            fi
            qemu-system-x86_64 \
              -enable-kvm \
              -vga virtio \
              -display gtk,gl=on,grab-on-hover=on,zoom-to-fit=on,show-cursor=on \
              -drive file="$QEMU_DIR/iso.qcow2",format=qcow2,if=virtio \
              -drive if=pflash,format=raw,unit=0,readonly=on,file="${pkgs.OVMF.firmware}" \
              -drive if=pflash,format=raw,unit=1,readonly=off,file="$VARS_DIR/OVMF_VARS.fd" \
              -drive media=cdrom,file="${isoImage}/iso/${isoImage.name}",readonly=on \
              -m 8G \
              -smp 2 \
              -boot menu=on \
              "$@"
          '';
        };
      apps.run-iso = {
        type = "app";
        program = self'.packages.run-iso;
      };
    };
}
