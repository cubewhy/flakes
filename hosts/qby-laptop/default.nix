# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../locale/zh-cn.nix
      ../../software/fcitx5.nix
      ../../software/direnv.nix
      ../../software/nix-ld.nix
      ../../software/plymouth.nix
      ../../software/proxy/mihomo
      ../../software/virt/podman.nix
      ../../software/virt/distrobox.nix
      ../../software/drivers/nvidia.nix
      ../../software/drivers/bluetooth.nix
      ../../software/drivers/remap-copilot.nix
      ../../software/drivers/opentabletdriver.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "tpm_crb" "tpm_tis"];

  boot.initrd.luks.devices = {
    "luks-f5030deb-c3d5-42f7-812a-68994bfe9663".crypttabExtraOpts = [ "tpm2-device=auto" ];

    "luks-c01678b1-2176-41da-9b3e-b39d7fab3608" = {
      device = "/dev/disk/by-uuid/c01678b1-2176-41da-9b3e-b39d7fab3608";
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    "cryptdata" = {
      device = "/dev/disk/by-uuid/9f9c80d1-5cbb-44a4-8c21-e96eab99dc97";
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };

  fileSystems."/mnt/data" = {
    device = "/dev/mapper/cryptdata";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data 1777 root root -"
  ];

  networking.hostName = "qby-nixos-laptop";

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  services.xserver = {
    excludePackages = [pkgs.xterm];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."cubewhy" = {
    isNormalUser = true;
    description = "cubewhy";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    blacklist redmi_wmi
    blacklist wacom
    blacklist hid_uclogic
  '';

  boot.kernelParams = [
    "quiet"
    "gpiolib_acpi.ignore_wake=AMDI0030:00@4"
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e487", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e487", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="362d", ATTR{idProduct}=="d20f", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTR{idVendor}=="362d", ATTR{idProduct}=="d20f", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{idProduct}=="d000", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTR{idVendor}=="3434", ATTR{idProduct}=="d000", MODE="0660", TAG+="uaccess"

    # Gaomon M5 V2 / 256c:200e
    KERNEL=="hidraw*", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="200e", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="256c", ATTR{idProduct}=="200e", MODE="0666"
  '';

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    git
    librewolf
    sbctl
    p7zip
    rar
    bind
    usbutils
    pciutils

    kdePackages.ksshaskpass
    kdePackages.partitionmanager
    kdePackages.kcolorchooser
    kdePackages.kclock
    kdePackages.kfind
    kdePackages.kcharselect
    kdePackages.kcalc
    kdePackages.kate
    kdePackages.kdialog
    kdePackages.filelight
  ];

  services.flatpak = {
    enable = true;
    packages = [];
  };

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.xserver.videoDrivers = [
    "amdgpu"
  ];


  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    nvidiaBusId = "PCI:1@0:0:0";
    amdgpuBusId = "PCI:5@0:0:0";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    inter
  ];

  fonts.fontconfig.useEmbeddedBitmaps = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-qt;
  };

  environment.sessionVariables = {
    PINENTRY_KDE_USE_WALLET = "1";
    SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  systemd.user.services.gpg-agent.environment = {
    PINENTRY_KDE_USE_WALLET = "1";
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  nix.settings = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
