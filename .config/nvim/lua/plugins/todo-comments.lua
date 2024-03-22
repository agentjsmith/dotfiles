return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  config = function()
    require('todo-comments').setup()
    vim.keymap.set('n', '<leader>stc', ':TodoTelescope<Enter>', { desc = '[S]earch [T]odo [C]omments' })
  end
}
