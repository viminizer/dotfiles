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

-- Teaching. <leader>t is a group of its own so nothing here collides with the
-- LazyVim defaults, which have already claimed most of <leader>u and <leader>c.
-- <leader>ti, tq and tQ are twoslash, bound in plugins/teaching.lua.
vim.keymap.set("n", "<leader>tt", function()
  require("util.teach").toggle()
end, { desc = "Teach Mode Toggle" })

vim.keymap.set("n", "<leader>tk", "<cmd>ShowkeysToggle<cr>", { desc = "Keystrokes Toggle" })

-- Course beats: one commit and one tag per beat in turnout, shortlist, pulse.
vim.keymap.set("n", "<leader>tb", function()
  require("util.course").pick()
end, { desc = "Beat Pick" })

vim.keymap.set("n", "<leader>tn", function()
  require("util.course").step(1)
end, { desc = "Beat Next" })

vim.keymap.set("n", "<leader>tp", function()
  require("util.course").step(-1)
end, { desc = "Beat Previous" })

vim.keymap.set("n", "<leader>td", function()
  require("util.course").diff()
end, { desc = "Beat Diff vs Previous" })

-- Run JS/TS in a tmux pane beside the editor.
vim.keymap.set("n", "<leader>tr", function()
  require("util.runner").run_buffer()
end, { desc = "Run Buffer" })

vim.keymap.set("x", "<leader>tr", function()
  -- Leave visual mode first: '< and '> only point at the selection once it
  -- has ended, and would otherwise still hold the previous one.
  vim.cmd("normal! \27")
  require("util.runner").run_selection()
end, { desc = "Run Selection" })

vim.keymap.set("n", "<leader>tR", function()
  require("util.runner").close()
end, { desc = "Run Pane Close" })
