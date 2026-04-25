# Repo Info

The github repo is now being used as a mirror as I have moved this repo to the
Radicle network.

On the Radicle network, this repo can be found with
`rad:z3p3ybE6Vm6WedPNrB86msvw6ogBn`.

The repo can also be viewed in your browser at:

    https://app.radicle.xyz/nodes/rosa.radicle.xyz/rad:z3p3ybE6Vm6WedPNrB86msvw6ogBn

# Usage Instructions

In order to update flake:

```bash
nix flake update
```

Deploy NixOS config with parallelism

```bash
sudo nixos-rebuild --flake . switch -j auto
```

NixOS Remote Deployment Example

```bash
nixos-rebuild switch --flake .#nixjoy -j auto --ask-sudo-password --target-host admin@nixjoy --build-host admin@nixjoy
```

Running Pentest Development Shell

```bash
nix develop .#pentest
```

Build iso image

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage

```

Burn iso image to usb

```bash
dd if=result/iso/*.iso of=/dev/sdX status=progress
sync
```

Build and Burn iso image to usb in one step

```bash
sudo bash -c "nix build .#nixosConfigurations.iso.config.system.build.isoImage && dd if=\$(ls result/iso/*.iso) of=/dev/sda status=progress && sync"
```

Build vm

```bash
nixos-rebuild --flake .#<host> build-vm
```

# Remote install

In order to format disk and install NixOS with host configuration, do the following:

1. burn nixos install image to usb
2. boot installer on target machine
3. use `mkpasswd` on target machine to set password for nixos account
4. connect target machine to internet
5. use `ip addr` to discover target machine ip address
6. run nixos-anywhere from another machine to format and install configuration on target machine

These instructions assume that a disko configuration was defined in the host configuration to
facilitate disk formatting. The `--extra-files` options can be used to copy necessary sops
secrets to target machine prior to installation. The filesystem structure of the files you
want to copy over must be replicated in the provided directory. For example, if you want foo.txt
to be copied to /etc/foo.txt on the target machine, you must store foo.txt in ~/Downloads/tmp/etc/foo.txt
and then set `--extra-files ~/Downloads/tmp` option when call nixos-anywhere.

```bash
nix run github:nix-community/nixos-anywhere -- -f <flake>#<host> --target-host nixos@<destination-ip-address> --extra-files <directory>
```

# Tailscale

We want to be able to access nixjoy over the internet safely.
inputs.private-dotfiles.nixosModules.tailscale enables the Tailscale service.
Additionally, we need to perform an initial connection with `tailscale up`.
Furthermore, we need to advertise that tailscale will handle ssh connections
coming from the tailnet using `tailscale set --ssh`. Finally, we must configure
our ACL in the tailscale admin portal to allow receiving ssh connections from
the tailnet.

# Backup

In addition to the settings defined in nixos/nixframe/configuration.nix, you
will need to add the hostkey for the remote borg repo. Perform the following
command to get the host key.

```bash
ssh-keyscan -H <server>
```

You can then set the hostkey declaratively using
`services.openssh.knownHosts.<name>.publicKey`.

Verify repository integrity

```bash
borg check --verify-data <repo>
```

Verify archive content matches local data

```bash
systemd-inhibit --who "borg" --why "backup-test" borg export-tar <repo>::<archive> - | tar -C / -d -f -
```

# FIDO2 Unlock

`systemd-cryptenroll` must be used to manually enroll FIDO2 key into LUKS2
partition.

The pam u2f module is used to login with the FIDO2 key. This can be
declaratively set with NixOS. `pamu2fcfg` is used to get the public key to
enroll the FIDO2 keys.

# Garbage Collection

Do the following to manually garbage collect NixOS generations in the last two
weeks.

```bash
nix-collect-garbage --delete-older-than 14d
```
