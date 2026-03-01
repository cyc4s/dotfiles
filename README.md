# Dotfiles

WSL2 + Nix + home-manager で管理する dotfiles

## Tools

- Terminal: [WezTerm](https://wezterm.org/) (Nightly)
- Shell: [zsh](https://www.zsh.org/)
- Font: [HackGen Console NF](https://github.com/yuru7/HackGen)

## Setup (New WSL)

WSL2 Ubuntu + curl があれば OK:

```bash
bash <(curl -sL https://raw.githubusercontent.com/cyc4s/dotfiles/main/setup.sh)
```

setup.sh が以下を自動で行います:

1. Nix インストール (Determinate Systems installer)
2. dotfiles を clone (`nix-shell -p git` で git を一時利用)
3. home-manager 設定を適用
4. デフォルトシェルを zsh に変更

### What's Managed by Nix

| Category | Description |
|----------|-------------|
| **Shell** | zsh (plugins, completions, syntax highlighting) |
| **Prompt** | Starship |
| **CLI Tools** | fzf |
| **Dotfiles** | starship.toml (symlink via home-manager) |

## Windows Side Setup

WezTerm 等の Windows アプリは WSL の `setup.sh` では管理できないため、手動セットアップが必要。

### 1. WezTerm インストール

```powershell
winget install wez.wezterm.nightly
```

### 2. フォントインストール

```powershell
winget install yuru7.HackGen.NF
```

### 3. シンボリックリンク作成

管理者 PowerShell で実行（初回のみ）:

```powershell
$distro = ((wsl -l -q)[0] -replace "`0","").Trim()
$wslUser = (wsl -e whoami).Trim()
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\wezterm" -Target "\\wsl$\$distro\home\$wslUser\dotfiles\.config\wezterm"
```

WSL の既定ディストリビューションとユーザー名を自動検出するので、手動の置き換え不要。

### Manual Setup Required

| Item | Reason |
|------|--------|
| SSH Keys | セキュリティ上、リポジトリに含めない |
| `.gitconfig` | 環境ごとにユーザー名・メールが異なる |
| Windows Side Setup | WSL 側の setup.sh では Windows アプリを管理できない |

## Daily Commands

```bash
nix-switch   # 設定を適用
nix-update   # flake inputs を更新して適用
nix-check    # flake のバリデーション
nix-clean    # 古い Nix store を GC
```
