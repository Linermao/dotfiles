return {
  { import = "lazyvim.plugins.extras.lang.rust" },
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    opts = function(_, opts)
      opts.server.default_settings["rust-analyzer"] = {
        cargo = {
          loadOutDirsFromCheck = true,
        },
        checkOnSave = true,
        procMacro = { enable = true },
      }
    end,
  },
}
