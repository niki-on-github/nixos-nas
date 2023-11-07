# My NixOS NAS

My NixOS based NAS configuration hosted on my personal Git Server. Feel free to look around. Be aware that not all configuration files are available in my public repository.

## Deployment

See [r/nixos-modules](https://git.server01.lan/r/nixos-modules). You may need to check out the commit from `./flake.lock`.

## LUKS

### Remove Slot

```bash
sudo cryptsetup luksDump /dev/$LUKS_PARTITION
sudo cryptsetup luksKillSlot /dev/$LUKS_PARTITION $SLOT_NUMBER
```

### Add Keyfile

```bash
sudo cryptsetup luksAddKey  /dev/$LUKS_PARTITION /boot/keys/disk.key
```

## Add Disk

Run `disk-format`. Then add the new disk to this flake config.

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

NOTE: For the `snapraid` commands use the provides alias e.g. `snapraid-pool-01` that use the `btrfs-snapraid` script with config for `pool-01`.

## Harware

### Supermicro X11SSH-F

#### UEFI Boot from NVME SSD

1. In the BIOS, go to the `Advanced` tab and select `PCIe/PCI/PnP Configuration`. Change the `NVMe Firmware Source` to `AMI Native Support`.
2. In the BIOS, go to the `Boot` tab and change `Boot Mode Select` to `UEFI`.
3. In the BIOS, go to the `Boot` tab and assign `[UEFI Hard Disk]` to `UEFI Boot Order #1`.
4. Boot your Install medium with `F11` (Boot Menu) and install the system.

## Disks

| Parity  | Data    | Data    | Data    |
| ------- | ------- | ------- | ------- |
| Slot 21 | Slot 22 | Slot 23 | Slot 24 |
| Slot 17 | Slot 18 | Slot 19 | Slot 20 |
| Slot 13 | Slot 14 | Slot 15 | Slot 16 |
| Slot 09 | Slot 10 | Slot 11 | Slot 12 |
| Slot 05 | Slot 06 | Slot 07 | Slot 08 |
| Slot 01 | Slot 02 | Slot 03 | Slot 04 |

