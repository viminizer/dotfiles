-- Beat navigation for the course repos (turnout, shortlist, pulse).
--
-- In those repos the git history is the product: one commit and one tag per
-- beat, numbered 1, 1.1, 1.1.1 and so on. Teaching means checking out a beat,
-- talking about it, then moving to the next one. `git checkout 1.2.3` works but
-- means leaving the editor and remembering the number, and 129 tags is more
-- than anyone remembers.
--
-- Every checkout here refuses to run on a dirty worktree. Losing live edits in
-- front of a class is not a recoverable mistake.
local M = {}

---@param args string[]
---@return string[] lines, boolean ok
local function git(args)
  local cmd = { "git", "-C", vim.fn.getcwd() }
  vim.list_extend(cmd, args)
  local res = vim.system(cmd, { text = true }):wait()
  local out = vim.split(vim.trim(res.stdout or ""), "\n", { trimempty = true })
  return out, res.code == 0
end

---Beats in repo order, each as { tag, subject }.
---@return { tag: string, subject: string }[]
local function beats()
  -- Sorted by version so 1.10 lands after 1.9 rather than after 1.1.
  local lines = git({ "for-each-ref", "--sort=v:refname", "--format=%(refname:short)\t%(contents:subject)", "refs/tags" })
  return vim.tbl_map(function(line)
    local tag, subject = line:match("^([^\t]*)\t?(.*)$")
    return { tag = tag, subject = subject }
  end, lines)
end

---The tag at HEAD, or nil when HEAD is not on a beat.
---@return string?
local function current()
  local out, ok = git({ "tag", "--points-at", "HEAD" })
  return ok and out[1] or nil
end

---@return boolean
local function clean()
  local out = git({ "status", "--porcelain" })
  if #out > 0 then
    vim.notify("Worktree has uncommitted changes. Commit or stash first.", vim.log.levels.WARN)
    return false
  end
  return true
end

---@param tag string
local function checkout(tag)
  if not clean() then
    return
  end
  local _, ok = git({ "checkout", "--quiet", tag })
  if not ok then
    vim.notify("Could not check out " .. tag, vim.log.levels.ERROR)
    return
  end
  -- Reload every buffer from disk. Without this the screen still shows the
  -- previous beat while the files on disk have already moved on.
  vim.cmd("checktime")
  vim.notify("Beat " .. tag, vim.log.levels.INFO)
end

---The beat shown in lualine. Empty outside a repo with tags.
---@return string
function M.status()
  local tag = current()
  return tag and ("󰃀 " .. tag) or ""
end

---Jump `offset` beats from wherever HEAD is.
---@param offset integer
function M.step(offset)
  local list = beats()
  if #list == 0 then
    vim.notify("No tags in this repo", vim.log.levels.WARN)
    return
  end
  local tag = current()
  if not tag then
    vim.notify("HEAD is not on a beat. Pick one first.", vim.log.levels.WARN)
    return
  end
  for i, beat in ipairs(list) do
    if beat.tag == tag then
      local target = list[i + offset]
      if not target then
        vim.notify(offset > 0 and "Already at the last beat" or "Already at the first beat", vim.log.levels.INFO)
        return
      end
      checkout(target.tag)
      return
    end
  end
end

---Pick a beat from the full list.
function M.pick()
  local list = beats()
  if #list == 0 then
    vim.notify("No tags in this repo", vim.log.levels.WARN)
    return
  end
  local width = 0
  for _, beat in ipairs(list) do
    width = math.max(width, #beat.tag)
  end
  vim.ui.select(list, {
    prompt = "Beat",
    format_item = function(beat)
      return string.format("%-" .. width .. "s  %s", beat.tag, beat.subject)
    end,
  }, function(beat)
    if beat then
      checkout(beat.tag)
    end
  end)
end

---Diff the current beat against the one before it, so the class sees exactly
---what this step introduced.
function M.diff()
  local tag = current()
  if not tag then
    vim.notify("HEAD is not on a beat", vim.log.levels.WARN)
    return
  end
  local list = beats()
  for i, beat in ipairs(list) do
    if beat.tag == tag and i > 1 then
      local prev = list[i - 1].tag
      vim.cmd("tabnew")
      vim.cmd("terminal git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " diff " .. prev .. " " .. tag)
      return
    end
  end
  vim.notify("No beat before " .. tag, vim.log.levels.INFO)
end

return M
