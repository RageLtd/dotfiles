return {
  -- File explorer with Catppuccin-themed icons
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        -- Show gitignored files but grey them out
        hide_gitignored = false,
        hide_hidden = false,
        filtered_items = {
          visible = true, -- Show filtered items
          hide_dotfiles = false,
          hide_gitignored = false, -- Don\`t hide gitignored files
          hide_hidden = false,
          hide_by_name = {
            -- Still hide some system files that are truly useless
            ".DS_Store",
            "thumbs.db",
          },
          never_show = {}, -- Empty so nothing is completely hidden
        },
      },
      window = {
        mappings = {
          ["<space>"] = "none",
          ["H"] = "toggle_hidden", -- Toggle hidden files visibility
          ["?"] = "show_help",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "󰅂", -- Catppuccin-style arrow
          expander_expanded = "󰅀", -- Catppuccin-style arrow
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "󰉋", -- Catppuccin folder icon
          folder_open = "󰝰", -- Catppuccin open folder icon
          folder_empty = "󰉖", -- Catppuccin empty folder icon
          folder_empty_open = "󰷏", -- Catppuccin empty open folder
          default = "󰈚", -- Default file icon
          highlight = "NeoTreeFileIcon",
        },
        git_status = {
          symbols = {
            -- Git status symbols with Catppuccin styling
            added = "✚", -- Green
            modified = "●", -- Yellow
            deleted = "✖", -- Red
            renamed = "󰁕", -- Blue
            untracked = "★", -- White
            ignored = "󰙎", -- Grey (special symbol for ignored files)
            unstaged = "󰄱", -- Orange
            staged = "✓", -- Green
            conflict = "󰀧", -- Red
          },
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
      },
    },
    config = function(_, opts)
      -- Set up custom highlight groups for Catppuccin integration
      local function setup_highlights()
        -- Catppuccin Macchiato colors
        local colors = {
          text = "#cdd6f4",
          surface2 = "#6c7086",
          mauve = "#cba6f7",
          blue = "#89b4fa",
          green = "#a6e3a1",
          yellow = "#f9e2af",
          red = "#f38ba8",
          peach = "#fab387",
          pink = "#f5c2e7",
        }

        -- File explorer highlights
        vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", {
          fg = colors.surface2,
          italic = true,
        })

        vim.api.nvim_set_hl(0, "NeoTreeExpander", {
          fg = colors.mauve,
        })

        vim.api.nvim_set_hl(0, "NeoTreeFileIcon", {
          fg = colors.blue,
        })

        -- Git status colors
        vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = colors.green })
        vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = colors.red })
        vim.api.nvim_set_hl(0, "NeoTreeGitRenamed", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = colors.text })
        vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = colors.surface2 })
        vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged", { fg = colors.peach })
        vim.api.nvim_set_hl(0, "NeoTreeGitStaged", { fg = colors.green })
        vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = colors.red })
      end

      -- Apply highlights on colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup_highlights,
      })

      -- Apply highlights immediately
      setup_highlights()

      require("neo-tree").setup(opts)
    end,
  },

  -- Better notifications with Catppuccin styling
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#1e1e2e", -- Catppuccin base
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
      timeout = 3000,
      icons = {
        ERROR = "󰅚",
        WARN = "󰀪",
        INFO = "󰋽",
        DEBUG = "󰃤",
        TRACE = "✎",
      },
    },
  },

  -- Enhanced word highlighting
  {
    "RRethy/vim-illuminate",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
}
