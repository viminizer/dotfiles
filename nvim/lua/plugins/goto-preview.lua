-- Peek a definition in a float, without leaving the buffer.
-- gl was free: Yanky owns gp/gP, and only neo-tree and lazy use gl in their own windows.
return {
  {
    "rmagatti/goto-preview",
    keys = {
      {
        "gl",
        function()
          -- Sized on each open, so it follows the terminal size.
          require("goto-preview").goto_preview_definition({
            width = math.floor(vim.o.columns * 0.6),
            height = math.floor(vim.o.lines * 0.6),
          })
        end,
        desc = "Peek Definition",
      },
    },
    -- Long lines wrap (wrap is on in config/options.lua), long functions scroll.
    opts = {
      border = "rounded",
      -- The float shows the real file buffer, so q is mapped only while it is
      -- open, and removed on close so q records macros there again.
      post_open_hook = function(buf, win)
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, false)
        end, { buffer = buf, desc = "Close Peek" })
      end,
      post_close_hook = function(buf)
        pcall(vim.keymap.del, "n", "q", { buffer = buf })
      end,
    },
  },
}
