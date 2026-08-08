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
        -- Defaults to winblend 30, which cannot composite against a
        -- transparent background and renders a dark box.
        mini = {
          win_options = {
            winblend = 0,
            winhighlight = "Normal:NoiceMini",
          },
        },
      },
      -- LSP progress goes to the statusline instead of a floating box. No float
      -- can do what was asked: nvim draws it over the cells beneath it, and
      -- winblend only dims the text underneath rather than letting both occupy
      -- the same cell. The statusline has a row of its own, so it covers nothing.
      routes = {
        { filter = { event = "lsp", kind = "progress" }, opts = { skip = true } },
      },
      status = {
        lsp_progress = { event = "lsp", kind = "progress" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local text = require("noice").api.status.lsp_progress.get() or ""
          if #text > 50 then
            text = text:sub(1, 49)
            -- noice escapes % as %% for the statusline; truncating mid-pair
            -- would leave a stray % that gets read as a format item
            local _, count = text:gsub("%%", "")
            text = (count % 2 == 1 and text:sub(1, #text - 1) or text) .. "…"
          end
          return text
        end,
        cond = function()
          return package.loaded["noice"] and require("noice").api.status.lsp_progress.has()
        end,
        color = { fg = "#ffa500" },
      })
    end,
  },
}
