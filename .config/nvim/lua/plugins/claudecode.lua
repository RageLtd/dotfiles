return {
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim", -- Enhanced terminal support (preferred provider)
    },
    config = function()
      -- Ensure Claude CLI is in PATH for the plugin
      local claude_dir = "/Users/NathanDeVuono/.claude/local"
      local current_path = vim.env.PATH or ""
      if not string.find(current_path, claude_dir, 1, true) then
        vim.env.PATH = claude_dir .. ":" .. current_path
      end
      
      require("claudecode").setup({
        -- Server Configuration
        port_range = { min = 10000, max = 65535 },
        auto_start = true,
        log_level = "warn", -- Reduced noise: warn, error only
        
        -- Selection and Context Tracking
        track_selection = true,
        visual_demotion_delay_ms = 50, -- Quick visual selection updates
        
        -- Connection Settings (optimized timeouts)
        connection_wait_delay = 200,
        connection_timeout = 15000, -- Increased for reliability
        queue_timeout = 5000,
        
        -- Terminal Configuration (using official options)
        terminal = {
          split_side = "right",
          split_width_percentage = 0.35, -- Slightly wider for better UX
          provider = "snacks", -- Explicitly use snacks for consistency
          auto_close = true,
        },
        
        -- Diff Integration (enhanced with all available options)
        diff_opts = {
          auto_close_on_accept = true,
          show_diff_stats = true, -- Show insertion/deletion counts
          vertical_split = true,
          open_in_current_tab = true,
        },
      })
    end,
    
    keys = {
      -- Core Claude Code commands (official recommendations)
      { "<leader>cc", "<cmd>ClaudeCode<cr>", mode = { "n", "v" }, desc = "🤖 Toggle Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "🎯 Focus Claude Terminal" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "📤 Send Selection to Claude" },
      
      -- Diff management (optimized keybindings)
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "✅ Accept Diff" },
      { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "❌ Deny Diff" },
      
      -- Status and debugging
      { "<leader>cS", "<cmd>ClaudeCodeStatus<cr>", desc = "📊 Claude Status" },
    },
    
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend", 
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeStatus",
    },
    
    -- Load on these events (including when buffers are already open)
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
  },
}