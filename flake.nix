{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: 

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        {
        devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixpkgs-fmt
	  git
	];
      };

      containers = {
        jellyfin = import ./modules/containers/jellyfin.nix;
      };

      services = {
        jellyfin = import ./modules/services/jellyfin.nix;
      };
      }
    );

}
