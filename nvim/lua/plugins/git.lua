-- Diffview for reviewing a branch, plus a worktree switcher. Both pick from a
-- list through vim.ui.select, which LazyVim routes to the snacks picker.
local function git_lines(args)
  return vim.fn.systemlist(vim.list_extend({ "git" }, args))
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gD",
        function()
          -- origin/HEAD is an alias for another branch, so it only adds noise.
          local branches = vim.tbl_filter(function(b)
            return not b:match("/HEAD$")
          end, git_lines({ "branch", "-a", "--format=%(refname:lstrip=2)" }))
          vim.ui.select(branches, { prompt = "Base branch" }, function(base)
            -- Triple-dot diffs from where this branch forked, so commits that
            -- landed on base since then do not show up as changes here.
            -- --imply-local puts real files on the right, so uncommitted work
            -- shows and LSP still works. -C pins it to the cwd: diffview
            -- otherwise uses the current buffer's repo, which after <leader>gw
            -- is still the old worktree, and the diff comes up empty.
            if base then
              local cwd = vim.fn.fnameescape(vim.fn.getcwd())
              vim.cmd("DiffviewOpen -C" .. cwd .. " " .. base .. "...HEAD --imply-local")
            end
          end)
        end,
        desc = "Diff against base branch",
      },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      -- LazyVim's snacks extra binds this to a diff picker; diffview owns it.
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
