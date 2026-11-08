-- Native Windows only (viminizer branch). Handmade Hero style C/C++: MSVC's
-- cl.exe driven by a build.bat, debugging in the Visual Studio debugger.
--
-- Lives in plugins/ so lazy.nvim imports it while reading the spec, which is
-- before any plugin builds -- the MSVC environment has to exist by then.
if vim.fn.has("win32") == 0 then
  return {}
end

local vswhere = vim.fs.joinpath(vim.env["ProgramFiles(x86)"] or "", "Microsoft Visual Studio/Installer/vswhere.exe")

---@param property string
---@return string?
local function vs(property)
  if vim.fn.executable(vswhere) == 0 then
    return nil
  end
  local out = vim.trim(vim.system({ vswhere, "-latest", "-property", property }, { text = true }):wait().stdout or "")
  return out ~= "" and out or nil
end

-- What `vcvarsall.bat x64` sets -- Casey's shell.bat, done once per editor --
-- so build.bat finds cl.exe. It also gives nvim-treesitter its C compiler:
-- LazyVim looks for cl.exe only under "Program Files (x86)", and VS 2026
-- installs to "Program Files", so without this every parser build fails.
-- Cached, because vcvarsall takes a couple of seconds; :MsvcEnvRefresh after
-- a Visual Studio update.
local cache = vim.fs.joinpath(vim.fn.stdpath("cache"), "msvc-env.txt")

---@param refresh boolean
local function msvc_env(refresh)
  local lines
  if not refresh and vim.uv.fs_stat(cache) then
    lines = vim.fn.readfile(cache)
  else
    local root = vs("installationPath")
    if not root then
      return
    end
    local vcvars = root .. "\\VC\\Auxiliary\\Build\\vcvarsall.bat"
    local res = vim.system({ "cmd.exe", "/c", "call", vcvars, "x64", ">nul", "&&", "set" }, { text = true }):wait()
    if res.code ~= 0 then
      return
    end
    lines = vim.split(res.stdout or "", "\r?\n", { trimempty = true })
    vim.fn.mkdir(vim.fn.fnamemodify(cache, ":h"), "p")
    vim.fn.writefile(lines, cache)
  end

  -- Prepend only MSVC's PATH additions, so PATH changes made after the cache
  -- was written still show up.
  local current = {}
  for p in (vim.env.PATH or ""):gmatch("[^;]+") do
    current[p:lower()] = true
  end
  for _, line in ipairs(lines) do
    local key, val = line:match("^([^=]+)=(.*)$")
    if key and key:upper() == "PATH" then
      local added = {}
      for p in val:gmatch("[^;]+") do
        if not current[p:lower()] then
          table.insert(added, p)
        end
      end
      if #added > 0 then
        vim.env.PATH = table.concat(added, ";") .. ";" .. vim.env.PATH
      end
    elseif key then
      vim.env[key] = val
    end
  end
end

msvc_env(false)
vim.api.nvim_create_user_command("MsvcEnvRefresh", function()
  msvc_env(true)
  vim.notify("MSVC x64 environment reloaded")
end, { desc = "Re-run vcvarsall.bat x64 and reload its environment" })

---@return string? dir holding the nearest build.bat
local function build_root()
  local start = vim.fn.expand("%:p:h")
  if start == "" then
    start = vim.fn.getcwd()
  end
  local found = vim.fs.find("build.bat", { upward = true, path = start })[1]
  if not found then
    vim.notify("No build.bat in this folder or any parent", vim.log.levels.WARN)
    return nil
  end
  return vim.fs.dirname(found)
end

-- cl prints `path(12): error C2065: ...`. Keep -FC in build.bat so the path is
-- absolute; otherwise it is relative to wherever build.bat pushd'd to.
local msvc_efm = table.concat({
  "%f(%l\\,%c): %trror %m",
  "%f(%l\\,%c): %tarning %m",
  "%f(%l): fatal %trror %m",
  "%f(%l): %trror %m",
  "%f(%l): %tarning %m",
}, ",")

