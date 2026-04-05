return {
  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      local ensure_installed = {
        "bash",
        "dockerfile",
        "ecma",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "html",
        "html_tags",
        "javascript",
        "json",
        "jsx",
        "just",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      local function install_missing_parsers()
        local installed = {}

        for _, lang in ipairs(ts.get_installed("parsers")) do
          installed[lang] = true
        end

        local missing = vim.tbl_filter(function(lang)
          return not installed[lang]
        end, ensure_installed)

        if #missing > 0 then
          ts.install(missing, { summary = true })
        end
      end

      -- Keep generated parsers out of the plugin checkout so stale copies do not shadow Neovim's bundled parsers.
      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      vim.api.nvim_create_user_command("TSInstallRequired", function()
        ts.install(ensure_installed, { summary = true })
      end, {
        desc = "Install curated Treesitter parsers",
      })

      if #vim.api.nvim_list_uis() > 0 then
        vim.api.nvim_create_autocmd("VimEnter", {
          group = vim.api.nvim_create_augroup("treesitter-install-missing", { clear = true }),
          once = true,
          callback = install_missing_parsers,
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- Sticky top for nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
      min_window_height = 20,
      max_lines = 5,
      multiline_threshold = 1,
      mode = "topline",
    },
  },
}
