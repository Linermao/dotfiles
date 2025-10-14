return {
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    config = function()
      require("nvim-treesitter.configs").setup {
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  -- telescope
  {
    "nvim-telescope/telescope.nvim", tag="0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },
}