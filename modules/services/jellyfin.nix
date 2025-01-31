# modules/containers/jellyfin.nix
{ pkgs, ... }@inputs:
{
  # Create jellyfin user
  users.users.jellyfin = {
    isSystemUser = true;
    home = "/var/lib/jellyfin";
    extraGroups = [ "podman" "jellyfin"];
  };

  # Ensure folders exit
  systemd.tmpfiles.rules = [
    "d /srv/jellyfin/var/lib/jellyfin/config 0750 jellyfin jellyfin"
    "d /srv/jellyfin/var/lib/jellyfin/cache 0750 jellyfin jellyfin"
    "d /srv/media/0750 jellyfin jellyfin"
  ];

  # Open the firewall ports
  networking.firewall = {
    allowedTCPPorts = [ 8096 8920 ];
  };

  # Define the container
  virtualisation.oci-containers.containers.jellyfin = {
    image = "jellyfin:latest";  # Tag matches our custom image
    imageFile = inputs.lm.containers.jellyfin;  # Use our custom image

    user = "jellyfin:jellyfin";

    autoStart = true;
    ports = [
      "0.0.0.0:8096:8096/tcp"  # HTTP web interface
      "0.0.0.0:8920:8920/tcp"  # HTTPS web interface
    ];

    volumes = [
      "/srv/jellyfin/var/lib/jellyfin/config:/config"
      "/srv/jellyfin/var/lib/jellyfin/cache:/cache"
      "/srv/media:/media"
    ];

    environment = {
      JELLYFIN_CONFIG_DIR = "/config";
      JELLYFIN_CACHE_DIR = "/cache";
      JELLYFIN_DATA_DIR = "/media";
    };

    extraOptions = [
      "--network=host"  # Optional: Use host network for better performance
    ];
  };
}
