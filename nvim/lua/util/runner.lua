-- Send JS/TS to a tmux pane and run it, so a lesson can show output next to
-- the code instead of cutting away to a terminal.
--
-- The pane is opened once, below the editor, and reused. Anything sent to it
-- lands in a temp file first: pasting a multi-line snippet straight into a
-- shell gets mangled by bracketed paste and by the shell's own history.
local M = {}

local PANE_TITLE = "runner"

---@param args string[]
---@return string
local function tmux(args)
  local cmd = { "tmux" }
  vim.list_extend(cmd, args)
  return vim.trim(vim.system(cmd, { text = true }):wait().stdout or "")
end

---@return string? pane id
local function find_pane()
  local out = tmux({ "list-panes", "-F", "#{pane_id} #{pane_title}" })
  for _, line in ipairs(vim.split(out, "\n", { trimempty = true })) do
    local id, title = line:match("^(%%%d+) (.*)$")
    if title == PANE_TITLE then
      return id
    end
  end
  return nil
end

---@return string? pane id
local function pane()
  local existing = find_pane()
  if existing then
    return existing
  end
  local id = tmux({ "split-window", "-d", "-v", "-p", "30", "-P", "-F", "#{pane_id}" })
  if id == "" then
    return nil
  end
  tmux({ "select-pane", "-t", id, "-T", PANE_TITLE })
  return id
end

---bun runs .ts directly, so a TypeScript snippet needs no build step. node is
---the fallback for machines without it.
---@return string
local function interpreter()
  return vim.fn.executable("bun") == 1 and "bun" or "node"
end

---@param code string
---@param ext string
local function send(code, ext)
  if vim.env.TMUX == nil then
    vim.notify("Not inside tmux", vim.log.levels.WARN)
    return
  end
  local target = pane()
  if not target then
    vim.notify("Could not open a tmux pane", vim.log.levels.ERROR)
    return
  end
  local file = vim.fn.tempname() .. "." .. ext
  vim.fn.writefile(vim.split(code, "\n"), file)
  tmux({ "send-keys", "-t", target, "clear && " .. interpreter() .. " " .. file, "Enter" })
end

---Run the whole buffer.
function M.run_buffer()
  local ext = vim.bo.filetype == "typescript" and "ts" or "js"
  send(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"), ext)
end

---Run just the visual selection, for showing one idea at a time.
function M.run_selection()
  local from = vim.fn.getpos("'<")
  local to = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, from[2] - 1, to[2], false)
  local ext = vim.bo.filetype == "typescript" and "ts" or "js"
  send(table.concat(lines, "\n"), ext)
end

---Close the runner pane.
function M.close()
  local target = find_pane()
  if target then
    tmux({ "kill-pane", "-t", target })
  end
end

return M
