return {
  {
    "olivercederborg/poimandres.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      bold_vert_split = false,
      dim_nc_background = false,
      disable_background = true,
      disable_float_background = true,
      disable_italics = false,
    },
    config = function(_, opts)
      require("poimandres").setup(opts)
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "poimandres",
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "poimandres"
    end,
  },
}
