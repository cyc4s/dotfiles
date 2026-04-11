{ config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  mkLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in
{
  # ~/.config/ 配下のシンボリックリンク
  # 編集後は home-manager switch 不要（新しいターミナルを開くだけで反映）
  xdg.configFile = {
    "starship.toml".source = mkLink "starship.toml";
    "nvim".source = mkLink "nvim";
    "vde/layout.yml".source = mkLink ".config/vde/layout.yml";
    "mise/config.toml".source = mkLink ".config/mise/config.toml";
  };

  # ~/直下のドットファイル
  home.file = {
    ".nbrc".source = mkLink "nb/.nbrc";
    ".tmux.conf".source = mkLink ".tmux.conf";
  };
}
