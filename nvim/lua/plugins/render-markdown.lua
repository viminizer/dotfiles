return {
  "MeanderingProgrammer/markdown.nvim",
  name = "render-markdown",
  ft = "markdown", -- or remove to load on demand
  opts = {
    link = {
      enabled = true,
      render_modes = false,
      footnote = {
        enabled = true,
        superscript = true,
        prefix = "",
        suffix = "",
      },
      image = "󰥶 ",
      email = "󰇮 ",
      hyperlink = "󰌹 ",
      highlight = "RenderMarkdownLink",
      wiki = {
        icon = "󱗖 ",
        body = function()
          return nil
        end,
        highlight = "RenderMarkdownWikiLink",
      },
      custom = {
        web = { pattern = "^http", icon = "󰖟 " },
        github = { pattern = "github%.com", icon = "󰊤 " },
        gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
        stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
        wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
        youtube = { pattern = "youtube%.com", icon = "󰗃 " },
      },
    },
    callout = {
      note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
      -- ... your other callout configs here ...
    },
    checkbox = {
      enabled = true,
      render_modes = false,
      bullet = false,
      right_pad = 1,
      unchecked = {
        icon = "  ",
        highlight = "RenderMarkdownUnchecked",
      },
      checked = {
        icon = "  ",
        highlight = "RenderMarkdownChecked",
      },
      custom = {
        todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
      },
    },
    bullet = {
      enabled = true,
      render_modes = false,
      icons = { "󰫣 ", "  ", "●", "○", "◆", "◇" },
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ("%d."):format(index > 1 and index or ctx.index)
      end,
      highlight = "RenderMarkdownBullet",
    },
    quote = {
      icon = "▋",
    },
    anti_conceal = {
      enabled = true,
      ignore = {
        code_background = true,
        sign = true,
      },
    },
  },
}
