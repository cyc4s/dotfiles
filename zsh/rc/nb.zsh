# nb 関連のシェル関数を読み込む（autoload）
fpath=("${0:a:h}/functions/nb" $fpath)
autoload -Uz nbq nba nbqr
