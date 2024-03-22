return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require('neo-tree').setup({
      enable_git_status = true,
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
      follow_current_file = { enabled = true },
      close_if_last_window = true,
      events = {
        {
          -- auto open file on creation
          event = "file_created",
          handler = function(file_path)
            vim.cmd("edit " .. file_path)
          end
        },
        {
          -- auto hide tree on file open
          event = "file_opened",
          handler = function(file_path)
            require("neo-tree.command").execute({ action = "close" })
          end
        },
      },
    })

    vim.keymap.set('n', '<leader>n', '<cmd>Neotree reveal toggle<cr>', { desc = "Toggle [N]eotree" })
  end
}
