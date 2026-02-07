return {
  -- Linting & Static Type Checking
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      local function does_command_exist(cmd)
        return vim.fn.executable(cmd) == 1
      end

      local grouped_linters_configs = {
        {
          filetypes = { "python" },
          linters = does_command_exist("mypy") and { "mypy" } or {},
        },
        -- TODO: figure out JS linters
        -- {
        --   filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        --   linters = { "eslint_d" },
        -- },
      }

      lint.linters_by_ft = {}
      for _, config_entry in ipairs(grouped_linters_configs) do
        if #config_entry.linters > 0 then
          for _, filetype in ipairs(config_entry.filetypes) do
            lint.linters_by_ft[filetype] = config_entry.linters
          end
        end
      end

      -- Autocommand to execute the actual linting
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("lint", { clear = true }),
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })

      -- Custom command to check which linters are configured for current buffer
      vim.api.nvim_create_user_command("LintInfo", function()
        local lint = require("lint")
        local ft = vim.bo.filetype
        local linters = lint.linters_by_ft[ft] or {}

        if #linters == 0 then
          print("No linters configured for filetype: " .. ft)
        else
          print("Active linters for " .. ft .. ": " .. table.concat(linters, ", "))
        end
      end, {})
    end,
  },
}
