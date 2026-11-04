-- return { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ... }
--return { "electromidz/necrophos", priority = 1000, config = true, opts = ... }

-- Setup with options
-- return {
--   "electromidz/necrophos",
--   lazy = false,
--   priority = 1000,
--   opts = {
--     theme = "kunkka", -- or "necrophos"
--   },
-- }
-- return {
--   "electromidz/necrophos",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     require("necrophos").setup({
--       theme = "kunkka",
--       transparent = false,
--     })
--   end,
-- }
return {
  {
    "electromidz/necrophos.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "invoker", -- This tells necrophos to use your kunkka theme
      transparent = true,
    },
    config = function(plugin, opts)
      require("necrophos").setup(opts)
    end,
  },
}
