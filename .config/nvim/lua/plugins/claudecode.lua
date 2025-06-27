return {
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim", -- Optional: Enhanced terminal support
    },
    config = function()
      -- Ensure Claude CLI is in PATH for the plugin
      local claude_dir = "/Users/NathanDeVuono/.claude/local"
      local current_path = vim.env.PATH or ""
      if not string.find(current_path, claude_dir, 1, true) then
        vim.env.PATH = claude_dir .. ":" .. current_path
      end
      
      require("claudecode").setup({
        -- Logging level
        log_level = "error",
        
        -- Auto-start configuration
        auto_start = true,                   -- Allow starting with buffers open
        
        -- Terminal Configuration for Right-Side Panel
        terminal = {
          split_side = "right",              -- Right-side panel
          split_width_percentage = 0.35,     -- 35% of screen width
          auto_close = true,                 -- Close panel when Claude exits
          reuse_existing = true,             -- Reuse existing terminal if available
        },
        
        -- Connection settings
        connection_timeout = 10000,          -- 10 second timeout for connection
        track_selection = true,              -- Track buffer selection changes
      })
    end,
    
    keys = {
      -- Main Claude Code toggle (works in normal and visual modes)
      { "<leader>cc", "<cmd>ClaudeCode<cr>", mode = { "n", "v" }, desc = "🤖 Toggle Claude Code" },
      
      -- Send selection to Claude
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "📤 Send to Claude" },
      
      -- Diff management
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "✅ Accept Changes" },
      { "<leader>cr", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "❌ Reject Changes" },
      { "<leader>cd", "<cmd>ClaudeCodeDiffToggle<cr>", desc = "🔄 Toggle Diff View" },
      
      -- Context management
      { "<leader>cf", "<cmd>ClaudeCodeAddFile<cr>", desc = "📁 Add File Context" },
      { "<leader>cb", "<cmd>ClaudeCodeAddBuffer<cr>", desc = "📄 Add Buffer Context" },
      
      -- Quick actions
      { "<leader>ce", "<cmd>ClaudeCodeExplain<cr>", mode = { "n", "v" }, desc = "📖 Explain Code" },
      { "<leader>co", "<cmd>ClaudeCodeOptimize<cr>", mode = { "n", "v" }, desc = "⚡ Optimize Code" },
      { "<leader>ct", "<cmd>ClaudeCodeTest<cr>", mode = { "n", "v" }, desc = "🧪 Generate Tests" },
    },
    
    cmd = {
      "ClaudeCode",
      "ClaudeCodeSend", 
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeDiffToggle",
      "ClaudeCodeAddFile",
      "ClaudeCodeAddBuffer",
      "ClaudeCodeExplain",
      "ClaudeCodeOptimize",
      "ClaudeCodeTest",
    },
    
    -- Load on these events (including when buffers are already open)
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
  },
}