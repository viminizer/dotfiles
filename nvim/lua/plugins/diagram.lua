-- Setup:
-- brew install imagemagick
-- npm install -g @mermaid-js/mermaid-cli

return {
  {
    "3rd/image.nvim",
    build = false,
    lazy = true, -- loaded by diagram.nvim on markdown; nothing else needs it at startup
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      tmux_show_only_in_active_window = true,
      max_height_window_percentage = 100,
      scale_factor = 2.0,
    },
  },
  {
    "3rd/diagram.nvim",
    dependencies = { "3rd/image.nvim" },
    ft = { "markdown" },
    opts = {
      events = {
        render_buffer = {},
        clear_buffer = { "BufLeave" },
      },
      renderer_options = {
        mermaid = {
          scale = 10,
          theme = "dark",
          background = "transparent",
        },
      },
    },
    keys = {
      {
        "<leader>cd",
        function()
          require("diagram").show_diagram_hover()
        end,
        desc = "Show diagram",
        ft = { "markdown" },
      },
    },
  },
}
