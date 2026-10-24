return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  init = function()
    -- Neo-tree is the explorer in this config; netrw is disabled.
    vim.g.git_worktree = { update_on_change_command = "enew", autopush = false }
  end,
  config = function()
    local hooks = require("git-worktree.hooks")
    hooks.register(hooks.type.SWITCH, function(path, prev_path)
      vim.g.worktree_root = vim.fn.getcwd()
      LazyVim.root.cache = {}
      hooks.builtins.update_current_buffer_on_switch(path, prev_path)

      -- Keep editing the corresponding file, or browse the new worktree if
      -- that file doesn't exist there (including switches from the dashboard).
      if vim.api.nvim_buf_get_name(0) == "" then
        require("neo-tree.command").execute({
          action = "focus",
          source = "filesystem",
          position = "float",
          dir = vim.g.worktree_root,
        })
      end
    end)
    require("telescope").load_extension("git_worktree")
  end,
  keys = {
    {
      "<leader>gT",
      function()
        require("telescope").extensions.git_worktree.git_worktree()
      end,
      desc = "Switch Git Worktree (Telescope)",
    },
  },
}
