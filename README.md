# Usage Instructions

In order to update flake:

```bash
nix flake update
```

Deploy NixOS config:

```bash
sudo nixos-rebuild --flake . switch
```

Deploy home-manger config:

```bash
home-manager --flake . switch
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
