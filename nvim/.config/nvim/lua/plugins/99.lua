-- ThePrimeagen's 99 AI plugin for Neovim
-- Requires opencode to be installed and configured
-- Repo: https://github.com/ThePrimeagen/99

return {
  "ThePrimeagen/99",
  -- Keep the plugin updated (project is in active development)
  version = false, -- Don't pin to a version, use latest
  config = function()
    local _99 = require("99")

    _99.setup({
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. vim.fs.basename(vim.uv.cwd()) .. ".99.debug",
        print_on_error = true,
      },
      -- Completion disabled - requires nvim-cmp but LazyVim uses blink.cmp
      -- The main features (fill-in function, visual mode) still work
      -- completion = {
      --   custom_rules = {
      --     "scratch/custom_rules/",
      --   },
      --   source = "cmp",
      -- },
      md_files = {
        "AGENT.md",
      },
    })

    -- Keybindings for AI functions
    -- <leader>9f - Fill in function implementation
    vim.keymap.set("n", "<leader>9f", function()
      _99.fill_in_function()
    end, { desc = "99: Fill in function" })

    -- <leader>9v - Process visual selection with AI
    vim.keymap.set("v", "<leader>9v", function()
      _99.visual()
    end, { desc = "99: Process visual selection" })

    -- <leader>9s - Stop all AI requests
    vim.keymap.set("v", "<leader>9s", function()
      _99.stop_all_requests()
    end, { desc = "99: Stop all requests" })
  end,
}
