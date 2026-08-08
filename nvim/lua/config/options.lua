-- Options are automatically loaded before lazy.nvim startup

-- Root detection patterns (used by file picker)
vim.g.root_spec = { "lsp", { ".git", "lua", "package.json", "Cargo.toml", "go.mod", "pom.xml" }, "cwd" }

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
