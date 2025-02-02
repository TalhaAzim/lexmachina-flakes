{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
      let
        pkgs = import nixpkgs {};
      in
      {

    nixosModules.jellyfin = import ./modules/services/jellyfin.nix;
    };

}
