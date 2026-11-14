{ config, pkgs, ... }: {
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  virtualisation.containers.containersConf.settings = {
    containers.log_driver = "k8s-file";
    # containers.base_hosts_file = "/etc/containers/hosts";
  };

  systemd.services.podman-restart.enable = true;

  virtualisation.containers.registries.settings = {
    unqualified-search-registries = [
      "docker.io"
      "quay.io"
    ];
  };

  networking.firewall.extraInputRules = ''
    iifname "podman*" meta l4proto { tcp, udp } th dport 53 accept
  '';

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
  ];
}
