local snacks_picker_exclude = {
  "**/.git/**",
  "**/.jj/**",
  "**/.hg/**",
  "**/.svn/**",
  "**/.venv/**",
  "**/venv/**",
  "**/.tox/**",
  "**/node_modules/**",
  "**/.direnv/**",
  "**/.mypy_cache/**",
  "**/.pytest_cache/**",
  "**/.ruff_cache/**",
  "**/__pycache__/**",
  "**/.idea/**",
  "**/.vscode/**",
}

return {
  {
    "folke/snacks.nvim",
    event = "VimEnter",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
      image = {},
      rename = {},
      input = {},
      picker = {
        ui_select = true,
        sources = {
          files = {
            follow = true,
            hidden = true,
            exclude = snacks_picker_exclude,
          },
          grep = {
            follow = true,
            hidden = true,
            exclude = snacks_picker_exclude,
          },
        },
        layout = {
          cycle = true,
        },
        win = {
          input = {
            wo = {
              winblend = 10,
            },
          },
          list = {
            wo = {
              winblend = 10,
            },
          },
          preview = {
            wo = {
              winblend = 10,
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "[S]earch [H]elp",
      },
      {
        "<leader>sk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "[S]earch [K]eymaps",
      },
      {
        "<leader>ss",
        function()
          Snacks.picker()
        end,
        desc = "[S]earch [S]elect Telescope",
      },
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "[S]earch [D]iagnostics",
      },
      {
        "<leader>sr",
        function()
          Snacks.picker.resume()
        end,
        desc = "[S]earch [R]esume",
      },
      {
        "<leader>s.",
        function()
          Snacks.picker.recent()
        end,
        desc = '[S]earch Recent Files ("." for repeat)',
      },
      {
        "<leader><leader>",
        function()
          Snacks.picker.buffers()
        end,
        desc = "[ ] Find existing buffers",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.lines({
            layout = {
              preset = "dropdown",
              preview = false,
            },
          })
        end,
        desc = "[/] Fuzzily search in current buffer",
      },
    },
  },
}
