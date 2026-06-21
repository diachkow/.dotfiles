return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" },
    cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "[F]ormat file",
      },
    },
    config = function()
      local conform = require("conform")
      local js_formatters = { "oxfmt", "oxlint" }

      -- Command to enable/disable format on save
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          go = { "gofmt" },
          javascript = js_formatters,
          typescript = js_formatters,
          javascriptreact = js_formatters,
          typescriptreact = js_formatters,
          html = { "oxfmt" },
          css = { "oxfmt" },
          scss = { "oxfmt" },
          less = { "oxfmt" },
          vue = js_formatters,
          graphql = { "oxfmt" },
          handlebars = { "oxfmt" },
          python = function(bufnr)
            local fallback_formatters = {}
            local append_default_formatter = function(formatter_name)
              if conform.get_formatter_info(formatter_name, bufnr) then
                table.insert(fallback_formatters, formatter_name)
              end
            end

            append_default_formatter("isort")
            append_default_formatter("black")

            -- Check if ruff is available
            if conform.get_formatter_info("ruff_format", bufnr) then
              return { "ruff_format", "ruff_fix" }
            end

            -- Return fallback formatters by default
            return fallback_formatters
          end,
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          local skip = {
            json = true,
            jsonc = true,
            yaml = true,
            ["yaml.docker-compose"] = true,
            ["yaml.gitlab"] = true,
            ["yaml.helm-values"] = true,
            toml = true,
          }
          if skip[vim.bo[bufnr].filetype] then
            return
          end
          return { timeout_ms = 800, lsp_format = "fallback" }
        end,
        notify_on_error = true,
        init = function()
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
      })
    end,
  },
}
