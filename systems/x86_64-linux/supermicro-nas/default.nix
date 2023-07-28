{ config, lib, pkgs, inputs, ... }:
let
  pool-01 = {
    name = "pool-01";

    # The order of disks is relevant for parity calculations!
    dataDisks = [
      { blkDev = "/dev/disk/by-id/ata-ST2000DM001-1CH164_Z1E2YXW5-part1"; label = "slot-02"; }
      { blkDev = "/dev/disk/by-id/ata-ST2000DM001-1CH164_S1E2827F-part1"; label = "slot-03"; }
    ];

    # The order of disks is relevant for parity calculations!
    parityDisks = [
      { blkDev = "/dev/disk/by-id/ata-WDC_WD20EFRX-68EUZN0_WD-WMC4M1409383-part1"; label = "slot-01"; }
    ];

    volumes = [
      "volume-01"
    ];
  };
in
{
  imports = with inputs.self.nixosModules; [
    inputs.self.nixosRoles.nas
    boot-encrypted
    (storage-pool-template {
      lib = lib;
      pkgs = pkgs;
      pool = pool-01;
    })
    (samba-share-template {
      lib = lib;
      pool = pool-01;
    })
  ];

  disko.devices = inputs.my-modules.nixosModules.encrypted-system-disk-template {
    lib = lib;
    disks = [ "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_240GB_193374805600" ];
  };

  users = {
    users = {
      nixos = {
        isNormalUser = true;
        description = "nix user";
        createHome = true;
        initialPassword = "nixos";
        home = "/home/nixos";
        extraGroups = [
          "audit"
          "sshusers"
          "storage"
          "wheel"
        ];
      };
    };
  };

  # required for deploy-rs
  nix.settings.trusted-users = [ "root" "nixos" ];
}
