{ ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.v2raya = {
      image = "ghcr.io/v2raya/v2raya:latest";
      autoStart = true;
      extraOptions = [
        "--privileged"
        "--network=host"
      ];
      environment = {
        V2RAYA_LOG_FILE = "/tmp/v2raya.log";
      };
      volumes = [
        "/run/current-system/kernel-modules:/lib/modules:ro"
        "/etc/resolv.conf:/etc/resolv.conf"
        "/etc/v2raya:/etc/v2raya"
      ];
    };
  };

  networking.proxy = {
    default = "http://127.0.0.1:20172";
    noProxy = "127.0.0.1,localhost,internal.domain";
  };
}
