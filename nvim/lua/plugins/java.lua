-- jdtls tuning for large multi-module Maven repos (e.g. shardingsphere: 435 modules)

-- Format with the project's own Eclipse profile when it ships one. Otherwise
-- jdtls formats to Eclipse defaults, so saving rewrites lines nobody touched
-- and the real change disappears into the diff. Apache projects using spotless
-- keep the profile at src/resources/spotless/java.xml; pointing jdtls at that
-- exact file makes format-on-save agree with `mvn spotless:apply`.
local function eclipse_profile()
  local root = vim.fs.root(vim.fn.getcwd(), { ".git" }) or vim.fn.getcwd()
  local path = root .. "/src/resources/spotless/java.xml"
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(path)) do
    local name = line:match('<profile[^>]-name="([^"]*)"')
    if name then
      return { url = path, profile = name }
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    -- lspconfig's jdtls builds its --jvm-arg list from os.getenv('JDTLS_JVM_ARGS'),
    -- reading nvim's own environment before the server is spawned. Setting this
    -- via cmd_env is too late: that only reaches the child process.
    init = function()
      -- ActiveProcessorCount caps how many cores jdtls floods at once. Opening
      -- this repo costs ~7 CPU-minutes either way (38MB of generated ANTLR
      -- parsers, unavoidable), but spreading it over 4 cores instead of 9 is
      -- the difference between an audible fan and a quiet one.
      vim.env.JDTLS_JVM_ARGS =
        "-Xms256m -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:ActiveProcessorCount=4"

      -- No format-on-save for Java. jdtls and the project's spotless profile
      -- are two different Eclipse formatter builds, so saving rewrites lines
      -- nobody touched and buries the real change in the diff. Format with
      -- `./mvnw spotless:apply -Pcheck`, which is what CI checks against.
      -- <leader>uf re-enables it for the current buffer.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        group = vim.api.nvim_create_augroup("JavaNoAutoformat", { clear = true }),
        callback = function()
          vim.b.autoformat = false
          -- Java convention is 4, and nvim sends shiftwidth as the LSP
          -- tabSize, which jdtls honours over the formatter profile.
          vim.opt_local.shiftwidth = 4
          vim.opt_local.tabstop = 4
          vim.opt_local.softtabstop = 4
        end,
      })
    end,
    opts = {
      servers = {
        jdtls = {
          -- nvim otherwise kills the server the instant it sends shutdown, so
          -- jdtls dies mid-write and logs failed index saves every time. This
          -- costs the full duration on every quit: lsp.lua's
          -- check_clients_closed polls a snapshot that never shrinks, so
          -- vim.wait always runs to the deadline rather than exiting early.
          -- Drop to 0 if the pause on :qa is more annoying than it is worth.
          flags = { exit_timeout = 2000 },
          settings = {
            java = {
              autobuild = { enabled = false },
              maxConcurrentBuilds = 1,
              import = {
                exclusions = {
                  "**/target/**",
                  "**/build/**",
                  "**/graphify-out/**",
                  "**/node_modules/**",
                  "**/.git/**",
                },
                maven = { offline = { enabled = true } },
              },
              maven = { downloadSources = false },
              eclipse = { downloadSources = false },
              references = { includeDecompiledSources = false },
              referencesCodeLens = { enabled = false },
              implementationsCodeLens = { enabled = false },
              completion = { maxResults = 50 },
              configuration = { updateBuildConfiguration = "disabled" },
              format = { settings = eclipse_profile() },
            },
          },
        },
      },
    },
  },
  -- nvim-jdtls is unused: jdtls runs through nvim-lspconfig + mason-lspconfig
  { "mfussenegger/nvim-jdtls", enabled = false },
}
