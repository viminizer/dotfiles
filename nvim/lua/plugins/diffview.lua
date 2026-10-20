local function compare_branch()
  local root = LazyVim.root.git() or vim.fn.getcwd()
  local result = vim.system({
    "git",
    "-C",
    root,
    "for-each-ref",
    "--sort=refname",
    "--format=%(refname:short)",
    "refs/heads",
    "refs/remotes",
  }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR, { title = "Diffview" })
    return
  end
  local branches = vim.tbl_filter(function(branch)
    return not branch:match("/HEAD$")
  end, vim.split(result.stdout, "\n", { trimempty = true }))
  vim.ui.select(branches, { prompt = "Compare HEAD against base branch:" }, function(base)
    if base then
      -- Three dots shows committed branch changes since the common ancestor,
      -- like a PR/MR comparison, without mixing in uncommitted edits.
      require("diffview").open({ base .. "...HEAD", "-C=" .. root })
    end
  end)
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  opts = {
    enhanced_diff_hl = true,
    view = { default = { layout = "diff2_horizontal" } },
    file_panel = { win_config = { width = 35 } },
  },
  keys = {
    { "<leader>gD", compare_branch, desc = "Diff Branch Against Base (Diffview)" },
    { "<leader>gV", "<cmd>DiffviewOpen<cr>", desc = "Diff Local Changes (Diffview)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch File History (Diffview)" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
  },
}
