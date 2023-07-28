{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.05";
    };

    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
    };

    nur = {
      url = "github:nix-community/NUR";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-modules = {
      url = "git+https://git.server01.lan/r/nixos-modules.git";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, deploy-rs, home-manager, sops-nix, nur, disko, my-modules, ... } @ inputs:
    let
      inherit (nixpkgs) lib;
      overlays = lib.flatten [
        nur.overlay
        my-modules.overlays
        my-modules.pkgs
      ];
      nixosDeployments = my-modules.utils.deploy.generateNixosDeployments {
        inherit inputs;
        inherit deploy-rs;
        path = ./systems;
        sharedModules = [
          { nixpkgs.overlays = overlays; }
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
        ];
      };
    in
    {
      inherit (nixosDeployments) nixosConfigurations deploy;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      rootPath = ./.;
      nixosModules = my-modules.nixosModules;
      nixosRoles = my-modules.nixosRoles;

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        deploy-rs.lib;

    };
}
