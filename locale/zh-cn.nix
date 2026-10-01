{pkgs, inputs, ...}: {
  time.timeZone = "Asia/Shanghai";

  nixpkgs.overlays = [ inputs.chinese-fonts-overlay.overlays.default ];

  fonts = {
    packages = with pkgs; [
      alibaba-fonts
      source-han-serif
      noto-fonts
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        sansSerif = [ "Alibaba Sans" "Alibaba PuHuiTi 3.0" ];
        serif = [ "Noto Serif" "Source Han Serif SC" ];
      };
    };
  };

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
