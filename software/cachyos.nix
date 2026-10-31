{
  pkgs,
  lib,
  ...
}:
{
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
  # other (optional) custom CachyOS packages that may be fit for your setup include:
  boot.zfs.package = lib.mkForce pkgs.zfs_cachyos;
  hardware.nvidia.package = lib.mkForce pkgs.nvidia_cachyos;
  services.scx = {
    enable = true;
    scheduler = "scx_rusty";
  };
}
