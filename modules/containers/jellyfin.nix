{ pkgs ? import <nixpkgs> {} , ...}:

let
  dockerTools = pkgs.dockerTools;
in
  dockerTools.buildImage {
    name = "jellyfin";
    tag = "latest";

    runAsRoot = ''
      #!${pkgs.stdenv.shell}
      ${dockerTools.shadowSetup}
      groupadd -r jellyfin
      useradd -r -g jellyfin -d /config -M jellyfin
      mkdir -p /config /cache /media
      chown -R jellyfin:jellyfin /config /cache /media
    '';

    contents = pkgs.buildEnv {
      name = "jellyfin-env";
      paths = [
        pkgs.jellyfin
	pkgs.jellyfin-web
	pkgs.jellyfin-ffmpeg
      ];
    };

    config = {
      Cmd = [
        "${pkgs.jellyfin}/bin/jellyfin"
      ];
      ExposedPorts = {
        "8096/tcp" = {};
        "8920/tcp" = {};
      };
      Volumes = {
        "/config" = {};
        "/cache" = {};
        "/media" = {};
      };
      WorkingDir = "/config";
      User = "jellyfin";
    };

  }
