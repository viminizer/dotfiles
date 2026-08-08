local M = {}

function M.apply()
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
    highlight NoiceMini guibg=none ctermbg=none
    highlight NoiceFormatProgressTodo guibg=none ctermbg=none
    highlight NoiceFormatProgressDone guibg=none ctermbg=none
    highlight Pmenu guibg=none ctermbg=none
    highlight PmenuSel guibg=#3b4252
    highlight PmenuBorder guifg=#ffa500 guibg=none
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
    highlight SnacksExplorer guibg=none ctermbg=none
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
    highlight BlinkCmpMenu guibg=none ctermbg=none
    highlight BlinkCmpMenuBorder guifg=#ffa500 guibg=none ctermbg=none
    highlight BlinkCmpDoc guibg=none ctermbg=none
    highlight BlinkCmpDocBorder guifg=#ffa500 guibg=none ctermbg=none
    highlight BlinkCmpDocSeparator guifg=#ffa500 guibg=none ctermbg=none
    highlight BlinkCmpSignatureHelp guibg=none ctermbg=none
    highlight BlinkCmpSignatureHelpBorder guifg=#ffa500 guibg=none ctermbg=none
  ]])
end

return M
