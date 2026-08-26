-- Teach mode: one toggle that reshapes the editor for a live class and puts it
-- back afterwards. Everything it turns on is off during normal editing, so the
-- daily config stays fast and quiet.
--
-- Deliberately not touched: kitty's background_opacity / background_blur.
--
-- What it changes:
--   * inlay hints on, so inferred types are visible without hovering
--   * codelens on, so reference and implementation counts show above symbols
--   * checkJs + strict for .js files outside a tsconfig, so a JS lesson can
--     show real type errors before TypeScript is introduced
--   * absolute line numbers, so "look at line 42" means something
--   * a block cursor, which is far easier to follow on a recording
--   * the CursorHold diagnostic float off, so it stops covering the code
--   * the font size up, because 16pt is unreadable on a projector
--   * keystrokes on screen, so nobody has to ask what you just pressed
local M = {}

-- Font size while teaching. kitty.conf sets 16 for daily use.
local FONT_SIZE = 21

local AUGROUP = "TeachMode"

---Run a kitty remote-control command. No-op outside kitty.
---@param args string[]
local function kitty(args)
  local socket = vim.env.KITTY_LISTEN_ON
  if not socket then
    return
  end
  local cmd = { "kitty", "@", "--to", socket }
  vim.list_extend(cmd, args)
  vim.system(cmd, { text = true })
end

---@param on boolean
local function inlay_hints(on)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
      pcall(vim.lsp.inlay_hint.enable, on, { bufnr = buf })
    end
  end
end

---@param on boolean
local function codelens(on)
  if on then
    pcall(vim.lsp.codelens.refresh, { bufnr = 0 })
  else
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        pcall(vim.lsp.codelens.clear, nil, buf)
      end
    end
  end
end

-- Pushed to vtsls at runtime rather than living in plugins/lsp.lua, because
-- implicitProjectConfig applies to every .js file that is not part of a
-- tsconfig project. Always-on, that lights up unrelated config files and
-- one-off scripts with errors nobody asked for.
---@param on boolean
local function js_strictness(on)
  local settings = {
    ["js/ts"] = {
      implicitProjectConfig = {
        checkJs = on,
        strict = on,
        strictNullChecks = on,
      },
    },
  }
  for _, client in ipairs(vim.lsp.get_clients({ name = "vtsls" })) do
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, settings)
    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
end

---@param on boolean
local function autocmds(on)
  if not on then
    pcall(vim.api.nvim_del_augroup_by_name, AUGROUP)
    return
  end
  local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })
  -- Buffers opened while teach mode is already on still get the treatment.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= "" then
        return
      end
      pcall(vim.lsp.inlay_hint.enable, true, { bufnr = args.buf })
      pcall(vim.lsp.codelens.refresh, { bufnr = args.buf })
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
    group = group,
    callback = function(args)
      pcall(vim.lsp.codelens.refresh, { bufnr = args.buf })
    end,
  })
end

function M.is_enabled()
  return vim.g.teach_mode == true
end

---@param on boolean
function M.set(on)
  -- Read by the CursorHold diagnostic float in config/options.lua and by the
  -- lualine indicator, so it has to be set before anything else runs.
  vim.g.teach_mode = on

  vim.opt.relativenumber = not on
  vim.opt.number = true
  -- A blinking block in insert mode. The daily `hor25` underline is nearly
  -- invisible once the video is scaled down. cursorline is left alone: LazyVim
  -- already has it on, so teach mode has nothing to add and turning it off on
  -- the way out would be a regression.
  vim.opt.guicursor = on and "n-v-c-sm:block,i-ci-ve:block-blinkwait300-blinkon500-blinkoff500,r-cr-o:block"
    or "n-v-c-sm:block,i-ci-ve:hor25,r-cr-o:hor20"

  inlay_hints(on)
  codelens(on)
  js_strictness(on)
  autocmds(on)

  -- 0 means "back to whatever kitty.conf says", so the daily size is never
  -- hardcoded in two places.
  kitty({ "set-font-size", on and tostring(FONT_SIZE) or "0" })

  -- showkeys only offers a toggle, no explicit on/off. Teach mode is the only
  -- thing that drives it and it starts hidden, so one call per transition
  -- keeps the two in step.
  pcall(vim.cmd, "ShowkeysToggle")

  vim.notify(on and "Teach mode on" or "Teach mode off", vim.log.levels.INFO)
end

function M.toggle()
  M.set(not M.is_enabled())
end

return M
