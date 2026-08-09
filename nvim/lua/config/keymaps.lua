vim.keymap.set("i", ";;", "<Esc>o", { desc = "Insert new line below" })

-- Open the current file in the default browser. Mainly for HTML: the generated
-- diagram pages depend on CDN fonts, Chart.js and mermaid, so nothing rendered
-- inside the terminal would resemble them.
vim.keymap.set("n", "<leader>cP", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return
  end
  vim.ui.open(file)
end, { desc = "Open File in Browser" })

vim.keymap.set("n", "<leader>cy", function()
  local msg = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
  if msg then
    vim.fn.setreg("+", msg.message)
    print("Copied diagnostic to clipboard")
  else
    print("No diagnostic on this line")
  end
end, { desc = "Copy Diagnostic Message" })
