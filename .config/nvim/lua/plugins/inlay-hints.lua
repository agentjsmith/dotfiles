return {
  {
    'simrat39/rust-tools.nvim',
  },

  {
    'simrat39/inlay-hints.nvim',
    config = function ()
      require("inlay-hints").setup()

      local ih = require("inlay-hints")
      require("rust-tools").setup({
        tools = {
          on_initialized = function()
            ih.set_all()
          end,
          inlay_hints = {
            auto = false,
          },
        },
        server = {
          function (c,b)
            ih.on_attach(c,b)
          end,
        },
      })

    end
  },
}
