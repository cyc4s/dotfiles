{ config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      ZRCDIR="${dotfilesPath}/zsh/rc"
      for rc in "$ZRCDIR"/*.zsh; do
        [ -f "$rc" ] && source "$rc"
      done
    '';
  };

  # starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

}
