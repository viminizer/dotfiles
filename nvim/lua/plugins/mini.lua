return {
  {
    "nvim-mini/mini.snippets",
    opts = {
      expand = {
        insert = function(snippet)
          return MiniSnippets.default_insert(snippet, {
            empty_tabstop = "",
            empty_tabstop_final = "",
          })
        end,
      },
    },
  },
}
