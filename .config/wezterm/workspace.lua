local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

local previous_workspace = nil

-- scratch ワークスペースをトグル
local function toggle_scratch_workspace()
  return wezterm.action_callback(function(window, pane)
    local current = wezterm.mux.get_active_workspace()

    if current == "scratch" then
      local target = previous_workspace or "default"
      window:perform_action(act.SwitchToWorkspace({ name = target }), pane)
    else
      previous_workspace = current
      window:perform_action(act.SwitchToWorkspace({ name = "scratch" }), pane)
    end
  end)
end

-- scratch を除外したワークスペース一覧を取得
local function get_filtered_workspaces()
  local filtered = {}
  for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
    if ws ~= "scratch" then
      table.insert(filtered, ws)
    end
  end
  return filtered
end

-- 次のワークスペースへ切替（scratch をスキップ）
local function switch_to_next_workspace()
  return wezterm.action_callback(function(window, pane)
    local filtered = get_filtered_workspaces()
    local current = wezterm.mux.get_active_workspace()

    local current_index = 1
    for i, ws in ipairs(filtered) do
      if ws == current then
        current_index = i
        break
      end
    end

    local next_index = current_index + 1
    if next_index > #filtered then
      next_index = 1
    end

    if #filtered > 0 then
      window:perform_action(act.SwitchToWorkspace({ name = filtered[next_index] }), pane)
    end
  end)
end

-- 前のワークスペースへ切替（scratch をスキップ）
local function switch_to_prev_workspace()
  return wezterm.action_callback(function(window, pane)
    local filtered = get_filtered_workspaces()
    local current = wezterm.mux.get_active_workspace()

    local current_index = 1
    for i, ws in ipairs(filtered) do
      if ws == current then
        current_index = i
        break
      end
    end

    local prev_index = current_index - 1
    if prev_index < 1 then
      prev_index = #filtered
    end

    if #filtered > 0 then
      window:perform_action(act.SwitchToWorkspace({ name = filtered[prev_index] }), pane)
    end
  end)
end

-- ワークスペース一覧から選択（fuzzy）
local function select_workspace()
  return wezterm.action_callback(function(window, pane)
    local workspaces = {}
    local index = 1
    for _, name in ipairs(wezterm.mux.get_workspace_names()) do
      if name ~= "scratch" then
        table.insert(workspaces, {
          id = name,
          label = string.format("%d. %s", index, name),
        })
        index = index + 1
      end
    end

    window:perform_action(
      act.InputSelector({
        action = wezterm.action_callback(function(_, _, id, label)
          if id then
            window:perform_action(act.SwitchToWorkspace({ name = id }), pane)
          end
        end),
        title = "Select workspace",
        choices = workspaces,
        fuzzy = true,
      }),
      pane
    )
  end)
end

-- 新規ワークスペース作成
local function create_workspace()
  return act.PromptInputLine({
    description = "(wezterm) Create new workspace:",
    action = wezterm.action_callback(function(window, _, line)
      if not line or line == "" then
        return
      end
      local tab = window:mux_window():active_tab()
      local pane = tab and tab:active_pane()
      if not pane then
        return
      end
      window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
    end),
  })
end

function module.apply_to_config(config)
  local keys = {
    { key = "w", mods = "LEADER", action = select_workspace() },
    { key = "w", mods = "LEADER|SHIFT", action = create_workspace() },
    { key = "s", mods = "LEADER", action = toggle_scratch_workspace() },
    { key = "n", mods = "LEADER", action = switch_to_next_workspace() },
    { key = "p", mods = "LEADER", action = switch_to_prev_workspace() },
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return module
