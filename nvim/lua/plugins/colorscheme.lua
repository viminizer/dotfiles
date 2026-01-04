return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = true,
        },
        groups = {
          all = {
            NormalSB = { bg = "NONE" },
            NormalFloat = { bg = "NONE" },
            NormalNC = { bg = "NONE" },
            LazyNormal = { bg = "NONE" },
            -- Statusline transparent
            StatusLine = { bg = "NONE" },
            StatusLineNC = { bg = "NONE" },
            -- Tabline/bufferline transparent
            TabLine = { bg = "NONE" },
            TabLineFill = { bg = "NONE" },
            TabLineSel = { bg = "NONE" },
          },
        },
      })
      vim.cmd.colorscheme("carbonfox")
      -- Re-apply after VimEnter to ensure it sticks
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function()
            vim.cmd.colorscheme("carbonfox")
          end, 10)
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "carbonfox",
    },
  },
  -- Lualine with transparent background
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = {
          normal = {
            a = { bg = "NONE" },
            b = { bg = "NONE" },
            c = { bg = "NONE" },
          },
          insert = {
            a = { bg = "NONE" },
            b = { bg = "NONE" },
            c = { bg = "NONE" },
          },
          visual = {
            a = { bg = "NONE" },
            b = { bg = "NONE" },
            c = { bg = "NONE" },
          },
          replace = {
            a = { bg = "NONE" },
            b = { bg = "NONE" },
            c = { bg = "NONE" },
          },
          command = {
            a = { bg = "NONE" },
            b = { bg = "NONE" },
            c = { bg = "NONE" },
          },
          inactive = {
            a = { bg = "NONE" },
            b = { bg = "NONE" },
            c = { bg = "NONE" },
          },
        },
        section_separators = "",
        component_separators = "",
      },
    },
  },
  -- Bufferline with transparent background
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = { "", "" },
      },
      highlights = {
        fill = { bg = "NONE" },
        background = { bg = "NONE" },
        tab = { bg = "NONE" },
        tab_selected = { bg = "NONE" },
        tab_separator = { bg = "NONE" },
        tab_separator_selected = { bg = "NONE" },
        buffer_visible = { bg = "NONE" },
        buffer_selected = { bg = "NONE", bold = true, italic = false },
        close_button = { bg = "NONE" },
        close_button_visible = { bg = "NONE" },
        close_button_selected = { bg = "NONE" },
        separator = { bg = "NONE" },
        separator_visible = { bg = "NONE" },
        separator_selected = { bg = "NONE" },
        offset_separator = { bg = "NONE" },
        indicator_selected = { bg = "NONE" },
        indicator_visible = { bg = "NONE" },
        duplicate = { bg = "NONE" },
        duplicate_visible = { bg = "NONE" },
        duplicate_selected = { bg = "NONE" },
        modified = { bg = "NONE" },
        modified_visible = { bg = "NONE" },
        modified_selected = { bg = "NONE" },
        diagnostic = { bg = "NONE" },
        diagnostic_visible = { bg = "NONE" },
        diagnostic_selected = { bg = "NONE" },
        hint = { bg = "NONE" },
        hint_visible = { bg = "NONE" },
        hint_selected = { bg = "NONE" },
        info = { bg = "NONE" },
        info_visible = { bg = "NONE" },
        info_selected = { bg = "NONE" },
        warning = { bg = "NONE" },
        warning_visible = { bg = "NONE" },
        warning_selected = { bg = "NONE" },
        error = { bg = "NONE" },
        error_visible = { bg = "NONE" },
        error_selected = { bg = "NONE" },
      },
    },
  },
}
