# ls
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# nix / home-manager
alias nix-switch='nix run ~/dotfiles#switch --impure'
alias nix-update='nix run ~/dotfiles#update --impure'
alias nix-check='nix run ~/dotfiles#check --impure'
alias nix-clean='nix run ~/dotfiles#clean --impure'
