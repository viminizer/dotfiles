return {
  "snacks.nvim",
  opts = {
    styles = {
      float = {
        backdrop = false,
        wo = {
          winhighlight = "Normal:Normal,NormalFloat:Normal",
        },
      },
      sidebar = {
        backdrop = false,
        wo = {
          winhighlight = "Normal:Normal,NormalFloat:Normal,NormalSB:Normal",
        },
      },
    },
    explorer = {
      replace_netrw = true,
      follow_file = false,
      win = {
        border = "rounded",
        backdrop = false,
        wo = {
          winhighlight = "Normal:Normal,NormalFloat:Normal,NormalSB:Normal",
        },
      },
    },
    picker = {
      layout = {
        backdrop = false,
      },
      sources = {
        explorer = {
          layout = {
            backdrop = false,
          },
        },
      },
      win = {
        input = {
          border = "rounded",
          wo = {
            winhighlight = "Normal:Normal,NormalFloat:Normal",
          },
        },
        list = {
          border = "rounded",
          wo = {
            winhighlight = "Normal:Normal,NormalFloat:Normal",
          },
        },
        preview = {
          border = "rounded",
          wo = {
            winhighlight = "Normal:Normal,NormalFloat:Normal",
          },
        },
      },
    },
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[

██╗   ██╗██╗███╗   ███╗██╗███╗   ██╗██╗███████╗███████╗██████╗ 
██║   ██║██║████╗ ████║██║████╗  ██║██║╚══███╔╝██╔════╝██╔══██╗
██║   ██║██║██╔████╔██║██║██╔██╗ ██║██║  ███╔╝ █████╗  ██████╔╝
╚██╗ ██╔╝██║██║╚██╔╝██║██║██║╚██╗██║██║ ███╔╝  ██╔══╝  ██╔══██╗
 ╚████╔╝ ██║██║ ╚═╝ ██║██║██║ ╚████║██║███████╗███████╗██║  ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝
]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "b", desc = "Spring Boot Init", action = ":Springtime" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
}
