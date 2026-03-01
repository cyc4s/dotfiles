#!/usr/bin/env bash
set -euo pipefail

# ==================================
#  dotfiles setup (WSL2 + Nix)
# ==================================

DOTFILES_REPO="https://github.com/cyc4s/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
NIX_INSTALLER_URL="https://install.determinate.systems/nix"

# --- ログ出力 ---
info()    { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m[OK]\033[0m   %s\n' "$*"; }
warn()    { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error()   { printf '\033[1;31m[ERR]\033[0m  %s\n' "$*"; exit 1; }

# --- Step 1: 環境チェック ---
check_wsl() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        info "WSL2 環境を検出しました"
    else
        warn "WSL 環境ではないようです。このスクリプトは WSL2 Ubuntu 向けに設計されています"
        warn "続行します..."
    fi
}

check_prerequisites() {
    if ! command -v curl &>/dev/null; then
        info "curl をインストール中..."
        sudo apt-get update -qq && sudo apt-get install -y -qq curl
    fi
    success "curl は利用可能です"
}

# --- Step 2: Nix インストール ---
install_nix() {
    if command -v nix &>/dev/null; then
        success "Nix はすでにインストール済みです ($(nix --version))"
        return 0
    fi

    info "Nix をインストール中 (Determinate Systems installer)..."
    curl --proto '=https' --tlsv1.2 -sSf -L "$NIX_INSTALLER_URL" | sh -s -- install

    # 現在のセッションで nix を使えるようにする
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # shellcheck disable=SC1091
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    if command -v nix &>/dev/null; then
        success "Nix のインストールが完了しました"
    else
        error "Nix のインストールに失敗しました。上のログを確認してください"
    fi
}

# --- Step 3: dotfiles を clone ---
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        success "dotfiles リポジトリは既に存在します ($DOTFILES_DIR)"
        return 0
    fi

    if [ -d "$DOTFILES_DIR" ]; then
        error "$DOTFILES_DIR は存在しますが git リポジトリではありません。削除またはリネームしてください"
    fi

    info "dotfiles を clone 中 (nix-shell -p git)..."
    nix-shell -p git --run "git clone '$DOTFILES_REPO' '$DOTFILES_DIR'"
    success "dotfiles を $DOTFILES_DIR に clone しました"
}

# --- Step 4: home-manager switch ---
apply_home_manager() {
    info "home-manager 設定を適用中..."
    info "(初回はパッケージのダウンロードに時間がかかります)"

    nix run home-manager -- switch --flake "$DOTFILES_DIR" --impure -b backup

    success "home-manager 設定の適用が完了しました"
}

# --- Step 5: デフォルトシェルを zsh に変更 ---
change_shell() {
    local zsh_path
    zsh_path="$HOME/.nix-profile/bin/zsh"

    if [ ! -x "$zsh_path" ]; then
        warn "zsh が $zsh_path に見つかりません。シェル変更をスキップします"
        return 0
    fi

    # すでに zsh がデフォルトなら skip
    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    if [ "$current_shell" = "$zsh_path" ]; then
        success "zsh はすでにデフォルトシェルです"
        return 0
    fi

    # /etc/shells に追加
    if ! grep -qF "$zsh_path" /etc/shells; then
        info "$zsh_path を /etc/shells に追加中..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    info "デフォルトシェルを zsh に変更中..."
    sudo chsh -s "$zsh_path" "$USER"
    success "デフォルトシェルを zsh に変更しました（次回ログイン時に反映）"
}

# --- Main ---
main() {
    echo ""
    echo "======================================="
    echo "  dotfiles setup (WSL2 + Nix)"
    echo "======================================="
    echo ""

    check_wsl
    check_prerequisites   # curl のみ確認（git は Nix 経由で使う）
    install_nix
    clone_dotfiles        # nix-shell -p git で clone
    apply_home_manager
    change_shell

    echo ""
    echo "======================================="
    success "セットアップ完了！"
    echo "======================================="
    echo ""
    info "新しいターミナルを開く（または 'exec zsh' を実行）と zsh が使えます"
    info "設定を変更した後は nix-switch で適用できます"
    echo ""
}

main "$@"
