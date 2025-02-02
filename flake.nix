{
  description = "Lex machina";

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
    }:
      {

    nixosModules.jellyfin = import ./modules/services/jellyfin.nix;
    };

}
