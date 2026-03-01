# WezTerm shell integration - OSC 7 でカレントディレクトリを通知
# ペイン分割時に同じディレクトリで開くために必要
__wezterm_osc7() {
  printf '\033]7;file://%s%s\033\\' "${HOSTNAME}" "${PWD}"
}
precmd_functions+=(__wezterm_osc7)
