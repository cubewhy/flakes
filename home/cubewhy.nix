{ pkgs, config, ... }:

{
  imports = [
    ./software/lazygit.nix
  ];

  home.stateVersion = "26.05";

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets.smtp_password = { };
  };

  home.packages = with pkgs; [
    hyfetch
    fastfetch

    osu-lazer-bin
    thunderbird
    ayugram-desktop
    cotp
    krita
    gimp
    wl-clipboard
    vlc
    sccache

    nerd-fonts.jetbrains-mono
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "sccache"

    [target.x86_64-unknown-linux-gnu]
    linker = "clang"
    rustflags = ["-C", "link-arg=-fuse-ld=mold"]
  '';

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "family=\"JetBrainsMono Nerd Font\"";

      font_size = 12.0;

      cursor_blink_interval = 0;
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
    };
  };

  programs.bash.enable = true;
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/flakes#qby-laptop";
      ollama = "podman exec -it ollama ollama";
    };

    initContent = ''
      v() {
        zi "$@" && nvim
      }
    '';

    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zoxide" ];
      theme = "robbyrussell";
      extraConfig = ''
        ZSH_DISABLE_COMPFIX="true"
      '';
    };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    ignores = [
      ".direnv/"
      ".DS_Store"
      "node_modules/"
      "*.swp"
    ];
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
      format = "ssh";
    };
    settings = {
      sendemail = {
        smtpserver = "smtp.gmail.com";
        smtpuser = "qby140326@gmail.com";
        smtpserverport = 465;
        smtpencryption = "ssl";
        smtppasscmd = "cat ${config.sops.secrets.smtp_password.path}";
      };

      user = {
        name = "cubewhy";
        email = "qby140326@gmail.com";
      };
    };
  };
}
