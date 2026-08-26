-- Plugins that only earn their place while teaching. All three stay quiet
-- until asked for, so they cost nothing during normal editing.
return {
  -- Inline `// ^?` type queries, the same syntax the TypeScript handbook uses.
  -- Hover vanishes the moment the cursor moves; a query stays on screen while
  -- you talk about it, and students can copy the pattern into their own editor.
  {
    "marilari88/twoslash-queries.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      multi_line = true,
      -- Off until :TwoslashQueriesEnable. Otherwise every stray `^?` in a
      -- comment starts rendering types mid-lesson.
      is_enabled = false,
      highlight = "Type",
    },
    keys = {
      { "<leader>tq", "<cmd>TwoslashQueriesEnable<cr>", desc = "Twoslash: enable" },
      { "<leader>tQ", "<cmd>TwoslashQueriesDisable<cr>", desc = "Twoslash: disable" },
      { "<leader>ti", "<cmd>TwoslashQueriesInspect<cr>", desc = "Twoslash: inspect under cursor" },
    },
    config = function(_, opts)
      require("twoslash-queries").setup(opts)
      -- The plugin attaches per client rather than globally.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("TwoslashAttach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "vtsls" then
            require("twoslash-queries").attach(client, args.buf)
          end
        end,
      })
    end,
  },

  -- Rewrites TypeScript's error messages into plain English. "Type 'X' is not
  -- assignable to type 'Y'" is a wall of text for anyone still learning the
  -- language, and reading it aloud is not teaching.
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      auto_attach = true,
      servers = { "vtsls" },
    },
  },

  -- Puts the keys you press on screen. Students ask "what did you just press"
  -- constantly, and narrating every motion breaks the flow of the lesson.
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    opts = {
      position = "top-right",
      timeout = 3,
      maxkeys = 5,
      show_count = true,
    },
  },
}
