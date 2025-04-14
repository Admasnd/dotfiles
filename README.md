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
