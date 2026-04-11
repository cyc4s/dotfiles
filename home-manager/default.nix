{ pkgs, username, homeDirectory, ... }:

{
  imports = [
    ./zsh.nix
    ./dotfiles.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    nodejs_24
    neovim
    nb
    ripgrep
    lazygit
    gcc
    wslu
    gh
    tmux
    mise
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # home-manager 自身の管理を有効化
  programs.home-manager.enable = true;
}
