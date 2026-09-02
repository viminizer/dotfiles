-- Kotlin. Not LazyVim's lang.kotlin extra, on purpose.
--
-- That extra wires up fwcd/kotlin-language-server, which is a community server
-- that resolves the classpath by shelling out to Gradle and gives up on
-- anything it cannot. JetBrains now ships `kotlin-lsp`, the same analysis
-- engine IntelliJ uses, so that is what this configures instead. The rest of
-- the extra -- ktlint, the treesitter parser, the debug adapter -- is
-- reproduced below, which is most of it and cheaper than importing the extra
-- and then switching the server back off.
--
-- Cost of the JetBrains server: the mason package is ~1.2GB, because it bundles
-- a JetBrains Runtime and the IntelliJ platform. Java 21 from the Brewfile is
-- not used by it, only by Gradle.

-- mason installs the package as `intellij-server`, not `kotlin-lsp`, so
-- nvim-lspconfig's default cmd of `kotlin-lsp --stdio` finds nothing on PATH.
-- mason-lspconfig does not rewrite cmd for this server, so it has to be spelled
-- out here or the server silently never attaches.
local kotlin_lsp = vim.fn.stdpath("data") .. "/mason/bin/intellij-server"

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Formatter and linter in one binary. Nothing else installs it: the
        -- server does not format, and mason-lspconfig only auto-installs LSPs.
        "ktlint",
        -- Kotlin/JVM DAP. Attach mode is the one that works reliably; see the
        -- nvim-dap block below.
        "kotlin-debug-adapter",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "kotlin" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_lsp = {
          cmd = {
            kotlin_lsp,
            "--stdio",
            -- Otherwise the indexes land in a JetBrains-shaped path outside
            -- stdpath, which makes "delete the stale index" a scavenger hunt.
            -- Deleting this directory is the fix when the server starts
            -- reporting unresolved references that resolve fine in Gradle.
            "--system-path",
            vim.fn.stdpath("cache") .. "/kotlin-lsp",
          },
          -- The default root_markers already cover settings.gradle{,.kts},
          -- build.gradle{,.kts} and pom.xml, which is every Kotlin project
          -- that has a build. A loose .kt file with no build gets no server.
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      -- ktlint reads the project's .editorconfig, so this agrees with whatever
      -- `./gradlew ktlintFormat` would do rather than imposing a second style.
      --
      -- No nvim-lint entry to go with it, unlike LazyVim's extra: ktlint's
      -- standard ruleset is almost entirely auto-correctable, so linting with
      -- the same binary that formats on save just draws a wall of diagnostics
      -- that vanish the moment you write. `detekt` is the linter to add here
      -- if real static analysis is wanted, and it needs a project config.
      formatters_by_ft = { kotlin = { "ktlint" } },
    },
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.adapters.kotlin = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/kotlin-debug-adapter",
        options = { auto_continue_if_many_stopped = false },
      }

      dap.configurations.kotlin = {
        {
          -- Attach, not launch. The adapter's launch mode asks Gradle to build
          -- and resolve a main class itself and is fragile about it; attaching
          -- to a JVM the project's own tooling started is the path that does
          -- not depend on the adapter guessing the build right.
          --
          --   ./gradlew run --debug-jvm      -- an application
          --   ./gradlew test --debug-jvm     -- a test run
          --
          -- Both stop and wait on 5005 until this attaches.
          type = "kotlin",
          request = "attach",
          name = "Attach to a --debug-jvm gradle run (5005)",
          hostName = "localhost",
          port = 5005,
          timeout = 2000,
          projectRoot = vim.fn.getcwd,
        },
      }
    end,
  },
}
