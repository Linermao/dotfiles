return {
  "Wansmer/langmapper.nvim",
  config = function()
    vim.opt.langmap = "j;k,k;j"

    local langmapper = require("langmapper")
    langmapper.setup({
      hack_keymap = true,
      map_all_ctrl = false,
      disable_hack_modes = { "i" },
    })
    langmapper.automapping({ global = true, buffer = true })
  end,

  priority = 10,
}
