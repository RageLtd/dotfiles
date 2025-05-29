return {
  -- Biome integration (matching your Zed code actions)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {
          cmd = { "biome", "lsp-proxy" },
          filetypes = {
            "javascript",
            "javascriptreact", 
            "typescript",
            "typescriptreact",
            "json",
            "jsonc",
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("biome.json", "biome.jsonc")(fname)
          end,
          single_file_support = false,
          settings = {},
        },
      },
      setup = {
        biome = function(_, opts)
          -- Auto-format and organize imports on save (matching Zed behavior)
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.jsonc" },
            callback = function()
              vim.lsp.buf.code_action({
                context = {
                  only = { "source.fixAll.biome", "source.organizeImports.biome" },
                  diagnostics = {},
                },
                apply = true,
              })
            end,
          })
        end,
      },
    },
  },
  
  -- Additional formatter integration
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
      },
      formatters = {
        biome = {
          command = "biome",
          args = { "format", "--stdin-file-path", "$FILENAME" },
          stdin = true,
        },
      },
    },
  },
}
