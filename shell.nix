{ pkgs ? import <nixpkgs> { } }:
let
  lib = pkgs.lib;
in
{
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      nix-diff
      nix-output-monitor
      home-manager
      git
      helix
      bat
    ];
  };
}
