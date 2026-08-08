return {
  -- Mason with borders
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },
  -- LSP info window with borders
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Set border for LspInfo window
      require("lspconfig.ui.windows").default_options.border = "rounded"
    end,
  },
  -- Which-key with borders
  {
    "folke/which-key.nvim",
    opts = {
      win = {
        border = "rounded",
      },
    },
  },
  -- Completion menu with borders (blink.cmp is LazyVim's engine; nvim-cmp is disabled)
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
      },
      signature = { window = { border = "rounded" } },
    },
  },
  -- Noice with borders and transparent cmdline
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
      views = {
        cmdline_popup = {
          border = {
            style = "rounded",
          },
          win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          },
        },
        popupmenu = {
          border = {
            style = "rounded",
          },
          win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          },
        },
      },
    },
  },
}
