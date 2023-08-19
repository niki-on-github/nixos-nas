{ config, lib, pkgs, inputs, ... }:
let
  user = "nix";
  pool-01 = {
    name = "pool-01";

    # The order of disks is relevant for parity calculations!
    dataDisks = [
      { blkDev = "/dev/disk/by-id/ata-ST2000DM001-1CH164_Z1E2YXW5-part1"; label = "slot-02"; }
    ];

    # The order of disks is relevant for parity calculations!
    parityDisks = [
      { blkDev = "/dev/disk/by-id/ata-WDC_WD20EFRX-68EUZN0_WD-WMC4M1409383-part1"; label = "slot-01"; }
    ];

    volumes = [
      "volume-01"
    ];
  };
  pool-02 = {
    name = "pool-02";

    # The order of disks is relevant for parity calculations!
    dataDisks = [
      { blkDev = "/dev/disk/by-id/ata-ST2000DM001-1CH164_S1E2827F-part1"; label = "slot-03"; }
    ];

    # The order of disks is relevant for parity calculations!
    parityDisks = [
      { blkDev = "/dev/disk/by-id/ata-HGST_HDS724040ALE640_PK2334PBHB727R-part1"; label = "slot-99"; }
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
    (storage-pool-template {
      lib = lib;
      pkgs = pkgs;
      pool = pool-02;
    })
    (samba-share-template {
      lib = lib;
      pool = pool-01;
    })
    (samba-share-template {
      lib = lib;
      pool = pool-02;
    })
  ];

  disko.devices = inputs.personalModules.nixosModules.encrypted-system-disk-template {
    lib = lib;
    disks = [ "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_240GB_193374805600" ];
  };

  sops = {
    defaultSopsFile = ./secrets.sops.yaml;
    gnupg.sshKeyPaths = [ "/boot/keys/sops.key" ];
    age.sshKeyPaths = [ ]; #  must be explicitly unset!
    secrets.user-password.neededForUsers = true;
  };

  users = {
    users = {
      ${user} = {
        isNormalUser = true;
        description = "nix user";
        createHome = true;
        # use `mkpasswd -m sha-512 | tr -d '\n'` to get the password hash for your sops file
        passwordFile = config.sops.secrets.user-password.path;
        home = "/home/${user}";
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
  nix.settings.trusted-users = [ "root" "${user}" ];
}
