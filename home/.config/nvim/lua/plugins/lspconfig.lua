-- LSP-related configuration plus mason for loading configuration
return {
  { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      "b0o/SchemaStore.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local keybind = function(keymap, func, desc)
            vim.keymap.set("n", keymap, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          keybind("gd", Snacks.picker.lsp_definitions, "Goto Definition")
          keybind("gD", vim.lsp.buf.declaration, "Goto Declaration")
          keybind("grr", Snacks.picker.lsp_references, "Goto References")
          keybind("gri", Snacks.picker.lsp_implementations, "Goto Implementations")
          keybind("grn", vim.lsp.buf.rename, "Rename Variable")
          keybind("gra", vim.lsp.buf.code_action, "Execute Code Action")
          keybind("gO", Snacks.picker.lsp_symbols, "Document Symbols")
          keybind("<leader>d", Snacks.picker.lsp_symbols, "Dynamic Workspace Symbols")
          keybind("<leader>D", Snacks.picker.lsp_type_definitions, "Type Definitions")
          keybind("K", vim.lsp.buf.hover, "Hover Element Under Cursor")
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      local make_capabilities = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

        -- Position encoding fix
        capabilities.general = capabilities.general or {}
        capabilities.general.positionEncodings = { "utf-16", "utf-8" }

        return capabilities
      end

      -- Setup Mason first
      require("mason").setup({
        PATH = "append",
      })

      local ensure_installed = {
        "lua-language-server",
        "ruff",
        "typescript-language-server",
        "typos-lsp",
        "tombi",
        "json-lsp",
        "yaml-language-server",
        "stylua",
        "isort",
        "oxlint",
        "oxfmt",
      }

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
        run_on_start = true,
      })

      -- NOTE: Add default capabilities for *all* LSP clients
      vim.lsp.config("*", { capabilities = make_capabilities() })

      vim.lsp.config("ty", {
        settings = {
          ty = {
            inlayHints = {
              variableTypes = false,
              callArgumentNames = false,
            },
          },
        },
      })
      vim.lsp.enable("ty")

      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            args = {},
          },
        },
      })
      vim.lsp.enable("ruff")

      -- Lua LSP setup
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "Snacks" },
            },
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = {
                "${3rd}/luv/library",
                unpack(vim.api.nvim_get_runtime_file("", true)),
              },
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- Typescript LSP setup
      vim.lsp.config("ts_ls", {
        filetypes = {
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
        },
      })
      vim.lsp.enable("ts_ls")

      vim.lsp.enable("oxlint")

      -- Typos LSP setup
      vim.lsp.config("typos_lsp", {
        init_options = {
          config = vim.fn.stdpath("config") .. "/typos.toml",
        },
      })
      vim.lsp.enable("typos_lsp")

      -- TOML LSP (tombi: actively-maintained successor to taplo)
      vim.lsp.enable("tombi")

      -- JSON LSP with SchemaStore catalog
      -- Schemas must be set in before_init (not on_init) for vim.lsp.config() API
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            validate = { enable = true },
          },
        },
        before_init = function(_, config)
          config.settings.json.schemas = require("schemastore").json.schemas()
        end,
      })
      vim.lsp.enable("jsonls")

      -- YAML LSP with SchemaStore catalog
      -- Built-in schemaStore must be disabled when using SchemaStore.nvim
      vim.lsp.config("yamlls", {
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            schemaStore = { enable = false, url = "" },
            validate = true,
          },
        },
        before_init = function(_, config)
          config.settings.yaml.schemas = require("schemastore").yaml.schemas()
        end,
      })
      vim.lsp.enable("yamlls")
    end,
  },
}
