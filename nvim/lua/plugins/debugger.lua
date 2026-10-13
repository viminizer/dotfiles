local function float_element(element)
  return function()
    require("dapui").float_element(element, {
      enter = true,
      position = "center",
      width = math.max(1, math.floor(vim.o.columns * 0.8) - 2),
      height = math.max(1, math.floor(vim.o.lines * 0.7) - 2),
    })
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dD",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "Clear All Breakpoints",
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      opts.layouts = {
        {
          position = "left",
          size = math.min(64, math.max(40, math.floor(vim.o.columns * 0.33))),
          elements = {
            { id = "scopes", size = 0.5 },
            { id = "watches", size = 0.25 },
            { id = "stacks", size = 0.25 },
          },
        },
        {
          position = "bottom",
          size = 0.25,
          elements = {
            { id = "repl", size = 0.6 },
            { id = "console", size = 0.4 },
          },
        },
      }
      opts.floating = { border = "rounded", max_width = 0.9, max_height = 0.85 }
      opts.render = { indent = 2 }
    end,
    keys = {
      { "<leader>dv", float_element("scopes"), desc = "Variables (Float)" },
      { "<leader>dW", float_element("watches"), desc = "Watches (Float)" },
      { "<leader>df", float_element("stacks"), desc = "Stack Frames (Float)" },
      { "<leader>dp", float_element("breakpoints"), desc = "Breakpoints (Float)" },
      {
        "<leader>dU",
        function()
          require("dapui").open({ reset = true })
        end,
        desc = "Reset Dap UI Layout",
      },
    },
  },
}
