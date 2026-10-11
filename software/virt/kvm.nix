{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };
  programs.virt-manager.enable = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  environment.systemPackages = with pkgs; [
    dnsmasq
  ];
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
