-- codediff for reviewing a branch, plus a worktree switcher. Both pick from a
-- list through vim.ui.select, which LazyVim routes to the snacks picker.
local function git_lines(args)
  return vim.fn.systemlist(vim.list_extend({ "git" }, args))
end

local function pick_worktree(on_pick)
  local paths = {}
  for _, line in ipairs(git_lines({ "worktree", "list", "--porcelain" })) do
    local path = line:match("^worktree (.+)")
    if path then
      table.insert(paths, path)
    end
  end
  vim.ui.select(paths, {
    prompt = "Worktree",
    format_item = function(p)
      return vim.fn.fnamemodify(p, ":~")
    end,
  }, function(path)
    if path then
      on_pick(path)
    end
  end)
end

local function diff_against_base(dir)
  -- origin/HEAD is an alias for another branch, so it only adds noise.
  local branches = vim.tbl_filter(function(b)
    return not b:match("/HEAD$")
  end, git_lines({ "-C", dir, "branch", "-a", "--format=%(refname:lstrip=2)" }))
  vim.ui.select(branches, { prompt = "Base branch" }, function(base)
    -- "base..." diffs the working tree against where this branch forked, so
    -- uncommitted work shows and commits that landed on base since do not.
    -- -C pins it to dir: otherwise it uses the current buffer's repo, which
    -- after <leader>gw is still the old worktree, and the diff comes up empty.
    if base then
      vim.cmd("CodeDiff -C " .. vim.fn.fnameescape(dir) .. " " .. base .. "...")
    end
  end)
end

return {
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
      -- One pane with deleted lines shown above the new ones, like GitHub,
      -- instead of old and new files side by side.
      diff = {
        layout = "inline",
        -- Both are off by default, which leaves an added file looking like any
        -- other file: the only hint is the A in the explorer.
        highlight_added_deleted_files = true,
        -- Must be a table; `true` is silently ignored. The inline layout only
        -- signs whole added or deleted files, so config below adds the rest.
        gutter_signs = {},
      },
      highlights = {
        -- carbonfox's DiffDelete (#311d26) is a dim purple that barely shows
        -- against the background. The word-level red is derived from this.
        line_delete = "#4a1c24",
      },
    },
    config = function(_, opts)
      require("codediff").setup(opts)
      -- codediff's inline layout draws no +/- signs on changed lines. Wrap its
      -- renderer to add them. This leans on codediff internals (the module,
      -- its namespace, the shape of diff_result), so recheck after updates.
      local inline = require("codediff.ui.inline")
      local signs = require("codediff.ui.gutter_signs")
      local sign_ns = vim.api.nvim_get_namespaces()["codediff-gutter-signs"]

      -- codediff signs a run of lines with one extmark spanning them, but the
      -- snacks statuscolumn draws a sign on its start row only, so an added
      -- file showed + on line 1 alone. Split each span into one mark per line.
      local function split_spans(bufnr)
        if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
          return
        end
        local last_row = vim.api.nvim_buf_line_count(bufnr) - 1
        for _, m in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, sign_ns, 0, -1, { details = true })) do
          local d = m[4]
          -- end_col 0 means the span stops at the start of end_row.
          local last = d.end_row and math.min(d.end_col == 0 and d.end_row - 1 or d.end_row, last_row)
          if last and last > m[2] then
            vim.api.nvim_buf_del_extmark(bufnr, sign_ns, m[1])
            for row = m[2], last do
              vim.api.nvim_buf_set_extmark(bufnr, sign_ns, row, 0, {
                sign_text = d.sign_text,
                sign_hl_group = d.sign_hl_group,
                number_hl_group = d.number_hl_group,
                priority = d.priority,
              })
            end
          end
        end
      end
      for _, name in ipairs({ "set_changed_ranges", "set_whole_file" }) do
        local set = signs[name]
        signs[name] = function(a, b, ...)
          set(a, b, ...)
          split_spans(a)
          -- set_whole_file's second argument is a side name, not a buffer.
          if type(b) == "number" then
            split_spans(b)
          end
        end
      end

      local render = inline.render_inline_diff
      inline.render_inline_diff = function(bufnr, diff_result, ...)
        render(bufnr, diff_result, ...)
        -- + on added lines. No left buffer in this layout, so pass nil for it.
        signs.set_changed_ranges(nil, bufnr, diff_result and diff_result.changes)
        -- Removed lines are virtual lines, which have no sign column. Redraw
        -- them from the window's left edge with a - over the gutter instead.
        local win = vim.fn.win_findbuf(bufnr)[1] or vim.api.nvim_get_current_win()
        local gutter = vim.fn.getwininfo(win)[1].textoff
        local text = opts.diff.gutter_signs.delete_text or "－"
        local prefix = { text .. string.rep(" ", gutter - vim.fn.strdisplaywidth(text)), "CodeDiffGutterDelete" }
        for _, m in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, inline.ns_inline, 0, -1, { details = true })) do
          local d = m[4]
          if d.virt_lines then
            for _, line in ipairs(d.virt_lines) do
              table.insert(line, 1, prefix)
            end
            d.id, d.ns_id, d.virt_lines_leftcol = m[1], nil, true
            vim.api.nvim_buf_set_extmark(bufnr, inline.ns_inline, m[2], m[3], d)
          end
        end
      end
    end,
    keys = {
      {
        "<leader>gD",
        function()
          diff_against_base(vim.fn.getcwd())
        end,
        desc = "Diff against base branch",
      },
      {
        "<leader>gW",
        function()
          pick_worktree(diff_against_base)
        end,
        desc = "Diff a worktree against base branch",
      },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      -- LazyVim's snacks extra binds this to a diff picker; codediff owns it.
      { "<leader>gD", false },
      {
        "<leader>gw",
        function()
          pick_worktree(function(path)
            vim.cmd.cd(path)
            vim.notify("cwd: " .. vim.fn.fnamemodify(path, ":~"))
          end)
        end,
        desc = "Switch worktree",
      },
    },
  },
}
