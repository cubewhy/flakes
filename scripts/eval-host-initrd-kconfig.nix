# eval-host-initrd-kconfig.nix
# Evaluates host-specific initrd dependencies (storage, LUKS, filesystems)
# and exports them as built-in (=y) Kconfig options.
{
  flakePath ? ./..,
  hostname ? "qby-laptop",
}:

let
  flake = builtins.getFlake (toString flakePath);
  host = flake.nixosConfigurations.${hostname};
  hostConfig = host.config;

  lib = host.pkgs.lib or flake.inputs.nixpkgs.lib;

  rawModules = hostConfig.boot.initrd.availableKernelModules ++ hostConfig.boot.initrd.kernelModules;

  fsTypes = lib.unique (
    builtins.filter (fs: fs != "none" && fs != null) (
      lib.catAttrs "fsType" (builtins.attrValues hostConfig.fileSystems)
    )
  );

  hasLuks = (hostConfig.boot.initrd.luks.devices or { }) != { };

  # Module-to-Kconfig mapping for common drivers
  moduleToKconfig = {
    "ahci" = [
      "CONFIG_ATA=y"
      "CONFIG_SATA_AHCI=y"
    ];
    "nvme" = [
      "CONFIG_BLK_DEV_NVME=y"
      "CONFIG_NVME_CORE=y"
    ];
    "vmd" = [
      "CONFIG_VMD=y"
      "CONFIG_PCI=y"
    ];
    "xhci_pci" = [
      "CONFIG_USB_SUPPORT=y"
      "CONFIG_USB=y"
      "CONFIG_USB_XHCI_HCD=y"
      "CONFIG_USB_XHCI_PCI=y"
    ];
    "thunderbolt" = [ "CONFIG_THUNDERBOLT=y" ];
    "sd_mod" = [
      "CONFIG_SCSI=y"
      "CONFIG_BLK_DEV_SD=y"
    ];
    "sr_mod" = [
      "CONFIG_SCSI=y"
      "CONFIG_BLK_DEV_SR=y"
    ];
    "usb_storage" = [ "CONFIG_USB_STORAGE=y" ];
    "usbhid" = [
      "CONFIG_HID=y"
      "CONFIG_USB_HID=y"
    ];
    "hid_generic" = [
      "CONFIG_HID=y"
      "CONFIG_HID_GENERIC=y"
    ];
    "atkbd" = [ "CONFIG_KEYBOARD_ATKBD=y" ];
    "i8042" = [
      "CONFIG_SERIO=y"
      "CONFIG_SERIO_I8042=y"
    ];
  };

  # Filesystem-to-Kconfig mapping
  fsToKconfig = {
    "ext4" = [
      "CONFIG_EXT4_FS=y"
      "CONFIG_EXT4_FS_POSIX_ACL=y"
    ];
    "btrfs" = [
      "CONFIG_BTRFS_FS=y"
      "CONFIG_BTRFS_FS_POSIX_ACL=y"
    ];
    "vfat" = [
      "CONFIG_FAT_FS=y"
      "CONFIG_VFAT_FS=y"
      "CONFIG_NLS_CODEPAGE_437=y"
      "CONFIG_NLS_ISO8859_1=y"
    ];
    "f2fs" = [ "CONFIG_F2FS_FS=y" ];
    "xfs" = [ "CONFIG_XFS_FS=y" ];
  };

  # LUKS cryptsetup requirements
  luksKconfig =
    if hasLuks then
      [
        "CONFIG_MD=y"
        "CONFIG_BLK_DEV_DM=y"
        "CONFIG_DM_CRYPT=y"
        "CONFIG_CRYPTO=y"
        "CONFIG_CRYPTO_SKCIPHER=y"
        "CONFIG_CRYPTO_AES=y"
        "CONFIG_CRYPTO_XTS=y"
        "CONFIG_CRYPTO_SHA256=y"
        "CONFIG_CRYPTO_USER_API_SKCIPHER=y"
        "CONFIG_CRYPTO_AES_NI_INTEL=y"
      ]
    else
      [ ];

  # Flatten all evaluated entries
  mappedModules = lib.concatLists (
    map (m: moduleToKconfig.${m} or [ "CONFIG_${lib.toUpper m}=y" ]) rawModules
  );

  mappedFs = lib.concatLists (
    map (fs: fsToKconfig.${fs} or [ "CONFIG_${lib.toUpper fs}_FS=y" ]) fsTypes
  );

  allKconfigEntries = lib.unique (mappedModules ++ mappedFs ++ luksKconfig);
in
(lib.concatStringsSep "\n" (lib.sort (a: b: a < b) allKconfigEntries)) + "\n"
