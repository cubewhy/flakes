# Notes:
# You can manage your subscriptions with Substore by accessing the following url
# http://127.0.0.1:23001
# (You need to create a proxy collection called `subscriptions` to make the things work)
# Switch node with the webui
# http://127.0.0.1:9090/ui
# Never open the 23001 and 9090 port to the public!
{
  pkgs,
  lib,
  ...
}: {
  networking.proxy.default = "http://127.0.0.1:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  boot.kernelModules = [
    "tun"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      mihomo = prev.mihomo.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or []) ++ [
          ./mihomo-xray-workaround.patch
        ];
      });
    })
  ];

  services.mihomo = {
    enable = true;
    configFile = "/etc/mihomo/config.yaml";

    tunMode = true;
    webui = pkgs.metacubexd;
  };

  environment.etc."mihomo/config.yaml" = {
    source = ./config.yaml;
    mode = "0700";
    user = "root";
  };

  networking.firewall = {
    enable = lib.mkForce false;
    trustedInterfaces = ["utun" "virbr0" "docker0" "lo"];

    checkReversePath = "loose";

    allowedUDPPorts = [53 1053];
    allowedTCPPorts = [53 1053];

    extraCommands = ''
      iptables -A FORWARD -i docker0 -j ACCEPT
      iptables -A FORWARD -o docker0 -j ACCEPT
      iptables -A FORWARD -i br-+ -j ACCEPT
      iptables -A FORWARD -o br-+ -j ACCEPT

      iptables -t nat -A PREROUTING -i docker0 -p udp --dport 53 -j REDIRECT --to-ports 1053
      iptables -t nat -A PREROUTING -i docker0 -p tcp --dport 53 -j REDIRECT --to-ports 1053
      iptables -t nat -A PREROUTING -i br-+ -p udp --dport 53 -j REDIRECT --to-ports 1053
      iptables -t nat -A PREROUTING -i br-+ -p tcp --dport 53 -j REDIRECT --to-ports 1053

      iptables -t nat -A POSTROUTING -s 172.16.0.0/12 -j MASQUERADE
    '';
  };

  networking.nat = {
    enable = true;
    internalInterfaces = ["virbr0"];
    externalInterface = "utun";
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.conf.docker0.rp_filter" = 0;
    "net.ipv4.conf.utun.rp_filter" = 0;
  };

  # services.resolved.enable = false;
  # networking.nameservers = ["127.0.0.1"];
}
