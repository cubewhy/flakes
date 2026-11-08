{ pkgs, ... }: {

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
  hardware.i2c.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  services.xserver = {
    excludePackages = [ pkgs.xterm ];
  };

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];

  environment.systemPackages = with pkgs; [
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

  environment.sessionVariables = {
    PINENTRY_KDE_USE_WALLET = "1";
    SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  systemd.user.services.gpg-agent.environment = {
    PINENTRY_KDE_USE_WALLET = "1";
  };

}
