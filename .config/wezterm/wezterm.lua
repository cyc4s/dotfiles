local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- WSL の既定ディストリビューションをデフォルトで開く
local success, stdout = wezterm.run_child_process({ "wsl.exe", "-l", "-q" })
if success then
  local distro = stdout:gsub("\0", ""):match("^%s*(.-)%s*[\r\n]")
  if distro and distro ~= "" then
    config.default_domain = "WSL:" .. distro
  end
end

-- 見た目
config.color_scheme = "nightfox"
config.font = wezterm.font("HackGen Console NF")
config.font_size = 13.0
config.initial_cols = 160
config.initial_rows = 48
config.window_background_opacity = 0.95
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

-- 基本設定
config.use_ime = true
config.scrollback_lines = 5000
config.automatically_reload_config = true

-- Claude Code の完了通知
wezterm.on("bell", function(window, pane)
  local process = pane:get_foreground_process_info()
  if process and process.argv then
    for _, arg in ipairs(process.argv) do
      if arg:find("claude") then
        window:toast_notification("Claude Code", "Task completed", nil, 4000)
        return
      end
    end
  end
end)

-- Leader key
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

-- Leader キー押下時にステータスバーに表示
wezterm.on("update-right-status", function(window)
  local leader = window:leader_is_active() and " LEADER " or ""
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#1d1f21" } },
    { Background = { Color = "#f0c674" } },
    { Text = leader },
  }))
end)

local act = wezterm.action

config.keys = {
  -- ペイン分割
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
  { key = "-", mods = "LEADER", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },

  -- ペイン移動 (vim スタイル)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- ペインを閉じる
  { key = "d", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },

  -- タブ操作
  { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "h", mods = "LEADER|CTRL", action = act.ActivateTabRelative(-1) },
  { key = "l", mods = "LEADER|CTRL", action = act.ActivateTabRelative(1) },

  -- コピーモード
  { key = "v", mods = "LEADER", action = act.ActivateCopyMode },

  -- ランチャー
  { key = "l", mods = "ALT", action = act.ShowLauncher },

  -- 単語単位の移動・削除
  { key = "LeftArrow", mods = "CTRL", action = act.SendKey({ key = "b", mods = "META" }) },
  { key = "RightArrow", mods = "CTRL", action = act.SendKey({ key = "f", mods = "META" }) },
  { key = "Backspace", mods = "CTRL", action = act.SendKey({ key = "w", mods = "CTRL" }) },
}

return config
