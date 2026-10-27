-- Peek a definition in a float under the cursor, without leaving the buffer.
-- gl was free: Yanky owns gp/gP, and only neo-tree and lazy use gl in their own windows.
return {
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    keys = {
      { "gl", "<cmd>Glance definitions<cr>", desc = "Peek Definition" },
    },
    opts = {},
  },
}
