-- Only what LazyVim does not already do.
--
-- Two things install servers for free, so listing them again here is noise:
--   * every enabled entry in `servers` below is handed to mason-lspconfig's
--     own ensure_installed, so LSP servers install themselves
--   * the extras in lazyvim.json bring their own servers and tools -- clangd,
--     the docker pair, jdtls, jsonls, yamlls, vtsls, taplo, prettier
--
-- Formatters and linters are the exception: nothing auto-installs those.
return {
  {
    "mason-org/mason.nvim",
    opts = {
      -- bash-language-server shells out to shellcheck when it is on PATH, and
      -- no enabled extra installs it.
      ensure_installed = { "shellcheck" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      -- Merged into LazyVim's defaults, then passed to vim.diagnostic.config()
      diagnostics = {
        float = {
          border = "rounded",
          severity_sort = true,
          max_width = 80,
          max_height = 20,
        },
      },
      servers = {
        -- TypeScript/JavaScript. The lang.typescript extra sets everything
        -- else; this only turns off the argument placeholders it enables.
        -- The extra copies these settings over to javascript, so setting
        -- typescript alone covers both.
        vtsls = {
          settings = {
            -- Section names with a slash are vtsls's own; it resolves
            -- "js/ts.hover.maximumLength" by splitting on dots, so "js/ts" is
            -- a single table key.
            ["js/ts"] = {
              -- Hover truncates at 500 characters by default, and the types
              -- worth putting on a projector are exactly the long ones.
              -- implicitProjectConfig is deliberately absent: it applies to
              -- every .js file outside a tsconfig, so util/teach.lua pushes
              -- checkJs/strict at runtime instead of lighting up every stray
              -- script with errors nobody asked for.
              hover = { maximumLength = 3000 },
            },
            vtsls = {
              experimental = {
                -- The typescript extra sets 30, which elides the informative
                -- half of any hint worth reading out.
                maxInlayHintLength = 80,
              },
            },
            typescript = {
              suggest = {
                completeFunctionCalls = false,
                -- JSDoc scaffolding, for the lessons that type plain JS
                -- before TypeScript shows up.
                completeJSDocs = true,
                jsdoc = { generateReturns = true },
              },
              preferences = {
                -- Auto-imports arrive as `import type`, which is the habit
                -- worth teaching rather than correcting later.
                preferTypeOnlyAutoImports = true,
                importModuleSpecifier = "shortest",
              },
              -- Land in real source instead of a .d.ts, so "let's look inside
              -- the library" arrives somewhere readable.
              preferGoToSourceDefinition = true,
              tsserver = {
                -- Errors in files nobody has opened yet. Without this a broken
                -- file stays green until someone happens to open it.
                experimental = { enableProjectDiagnostics = true },
              },
              -- Server-side only. Nothing renders these until teach mode turns
              -- nvim's codelens on, and the server computes a lens only when
              -- it is asked for one.
              referencesCodeLens = { enabled = true, showOnAllFunctions = true },
              implementationsCodeLens = {
                enabled = true,
                showOnInterfaceMethods = true,
                showOnAllClassMethods = true,
              },
              inlayHints = {
                -- The typescript extra enables everything here except
                -- variableTypes, which is the one that draws `const total:
                -- number`. That is the whole point when the subject is types.
                -- suppressWhen* default to hiding a hint when it merely
                -- repeats the name; a class needs to see it anyway.
                variableTypes = { enabled = true, suppressWhenTypeMatchesName = false },
                parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = false },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
        eslint = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
        -- pyright does not format, so without ruff a .py file saves unchanged.
        -- ruff covers formatting, linting and organize-imports in one server.
        pyright = {},
        ruff = {},
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
        -- Web
        html = {},
        cssls = {},
        tailwindcss = {},
        -- Shell
        bashls = {},
      },
      setup = {
        -- Both ruff and pyright answer hover. pyright's is the useful one.
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
  -- Java is configured in plugins/java.lua, through LazyVim's lang.java extra.
}
