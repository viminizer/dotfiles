vim.keymap.set("i", ";;", "<Esc>o", { desc = "Insert new line below" })
vim.keymap.set("i", "kk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer({ cwd = vim.fn.getcwd() })
end, { desc = "Explorer (cwd)" })
vim.keymap.set("n", "<leader>cy", function()
  local msg = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
  if msg then
    vim.fn.setreg("+", msg.message)
    print("Copied diagnostic to clipboard")
  else
    print("No diagnostic on this line")
  end
end, { desc = "Copy Diagnostic Message" })
