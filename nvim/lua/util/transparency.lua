local M = {}

function M.apply()
  vim.cmd([[
    highlight NeoTreeNormal guibg=none ctermbg=none
    highlight NeoTreeNormalNC guibg=none ctermbg=none
    highlight NeoTreeEndOfBuffer guibg=none ctermbg=none
    highlight NeoTreeWinSeparator guifg=#ff000f guibg=none
    highlight NeoTreeFloatNormal guibg=none ctermbg=none
    highlight NeoTreeFloatBorder guifg=#ff000f guibg=none
    highlight NeoTreeFloatTitle guifg=#ff000f guibg=none
    highlight NeoTreeTitleBar guifg=#ff000f guibg=none
    highlight minitablinecurrent guifg=#ff000f guibg=none
    highlight minitablinemodifiedcurrent guibg=none guifg=red
    highlight minitablinefill guibg=none
    highlight NoiceCmdlinePopup guibg=none ctermbg=none
    highlight NoiceCmdlinePopupBorder guifg=#ff000f guibg=none
    highlight NoiceCmdlinePopupTitle guifg=#ff000f guibg=none
    highlight NoicePopup guibg=none ctermbg=none
    highlight NoicePopupBorder guifg=#ff000f guibg=none
    highlight NoicePopupmenu guibg=none ctermbg=none
    highlight NoicePopupmenuBorder guifg=#ff000f guibg=none
    highlight NoicePopupmenuSelected guibg=#002a3a
    highlight NoiceCmdline guibg=none ctermbg=none
    highlight NoiceMini guibg=none ctermbg=none
    highlight NoiceFormatProgressTodo guibg=none ctermbg=none
    highlight NoiceFormatProgressDone guibg=none ctermbg=none
    highlight Pmenu guibg=none ctermbg=none
    highlight PmenuSel guibg=#002a3a
    highlight PmenuBorder guifg=#ff000f guibg=none
    highlight normal guibg=none ctermbg=none guifg=#ffa500
    highlight linenr guibg=none ctermbg=none
    highlight cursorlinenr guibg=none ctermbg=none
    highlight signcolumn guibg=none ctermbg=none
    highlight foldcolumn guibg=none ctermbg=none
    highlight normalfloat guibg=none ctermbg=none
    highlight floatborder guibg=none ctermbg=none guifg=#ff000f
    highlight floattitle guibg=none ctermbg=none guifg=#ff000f
    highlight visual guibg=#002a3a guifg=#fffaf3
    highlight LazyNormal guibg=none ctermbg=none
    highlight LazyBackdrop guibg=none ctermbg=none
    highlight LazyBorder guifg=#ff000f guibg=none
    highlight SnacksNormal guibg=none ctermbg=none
    highlight SnacksBackdrop guibg=none ctermbg=none
    highlight SnacksPicker guibg=none ctermbg=none
    highlight SnacksPickerBorder guifg=#ff000f guibg=none
    highlight SnacksPickerTitle guifg=#ff000f guibg=none
    highlight SnacksPickerInput guibg=none ctermbg=none
    highlight SnacksPickerInputBorder guifg=#ff000f guibg=none
    highlight SnacksPickerList guibg=none ctermbg=none
    highlight SnacksPickerListBorder guifg=#ff000f guibg=none
    highlight SnacksPickerPreview guibg=none ctermbg=none
    highlight SnacksPickerPreviewBorder guifg=#ff000f guibg=none
    highlight SnacksExplorer guibg=none ctermbg=none
    highlight SnacksExplorerNormal guibg=none ctermbg=none
    highlight SnacksExplorerBorder guifg=#ff000f guibg=none
    highlight SnacksExplorerTitle guifg=#ff000f guibg=none
    highlight SnacksWinBar guibg=none ctermbg=none
    highlight SnacksDashboard guibg=none ctermbg=none
    highlight NormalSB guibg=none ctermbg=none
    highlight NormalNC guibg=none ctermbg=none
    highlight WinBar guibg=none ctermbg=none
    highlight WinBarNC guibg=none ctermbg=none
    highlight TreesitterContext guibg=none ctermbg=none
    highlight BlinkCmpMenu guibg=none ctermbg=none
    highlight BlinkCmpMenuBorder guifg=#ff000f guibg=none ctermbg=none
    highlight BlinkCmpDoc guibg=none ctermbg=none
    highlight BlinkCmpDocBorder guifg=#ff000f guibg=none ctermbg=none
    highlight BlinkCmpDocSeparator guifg=#ff000f guibg=none ctermbg=none
    highlight BlinkCmpSignatureHelp guibg=none ctermbg=none
    highlight BlinkCmpSignatureHelpBorder guifg=#ff000f guibg=none ctermbg=none
  ]])
end

return M
