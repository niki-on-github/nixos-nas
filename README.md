# My NixOS NAS

My NixOS based NAS configuration hosted on my personal Git Server. Feel free to look around. Be aware that not all configuration files are available in my public repository.

## Deployment

See [r/nixos-modules](https://git.server01.lan/r/nixos-modules). You may need to check out the commit from `./flake.lock`.

## Add Disk

Run `disk-format`. Then add the new dis to this flake config.

## Samba

### Setup

```bash
sudo smbpasswd -a nix
```

## Disk Restore Procedure

1. Read the [SnapRaid manual](http://www.snapraid.it/manual)
2. Format new drive with `disk-format`
3. Replace drive in flake config pool.
4. Run `snapraid fix -d dX -l /tmp/snapraid.log` where `dX` is the disk e.g. `d1` from `snapraid.conf`
5. Run`snapraid check -d dX -a`
6. Resync with new drive: `snapraid sync`
