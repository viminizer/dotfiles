-- neo-tree overrides on top of LazyVim's editor.neo-tree extra.
--
-- The reason for picking neo-tree over the snacks explorer: group_empty_dirs
-- collapses a chain of single-child directories onto one line, so a Java
-- package reads as src/test/java/org/apache/shardingsphere instead of five
-- rows of indent. Neither snacks nor mini.files can do that.
return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    -- LazyVim binds <leader>e to the sidebar. A sidebar is what made deep
    -- package trees unreadable in the first place, so open a wide popup.
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, position = "float", dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (float, root dir)",
    },
  },
  opts = {
    filesystem = {
      group_empty_dirs = true,
    },
    window = {
      popup = {
        size = { width = "80%", height = "80%" },
        position = "50%",
      },
    },
  },
}
