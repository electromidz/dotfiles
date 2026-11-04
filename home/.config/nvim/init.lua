-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.g.transparency = 0.65 -- 0.0 (fully transparent) to 1.0 (fully opaque)

-- Or set background to transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
