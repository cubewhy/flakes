{pkgs, ...}: {
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

  environment.etc."containers/hosts".text = ''
    10.88.0.1 host.docker.internal
  '';

  virtualisation.containers.containersConf.settings = {
    containers.base_hosts_file = "/etc/containers/hosts";
  };

  systemd.services.podman-restart = {
    enable = true;
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.podman}/bin/podman start --all --filter restart-policy=always --filter restart-policy=unless-stopped"
      ];
    };
  };

  systemd.user.services.podman-restart = {
    enable = true;
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.podman}/bin/podman start --all --filter restart-policy=always --filter restart-policy=unless-stopped"
      ];
    };
  };

  virtualisation.containers.registries.settings = {
    unqualified-search-registries = [ "docker.io" "quay.io" ];
  };

  networking.firewall = {
    trustedInterfaces = ["podman0"];

    extraCommands = ''
      iptables -A INPUT -i podman+ -p udp --dport 53 -j ACCEPT
      iptables -A INPUT -i podman+ -p tcp --dport 53 -j ACCEPT
    '';
  };

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
  ];
}
