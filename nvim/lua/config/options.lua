-- Options are automatically loaded before lazy.nvim startup

-- Root detection patterns (used by file picker)
vim.g.root_spec = { "lsp", { ".git", "lua", "package.json", "Cargo.toml", "go.mod", "pom.xml" }, "cwd" }

vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.autowriteall = true -- Enable auto write
vim.opt.textwidth = 100
vim.opt.autoread = true -- Automatically read files when changed externally
vim.opt.updatetime = 200 -- Faster CursorHold for quicker file change detection
vim.opt.autoindent = true -- Enable autoindent
vim.opt.smartindent = true
vim.opt.tabstop = 2 -- Number of visual spaces per TAB
vim.opt.shiftwidth = 2 -- Indentation amount for autoindents
vim.opt.softtabstop = 2
vim.opt.expandtab = true -- Use tabs instead of spaces
vim.opt.smarttab = true
vim.opt.cursorline = true
vim.opt.undofile = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.inccommand = "split"
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"
vim.diagnostic.config({
  update_in_insert = true, -- Update diagnostics while typing
  underline = true,
  virtual_text = { spacing = 4, prefix = "●" },
  signs = true,
  severity_sort = true,
  float = {
    border = "rounded", -- Rounded corners for a clean look
    severity_sort = true, -- Sort the errors by severity (highest to lowest)
    max_width = 80, -- Set a maximum width for the floating window to avoid overflow
    max_height = 20, -- Set a maximum height to avoid the window becoming too large
  },
})

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
