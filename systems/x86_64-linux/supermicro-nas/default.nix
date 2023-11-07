{ config, lib, pkgs, inputs, ... }:
let
  user = "nix";
  pool-01 = {
    name = "pool-01";

    # The order of disks is relevant for parity calculations!
    dataDisks = [
      { blkDev = "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_4330A0M9FVGG-part1"; label = "slot-02"; }
      { blkDev = "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_33H0A0NLFVGG-part1"; label = "slot-03"; }
      { blkDev = "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_4340A07FFVGG-part1"; label = "slot-04"; }
    ];

    # The order of disks is relevant for parity calculations!
    parityDisks = [
      { blkDev = "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_33H0A0NTFVGG-part1"; label = "slot-01"; }
      { blkDev = "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_4340A00PFVGG-part1"; label = "slot-05"; }
    ];

    volumes = [
      "volume-01"
    ];
  };
in
{
  imports = with inputs.self.nixosModules; [
    inputs.self.nixosRoles.nas
  ];

  templates = {
    system = {
      bootEncrypted = {
        enable = true;
        disk = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S6P7NX0W319108R";
      };
      storagePools = {
        enable = true;
        pools = [pool-01];
      };
    };
    services = {
      ftp = {
        enable = true;
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets.sops.yaml;
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
