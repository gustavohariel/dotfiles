return {
  -- Titanium colorscheme — inspired by OMP default dark theme
  -- Uses tokyonight as a base, then overrides highlights for titanium palette
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(colors)
        -- Override tokyonight palette with titanium colors
        colors.bg = "#151820"
        colors.bg_dark = "#0f1216"
        colors.bg_float = "#151820"
        colors.bg_highlight = "#1f252d"
        colors.bg_visual = "#2a3038"
        colors.bg_search = "#2a3038"
        colors.fg = "#e8ecf4"
        colors.fg_dark = "#9ca3b0"
        colors.fg_float = "#e8ecf4"
        colors.fg_gutter = "#6b7280"
        colors.fg_sidebar = "#e8ecf4"
        colors.blue = "#00b4ff"
        colors.blue0 = "#0082b3"
        colors.blue1 = "#00b4ff"
        colors.blue2 = "#00b4ff"
        colors.blue5 = "#0082b3"
        colors.blue6 = "#0082b3"
        colors.blue7 = "#0082b3"
        colors.green = "#00ff88"
        colors.green1 = "#00ff88"
        colors.green2 = "#00ff88"
        colors.teal = "#00ff88"
        colors.yellow = "#ffb347"
        colors.orange = "#ffb347"
        colors.red = "#ff4757"
        colors.red1 = "#ff4757"
        colors.magenta = "#d4c090"
        colors.purple = "#d4c090"
        colors.comment = "#6b7280"
        colors.border = "#2a3038"
        colors.diff = {
          add = "#003322",
          delete = "#330005",
          change = "#002233",
        }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "tokyonight"
    end,
  },
}
