-- Set working directory to the director Neovim was opened with
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd.cd(arg)
    end
  end,
})

--iAuto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.env", "*.env.*" },
  callback = function()
    vim.b.autoformat = false
    vim.diagnostic.enable(false, { bufnr = 0 })
  end,
})

-- Keep informal scratch notes quiet without changing Markdown in projects.
local scratchpad = vim.fn.expand("~/notes/scratch.md")
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("QuietScratchpad", { clear = true }),
  pattern = scratchpad,
  callback = function(args)
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})
-- LazyVim may load this file after the initial buffer's read/enter events.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_get_name(buf) == scratchpad then
    vim.diagnostic.enable(false, { bufnr = buf })
  end
end

-- Hard-wrap prose only. A global textwidth breaks code comments mid-line,
-- because nvim's default formatoptions includes `t` and `c`.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.textwidth = 100
  end,
})

-- LazyVim turns wrap on for markdown, and markview then skips its table pipe
-- rendering entirely (renderers/markdown.lua:1542, "BUG, wrap breaks table
-- rendering"), leaving tables as raw ASCII inside drawn borders. This has to
-- live here rather than in the markview spec's init: autocmds on the same event
-- fire in registration order, and LazyVim's lazyvim_wrap_spell registers after
-- plugin init but before this file. <leader>uw toggles wrap back on.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = false
  end,
})

-- Force transparent background for Lazy and Snacks windows
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lazy", "snacks_explorer", "snacks_picker", "snacks_input", "snacks_win" },
  callback = function()
    vim.opt_local.winblend = 0
    vim.wo.winhighlight = "Normal:Normal,NormalNC:Normal,NormalSB:Normal,NormalFloat:Normal"
  end,
})

-- Also handle by buffer name pattern for snacks explorer
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match("snacks") or vim.bo.filetype:match("snacks") then
      vim.wo.winhighlight = "Normal:Normal,NormalNC:Normal,NormalSB:Normal,NormalFloat:Normal"
    end
  end,
})
