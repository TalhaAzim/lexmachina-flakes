# modules/containers/jellyfin.nix
{ config, pkgs, lib, ... }:
let
  dockerTools = pkgs.dockerTools;
  imageName = "jellyfin-custom";
  imageTag = "latest";
  jellyfinImage = dockerTools.buildImage {
    name = imageName;
    tag = imageTag;

    runAsRoot = ''
      #!${pkgs.stdenv.shell}
      ${dockerTools.shadowSetup}
      groupadd -r jellyfin
      useradd -r -g jellyfin -d /config -M jellyfin
      mkdir -p /config /cache /media
      chown -R jellyfin:jellyfin /config /cache /media
    '';

    copyToRoot = pkgs.buildEnv {
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
      User = "jellyfin:jellyfin";
    };
  };
in 
{
  # Create jellyfin user
  users.groups.jellyfin = {};
  users.users.jellyfin = {
    isSystemUser = true;
    home = "/var/lib/jellyfin";
    extraGroups = [ "podman" "jellyfin"];
    group = "jellyfin";
  };

  # Ensure folders exit
  systemd.tmpfiles.rules = [
    "d /srv/jellyfin/var/lib/jellyfin/config 0775 jellyfin jellyfin"
    "d /srv/jellyfin/var/lib/jellyfin/cache 0775 jellyfin jellyfin"
    "d /srv/media 0775 jellyfin jellyfin"
  ];

  # Open the firewall ports
  networking.firewall = {
    allowedTCPPorts = [ 8096 8920 ];
  };

  # Define the container
  virtualisation.oci-containers.containers.jellyfin-custom = {
    image = "${imageName}:${imageTag}";  # Tag matches our custom image
    imageFile = jellyfinImage.outPath;  # Use our custom image

    user = "jellyfin:jellyfin";

    autoStart = true;
    ports = [
      "0.0.0.0:8096:8096/tcp"  # HTTP web interface
      "0.0.0.0:8920:8920/tcp"  # HTTPS web interface
    ];

    volumes = [
      "/srv/jellyfin/config:/config:rw"
      "/srv/jellyfin/cache:/cache:rw"
      "/srv/media:/media:rw"
    ];

    environment = {
      JELLYFIN_CONFIG_DIR = "/config";
      JELLYFIN_CACHE_DIR = "/cache";
      JELLYFIN_DATA_DIR = "/media";
    };

    extraOptions = [
    ];
  };
}
