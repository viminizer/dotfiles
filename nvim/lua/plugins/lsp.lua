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
            typescript = {
              suggest = {
                completeFunctionCalls = false,
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
        pyright = {},
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
    },
  },
  -- Java is configured in plugins/java.lua, through LazyVim's lang.java extra.
}
