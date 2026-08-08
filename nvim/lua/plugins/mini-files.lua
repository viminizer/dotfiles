-- mini.files, bounded to the project root.
--
-- MiniFiles.go_out() escapes the project only in one case: when depth_focus is
-- 1 it calls explorer_open_root_parent() and prepends the parent directory.
-- At any other depth it just shifts focus left inside the existing branch,
-- which is fine. So the guard only has to block that first case.
return {
  "nvim-mini/mini.files",
  init = function()
    local function root()
      return vim.fs.normalize(vim.fn.getcwd())
    end

    local function is_within(path, base)
      path = vim.fs.normalize(path)
      return path == base or path:sub(1, #base + 1) == base .. "/"
    end

    -- True when going out would land outside the project root.
    local function would_escape()
      local state = MiniFiles.get_explorer_state()
      if not state or state.depth_focus ~= 1 then
        return false
      end
      local leftmost = state.branch[1]
      return not leftmost or not is_within(vim.fs.dirname(leftmost), root())
    end

    local function go_out()
      if would_escape() then
        return vim.notify("Already at project root", vim.log.levels.INFO)
      end
      MiniFiles.go_out()
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      group = vim.api.nvim_create_augroup("MiniFilesRootBound", { clear = true }),
      callback = function(args)
        local buf = args.data.buf_id
        vim.keymap.set("n", "h", go_out, { buffer = buf, desc = "Go out (stops at project root)" })
        vim.keymap.set("n", "H", function()
          go_out()
          MiniFiles.trim_right()
        end, { buffer = buf, desc = "Go out plus (stops at project root)" })
      end,
    })
  end,
}
