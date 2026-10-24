-- codediff for reviewing a branch, plus a worktree switcher. Both pick from a
-- list through vim.ui.select, which LazyVim routes to the snacks picker.
local function git_lines(args)
  return vim.fn.systemlist(vim.list_extend({ "git" }, args))
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
        -- signs whole added or deleted files, not changed lines.
        gutter_signs = {},
      },
    },
    keys = {
      {
        "<leader>gD",
        function()
          -- origin/HEAD is an alias for another branch, so it only adds noise.
          local branches = vim.tbl_filter(function(b)
            return not b:match("/HEAD$")
          end, git_lines({ "branch", "-a", "--format=%(refname:lstrip=2)" }))
          vim.ui.select(branches, { prompt = "Base branch" }, function(base)
            -- "base..." diffs the working tree against where this branch forked,
            -- so uncommitted work shows and commits that landed on base since
            -- do not. -C pins it to the cwd: otherwise it uses the current
            -- buffer's repo, which after <leader>gw is still the old worktree,
            -- and the diff comes up empty.
            if base then
              local cwd = vim.fn.fnameescape(vim.fn.getcwd())
              vim.cmd("CodeDiff -C " .. cwd .. " " .. base .. "...")
            end
          end)
        end,
        desc = "Diff against base branch",
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
              vim.cmd.cd(path)
              vim.notify("cwd: " .. vim.fn.fnamemodify(path, ":~"))
            end
          end)
        end,
        desc = "Switch worktree",
      },
    },
  },
}