local function build()
  local root = build_root()
  if not root then
    return
  end
  vim.cmd("silent! wall")
  vim.notify("Building...", vim.log.levels.INFO, { title = "build.bat" })
  -- Explicit .\ -- cmd won't run a bare build.bat from the current directory
  -- when NoDefaultCurrentDirectoryInExePath is in effect.
  vim.system({ "cmd.exe", "/c", ".\\build.bat" }, { cwd = root, text = true }, vim.schedule_wrap(function(res)
    local out = (res.stdout or "") .. (res.stderr or "")
    local lines = vim.split(out, "\r?\n", { trimempty = true })
    vim.fn.setqflist({}, " ", { title = "build.bat", lines = lines, efm = msvc_efm })
    local errors, warnings = 0, 0
    for _, item in ipairs(vim.fn.getqflist()) do
      if item.valid == 1 then
        if item.type == "w" then
          warnings = warnings + 1
        else
          errors = errors + 1
        end
      end
    end
    if errors > 0 then
      vim.cmd("botright copen")
      vim.notify(("%d error(s), %d warning(s)"):format(errors, warnings), vim.log.levels.ERROR, { title = "build.bat" })
    else
      vim.cmd("cclose")
      vim.notify(("Build OK, %d warning(s)"):format(warnings), vim.log.levels.INFO, { title = "build.bat" })
    end
  end))
end

---@param root string
---@return string?
local function newest_exe(root)
  local best, best_time
  for _, dir in ipairs({ root .. "/build", root .. "/../build", root }) do
    for _, exe in ipairs(vim.fn.globpath(dir, "*.exe", true, true)) do
      local stat = vim.uv.fs_stat(exe)
      if stat and (not best_time or stat.mtime.sec > best_time) then
        best, best_time = exe, stat.mtime.sec
      end
    end
  end
  return best and vim.fs.normalize(best)
end

-- `devenv /debugexe`, the way Casey starts the debugger.
local function debug_in_vs()
  local root = build_root()
  if not root then
    return
  end
  local exe = newest_exe(root)
  if not exe then
    vim.notify("No .exe in build/ or ../build/ -- build first", vim.log.levels.WARN)
    return
  end
  local devenv = vs("productPath")
  if not devenv then
    vim.notify("Visual Studio (devenv.exe) not found", vim.log.levels.ERROR)
    return
  end
  vim.system({ devenv, "/debugexe", (exe:gsub("/", "\\")) }, { detach = true })
  vim.notify("Debugging " .. vim.fn.fnamemodify(exe, ":t") .. " in Visual Studio")
end

-- clangd knows nothing about a build.bat project's defines without this.
-- clangd finds the MSVC and Windows SDK headers on its own.
vim.api.nvim_create_user_command("CompileFlags", function()
  local root = build_root() or vim.fn.getcwd()
  local file = vim.fs.joinpath(root, "compile_flags.txt")
  if vim.uv.fs_stat(file) and vim.fn.confirm(file .. " exists. Overwrite?", "&Yes\n&No", 2) ~= 1 then
    return
  end
  vim.fn.writefile({
    "-xc++",
    "-std=c++17",
    "-DHANDMADE_WIN32=1",
    "-DHANDMADE_INTERNAL=1",
    "-DHANDMADE_SLOW=1",
    "-fms-extensions",
    "-fms-compatibility",
    "-Wno-writable-strings",
  }, file)
  vim.cmd.edit(file)
  vim.notify("Wrote compile_flags.txt. :LspRestart if clangd is running.")
end, { desc = "Write a clangd compile_flags.txt next to build.bat" })

-- Format C/C++ on save only where the project ships a .clang-format. Without
-- one clangd falls back to LLVM style and rewrites code nobody touched -- the
-- same rule lazyvim_prettier_needs_config applies to prettier.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  group = vim.api.nvim_create_augroup("ClangFormatNeedsConfig", { clear = true }),
  callback = function(args)
    local found = vim.fs.find({ ".clang-format", "_clang-format" }, {
      upward = true,
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
    })[1]
    if not found then
      vim.b[args.buf].autoformat = false
    end
  end,
})

vim.api.nvim_create_user_command("Build", build, { desc = "Run the nearest build.bat" })

vim.keymap.set("n", "<leader>cb", build, { desc = "Build (build.bat)" })
vim.keymap.set("n", "<leader>dV", debug_in_vs, { desc = "Debug in Visual Studio" })

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.clangd = opts.servers.clangd or {}
      -- LLVM's clangd from winget, not mason's: it finds the MSVC toolchain and
      -- Windows SDK headers by itself, so windows.h resolves with nothing more
      -- than a compile_flags.txt.
      opts.servers.clangd.mason = false
      -- Assigned, not merged: lists merge by index in tbl_deep_extend, which
      -- would leave the extra's longer cmd's tail behind.
      opts.servers.clangd.cmd = {
        "clangd",
        "--background-index",
        -- iwyu adds #includes on completion, which fights a unity build where
        -- one .cpp includes everything once.
        "--header-insertion=never",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      }
    end,
  },
}
