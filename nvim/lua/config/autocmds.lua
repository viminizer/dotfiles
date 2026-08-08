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

-- Hard-wrap prose only. A global textwidth breaks code comments mid-line,
-- because nvim's default formatoptions includes `t` and `c`.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.textwidth = 100
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
