return {
  -- Mason: ensure language servers are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "vtsls",
        "eslint-lsp",
        "clangd",
        "rust-analyzer",
        "jdtls",
        "pyright",
        "gopls",
        "lua-language-server",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "json-lsp",
        "yaml-language-server",
        "bash-language-server",
        "dockerfile-language-server",
        "docker-compose-language-service",
        -- Formatters
        "prettier",
        "stylua",
        "shfmt",
        "clang-format",
        "rustfmt",
        "gofumpt",
        "black",
        "isort",
        -- Linters
        "eslint_d",
        "shellcheck",
      },
    },
  },
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        -- JavaScript/TypeScript (disabled - using LazyVim's vtsls extra instead)
        ts_ls = { enabled = false },
        vtsls = {}, -- Use vtsls for TypeScript
        eslint = {},
        -- C/C++
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
        },
        -- Rust
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
        -- Python
        pyright = {},
        -- Go
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
        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        -- Web
        html = {},
        cssls = {},
        tailwindcss = {},
        -- Data/Config
        jsonls = {},
        yamlls = {},
        -- Shell
        bashls = {},
        -- Docker
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
  -- Java (special handling)
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
  },
}
