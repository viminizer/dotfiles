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
    -- Default is "NC", whose top edge is a blank cell coloured by
    -- NeoTreeTitleBar rather than a border character. Transparency strips that
    -- background, leaving the float with no visible top. Rounded also matches
    -- every other border in this config.
    popup_border_style = "rounded",
    filesystem = {
      group_empty_dirs = true,
    },
    window = {
      popup = {
        size = { width = "80%", height = "80%" },
        position = "50%",
      },
      mappings = {
        -- Replaces neo-tree's "order by" submenu (oc, od, og, ...). nowait so
        -- it fires instead of waiting to see if one of those follows.
        ["o"] = {
          function(state)
            vim.ui.open(state.tree:get_node().path)
          end,
          desc = "open with system app",
          nowait = true,
        },
      },
    },
  },
}
