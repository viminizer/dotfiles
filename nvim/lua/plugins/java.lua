-- jdtls tuning for large multi-module Maven repos (e.g. shardingsphere: 435 modules)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {
          -- lspconfig's jdtls reads extra JVM args from this env var and keeps its own -data dir
          cmd_env = { JDTLS_JVM_ARGS = "-Xms256m -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=100" },
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
            },
          },
        },
      },
    },
  },
  -- nvim-jdtls is unused: jdtls runs through nvim-lspconfig + mason-lspconfig
  { "mfussenegger/nvim-jdtls", enabled = false },
}
