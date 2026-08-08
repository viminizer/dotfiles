vim.keymap.set("i", ";;", "<Esc>o", { desc = "Insert new line below" })
-- Floating explorer. The sidebar layout is capped at 40 columns, which deep
-- Java package trees outgrow. This trades the sidebar for a wide centred
-- popup; <leader>E is still LazyVim's sidebar explorer at cwd.
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer({
    cwd = vim.fn.getcwd(),
    layout = { preset = "default", preview = false },
    auto_close = true,
  })
end, { desc = "Explorer (float, cwd)" })
vim.keymap.set("n", "<leader>cy", function()
  local msg = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
  if msg then
    vim.fn.setreg("+", msg.message)
    print("Copied diagnostic to clipboard")
  else
    print("No diagnostic on this line")
  end
end, { desc = "Copy Diagnostic Message" })
