{ pkgs, ... }: {
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
}
