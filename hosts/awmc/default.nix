{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../locale/fonts.nix
    ../../locale/zh-cn.nix
    ../../software/fcitx5.nix
    ../../software/direnv.nix
    ../../software/nix-ld.nix
    ../../software/sccache.nix
    ../../software/plymouth.nix
    # ../../software/proxy/mihomo
    ../../software/proxy/v2raya.nix
    ../../software/virt/podman.nix
    ../../software/virt/distrobox.nix
    ../../software/drivers/bluetooth.nix
    ../../software/drivers/opentabletdriver.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.microsoft-surface.kernelVersion = "stable";

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
  hardware.i2c.enable = true;

  services.xserver = {
    excludePackages = [ pkgs.xterm ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  boot.extraModprobeConfig = ''
    options mwifiex_pcie disable_auto_ds=1
  '';

  hardware.sensor.iio.enable = true;

  boot.kernel.sysctl."kernel.sysrq" = 1;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  users.users."cubewhy" = {
    isNormalUser = true;
    description = "cubewhy";
    extraGroups = [
      "wheel"
      "i2c"
      "networkmanager"
      "surface-control"
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    librewolf
    p7zip
    rar
    bind
    ddcutil
    usbutils
    pciutils
    fd
    ripgrep
    unzip
    imagemagick
    libva-utils
    btop

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
    packages = [ ];
  };

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

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

  systemd.user.services.podman-restart = {
    enable = true;
    wantedBy = [ "multi-user.target" ];

    unitConfig = {
      ConditionUser = "cubewhy";
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs =
        pkgs: with pkgs; [
          webkitgtk_4_1
          libsoup_3
        ];
    };
  };

  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  nix.settings = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

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
