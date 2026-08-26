-- Options are automatically loaded before lazy.nvim startup

-- Root detection, used by every picker, the explorer and the root-dir terminal.
-- Always the folder nvim was launched in - never a parent, never $HOME.
--
-- LazyVim's default spec walks *upward* from the current file for markers like
-- .git or lua, so opening a file in a non-git project (or the dashboard, which
-- has no file at all) would land on some ancestor and search far too much. The
-- ~/lua symlink made that ancestor $HOME. Reading the cwd once, here, pins it:
-- this file runs before lazy.nvim starts, so it is the launch directory, and a
-- later :cd or a buffer from another project can't move it.
local launch_dir = vim.fn.getcwd()
vim.g.root_spec = {
  function()
    return launch_dir
  end,
}

-- Only options that differ from the LazyVim/nvim defaults belong here.
vim.opt.breakindent = true
vim.opt.wrap = true -- LazyVim disables wrap
vim.opt.autowriteall = true -- LazyVim sets autowrite; this also writes on :bnext, :make, etc.
vim.opt.softtabstop = 2
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:hor25,r-cr-o:hor20"
vim.opt.inccommand = "split" -- LazyVim uses "nosplit"
vim.opt.scrolloff = 8 -- LazyVim uses 4
vim.opt.concealcursor = "nc"
vim.opt.updatetime = 500 -- CursorHold delay; below ~500 the CursorHold autocmds below poll too hard
-- textwidth is set per-filetype in config/autocmds.lua, not globally.
-- Diagnostic display lives in plugins/lsp.lua under nvim-lspconfig's `diagnostics` opts.
-- Setting it here does nothing: LazyVim replaces the whole config when lspconfig loads.

-- Every logged LSP message is a synchronous write; this file had grown to 326MB.
-- Set to "debug" temporarily when you actually need to debug a language server.
vim.lsp.set_log_level("off")

-- Automatically open floating diagnostics on cursor hold
local diag_float_grp = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })
vim.api.nvim_create_autocmd("CursorHold", {
  group = diag_float_grp,
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
  end,
})

-- Global border for all floating windows
local border = "rounded"
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
