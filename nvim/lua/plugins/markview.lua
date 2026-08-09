-- markview replaces render-markdown as the in-buffer markdown renderer.
--
-- Both render-markdown specs are disabled below. LazyVim's markdown extra ships
-- one, and this config used to add a second under the plugin's old repo name
-- (MeanderingProgrammer/markdown.nvim), so lazy.nvim installed it twice and both
-- copies drew extmarks on the same buffer.
return {
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
  { "MeanderingProgrammer/markdown.nvim", enabled = false },
  {
    "OXY2DEV/markview.nvim",
    -- markview decides for itself which buffers to attach to, so ft-based lazy
    -- loading makes it miss the buffer nvim was opened with. Author's advice.
    lazy = false,
    opts = {
      preview = {
        -- Default is { "n", "no", "c" }, which unrenders the whole buffer the
        -- moment you enter insert mode. Adding "i" plus hybrid mode keeps the
        -- buffer rendered and shows raw markdown only on the cursor line - the
        -- behaviour render-markdown got from anti_conceal.
        modes = { "n", "no", "c", "i" },
        hybrid_modes = { "n", "i" },
      },
    },
    keys = {
      { "<leader>um", "<cmd>Markview toggle<cr>", desc = "Toggle Markview" },
    },
  },
}
