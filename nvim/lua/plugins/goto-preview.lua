-- Peek a definition in a float, without leaving the buffer.
-- gl was free: Yanky owns gp/gP, and only neo-tree and lazy use gl in their own windows.
return {
  {
    "rmagatti/goto-preview",
    keys = {
      {
        "gl",
        function()
          require("goto-preview").goto_preview_definition()
        end,
        desc = "Peek Definition",
      },
    },
    -- Long lines wrap (wrap is on in config/options.lua), long functions scroll.
    opts = { width = 80, height = 20, border = "rounded" },
  },
}
