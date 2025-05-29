return {
  -- Better UI for command line with Catppuccin theming
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      -- Catppuccin-themed command line icons
      cmdline = {
        format = {
          cmdline = { icon = "󰘳" }, -- Command
          search_down = { icon = "󰍉" }, -- Search down
          search_up = { icon = "󰍉" }, -- Search up
          filter = { icon = "󰈲" }, -- Filter
          lua = { icon = "󰢱" }, -- Lua
          help = { icon = "󰋖" }, -- Help
        },
      },
    },
  },

  -- Enhanced status line with Catppuccin icons
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = { left = "󰿟", right = "󰿟" },
        section_separators = { left = "󰿟", right = "󰿟" },
        globalstatus = true,
        icons_enabled = true,
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = "󰀘", -- Mode icon
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "󰊢", -- Git branch icon
          },
          {
            "diff",
            symbols = {
              added = "󰐙 ",    -- Git added
              modified = "󰆗 ", -- Git modified  
              removed = "󰍷 ",  -- Git removed
            },
          },
        },
        lualine_c = {
          {
            "filename",
            symbols = {
              modified = "󰆗",   -- Modified
              readonly = "󰌾",   -- Readonly
              unnamed = "󰎞",    -- Unnamed
              newfile = "󰎝",    -- New file
            },
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = {
              error = "󰅚 ",   -- Error
              warn = "󰀪 ",    -- Warning
              info = "󰋽 ",    -- Info
              hint = "󰌶 ",    -- Hint
            },
          },
          {
            "filetype",
            colored = true,
            icon_only = false,
          },
        },
        lualine_y = {
          {
            "progress",
            icon = "󰉻", -- Progress icon
          },
        },
        lualine_z = {
          {
            "location",
            icon = "󰍉", -- Location icon
          },
        },
      },
    },
  },

  -- Disable conflicting dashboard
  {
    "goolord/alpha-nvim",
    enabled = false,
  },
}
