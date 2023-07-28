# My NixOS NAS

My NixOS based NAS configuration hosted on my personal Git Server. Feel free to look around. Be aware that not all configuration files are available in my public repository.

## Automated Setup

### Initial Deployment

```bash
nix run github:numtide/nixos-anywhere -- --flake ".#supermicro-nas" nixos@10.0.1.200
```

### Update

#### Local

```bash
sudo nixos-rebuild switch --flake ".#supermicro-nas" --upgrade
```

#### Remote

```bash
nix run github:serokell/deploy-rs ".#supermicro-nas" -- --hostname 10.0.1.200
```

## Cheat Sheet

### Clone Repo

```bash
nix-env -iA nixos.pkgs.git
git -c http.sslVerify=false clone https://git.server01.lan/r/nixos-nas.git
```

### Manual Setup

```bash
nix-env -iA nixos.pkgs.git
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko -- --mode zap_create_mount ./system-disk.nix --arg device "/dev/disk/by-id/ata-SanDisk_SDSSDH3_512G_191805802811" --argstr label slot-01 --root-mountpoint /
sudo nixos-install --root /mnt --flake '.#supermicro-nas'
```
