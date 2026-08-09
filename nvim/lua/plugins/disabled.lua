-- Plugins LazyVim installs by default that this config does not use.
return {
  -- Colorschemes. carbonfox (nightfox) is set in colorscheme.lua, and LazyVim
  -- falls back to the built-in habamax if that ever fails to load, so neither of
  -- these is reachable.
  { "catppuccin/nvim", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },

  -- Browser markdown preview, pulled in by LazyVim's lang.markdown extra rather
  -- than chosen. markview renders markdown in the buffer, and <leader>cP opens
  -- the current file in a browser, so the node build it needs pays for nothing.
  { "iamcco/markdown-preview.nvim", enabled = false },
}
