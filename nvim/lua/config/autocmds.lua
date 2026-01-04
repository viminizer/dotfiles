--iAuto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.env" },
  callback = function()
    vim.b.autoformat = false
    vim.diagnostic.enable(false, {})
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "dotenv" },
  callback = function()
    vim.b.autoformat = false
    vim.diagnostic.enable(false, {})
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "*.env" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd("colorscheme", {
  pattern = "*",
  callback = function()
    vim.cmd([[
      highlight minifilesnormal guibg=none ctermbg=none
      highlight minifilesborder guifg=#ffa500 guibg=none
      highlight minifilestitle guifg=#ffa500 guibg=none
      highlight minifilestitlefocused guifg=#ffa500 guibg=none
      highlight minitablinecurrent guifg=#ffa500 guibg=none
      highlight minitablinemodifiedcurrent guibg=none guifg=red
      highlight minitablinefill guibg=none
      highlight NoiceCmdlinePopup guibg=none ctermbg=none
      highlight NoiceCmdlinePopupBorder guifg=#ffa500 guibg=none
      highlight NoiceCmdlinePopupTitle guifg=#ffa500 guibg=none
      highlight NoicePopup guibg=none ctermbg=none
      highlight NoicePopupBorder guifg=#ffa500 guibg=none
      highlight NoicePopupmenu guibg=none ctermbg=none
      highlight NoicePopupmenuBorder guifg=#ffa500 guibg=none
      highlight NoicePopupmenuSelected guibg=#3b4252
      highlight NoiceCmdline guibg=none ctermbg=none
      highlight Pmenu guibg=none ctermbg=none
      highlight PmenuSel guibg=#3b4252
      highlight PmenuBorder guifg=#ffa500 guibg=none
      highlight CmpItemMenu guibg=none ctermbg=none
      highlight CmpPmenu guibg=none ctermbg=none
      highlight normal guibg=none ctermbg=none guifg=#ffa500
      highlight linenr guibg=none ctermbg=none
      highlight cursorlinenr guibg=none ctermbg=none
      highlight signcolumn guibg=none ctermbg=none
      highlight foldcolumn guibg=none ctermbg=none
      highlight normalfloat guibg=none ctermbg=none
      highlight floatborder guibg=none ctermbg=none guifg=#ffa500
      highlight floattitle guibg=none ctermbg=none guifg=#ffa500
      highlight visual guibg=#3b4252 guifg=#ffa500
      highlight LazyNormal guibg=none ctermbg=none
      highlight LazyBackdrop guibg=none ctermbg=none
      highlight LazyBorder guifg=#ffa500 guibg=none
      highlight SnacksNormal guibg=none ctermbg=none
      highlight SnacksBackdrop guibg=none ctermbg=none
      highlight SnacksPicker guibg=none ctermbg=none
      highlight SnacksPickerBorder guifg=#ffa500 guibg=none
      highlight SnacksPickerTitle guifg=#ffa500 guibg=none
      highlight SnacksPickerInput guibg=none ctermbg=none
      highlight SnacksPickerInputBorder guifg=#ffa500 guibg=none
      highlight SnacksPickerList guibg=none ctermbg=none
      highlight SnacksPickerListBorder guifg=#ffa500 guibg=none
      highlight SnacksPickerPreview guibg=none ctermbg=none
      highlight SnacksPickerPreviewBorder guifg=#ffa500 guibg=none
      highlight SnacksExplorerNormal guibg=none ctermbg=none
      highlight SnacksExplorerBorder guifg=#ffa500 guibg=none
      highlight SnacksExplorerTitle guifg=#ffa500 guibg=none
      highlight SnacksWinBar guibg=none ctermbg=none
      highlight SnacksDashboard guibg=none ctermbg=none
      highlight NormalSB guibg=none ctermbg=none
      highlight NormalNC guibg=none ctermbg=none
      highlight WinBar guibg=none ctermbg=none
      highlight WinBarNC guibg=none ctermbg=none
      highlight TreesitterContext guibg=none ctermbg=none
      highlight SnacksExplorer guibg=none ctermbg=none
      ]])
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
