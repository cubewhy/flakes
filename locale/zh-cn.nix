{pkgs, ...}: {
  time.timeZone = "Asia/Shanghai";

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

  fonts.packages = with pkgs; [
    source-han-sans
    source-han-serif
    source-han-mono
    noto-fonts
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Source Han Serif SC" "Source Han Serif TC" "Noto Serif CJK SC" "DejaVu Serif"];
      sansSerif = ["Source Han Sans SC" "Source Han Sans TC" "Noto Sans CJK SC" "DejaVu Sans"];
      monospace = ["Source Han Mono SC" "Source Han Mono TC" "Noto Sans Mono CJK SC" "DejaVu Sans Mono"];
    };
  };

  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <test name="lang">
        <string>zh-cn</string>
      </test>
      <test name="family">
        <string>sans-serif</string>
      </test>
      <edit name="family" mode="prepend" binding="strong">
        <string>Source Han Sans SC</string>
      </edit>
    </match>
  '';
}
