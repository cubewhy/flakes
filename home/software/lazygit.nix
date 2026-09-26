{pkgs, ...}: let
  deltaThemes = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dandavison/delta/5ddd7fa66ee900b6783e80089174d2170e46f06f/themes.gitconfig";
    sha256 = "sha256-kPGzO4bzUXUAeG82UjRk621uL1faNOZfN4wNTc1oeN4=";
  };
in {
  xdg.configFile."delta/themes.gitconfig".source = deltaThemes;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      features = "decorations";
    };
  };

  xdg.configFile = {
    "lazygit/config.yml".text = ''
      git:
        overrideGpg: true
        log:
            order: default
        diffRenderers:
          - command: delta --dark --paging=never --line-numbers --features=colibri
            colorArg: always
          - command: ydiff -p cat -s --wrap --width={{columnWidth}}
            colorArg: never
          - command: difft --color=always
            type: extDiff
    '';
  };

  home.packages = with pkgs; [
    ydiff
    difftastic
    lazygit
  ];

  programs.git = {
    enable = true;

    includes = [
      {path = "~/.config/delta/themes.gitconfig";}
    ];
  };
}
