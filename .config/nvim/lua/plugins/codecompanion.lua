return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
      "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
      { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves the default Neovim interfaces
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "openai", -- Changed to OpenAI
          },
          inline = {
            adapter = "openai", -- Changed to OpenAI
          },
          agent = {
            adapter = "openai", -- Changed to OpenAI
          },
        },
        adapters = {
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "OPENAI_API_KEY", -- Reads from environment variable
              },
              schema = {
                model = {
                  default = "gpt-4o", -- Use GPT-4o as default (best model)
                },
                temperature = {
                  default = 0.1, -- Low temperature for more consistent code
                },
                max_tokens = {
                  default = 4096,
                },
              },
            })
          end,
          -- Keep anthropic as fallback option
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "ANTHROPIC_API_KEY",
              },
            })
          end,
        },
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = "🤖 AI Assistant ",
            provider = "telescope",
          },
          chat = {
            window = {
              layout = "vertical",
              border = "rounded", -- Nicer borders
              height = 0.8,
              width = 0.45,
              relative = "editor",
              opts = {
                breakindent = true,
                cursorcolumn = false,
                cursorline = false,
                foldcolumn = "0",
                linebreak = true,
                number = false,
              },
            },
            intro_message = "👋 Welcome to CodeCompanion with OpenAI GPT-4! How can I help you code today?",
          },
        },
        opts = {
          log_level = "ERROR",
          send_code = true,
          use_default_actions = true,
          use_default_prompt_library = true,
        },
        prompt_library = {
          ["Custom OpenAI"] = {
            strategy = "chat",
            description = "Custom prompt with GPT-4",
            opts = {
              index = 10,
              default_prompt = true,
              mapping = "<LocalLeader>cc",
              modes = { "n", "v" },
              slash_cmd = "custom",
              auto_submit = false,
            },
            prompts = {
              {
                role = "user",
                content = function()
                  return "Using GPT-4, please help me with: " .. vim.fn.input("Enter your request: ")
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
        },
      })
    end,
    keys = {
      -- Chat commands
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "🤖 AI Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "💬 AI Chat" },
      { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "🔄 Toggle AI Chat" },

      -- Quick actions
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = { "n", "v" }, desc = "📖 Explain Code" },
      { "<leader>af", "<cmd>CodeCompanion /fix<cr>", mode = { "n", "v" }, desc = "🔧 Fix Code" },
      { "<leader>ao", "<cmd>CodeCompanion /optimize<cr>", mode = { "n", "v" }, desc = "⚡ Optimize Code" },
      { "<leader>ar", "<cmd>CodeCompanion /refactor<cr>", mode = { "n", "v" }, desc = "🔄 Refactor Code" },
      { "<leader>at", "<cmd>CodeCompanion /tests<cr>", mode = { "n", "v" }, desc = "🧪 Generate Tests" },
      { "<leader>ad", "<cmd>CodeCompanion /document<cr>", mode = { "n", "v" }, desc = "📝 Document Code" },

      -- Inline assistance
      { "<leader>ai", "<cmd>CodeCompanionInline<cr>", mode = { "n", "v" }, desc = "✨ Inline AI" },

      -- Custom prompts
      { "<leader>ap", "<cmd>CodeCompanion /custom<cr>", mode = { "n", "v" }, desc = "🎯 Custom Prompt" },
    },
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionInline",
    },
  },
}
