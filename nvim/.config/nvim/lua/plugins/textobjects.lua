-- nvim-treesitter-textobjects v1.0 (main branch).
--
-- v1.0 dropped the old `configs.setup({ textobjects = {...} })` API and the
-- bundled keymap registration. We now `setup{}` the plugin's per-module
-- options and wire keymaps ourselves with the new helpers
-- `select.select_textobject` / `move.goto_*`.
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
    -- Stop the plugin from registering its own legacy default maps.
    vim.g.no_plugin_maps = true
  end,
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        selection_modes = {
          ["@parameter.outer"] = "v",  -- charwise
          ["@function.outer"]  = "V",  -- linewise
          ["@class.outer"]     = "<c-v>", -- blockwise
        },
        include_surrounding_whitespace = true,
      },
      move = {
        set_jumps = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")

    -- Selection (visual + operator-pending). "textobjects" is the query
    -- group bundled with this plugin.
    local function sel(query, group)
      return function() select.select_textobject(query, group or "textobjects") end
    end
    vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"))
    vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"))
    vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"),
      { desc = "Select outer part of a class region" })
    vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"),
      { desc = "Select inner part of a class region" })
    vim.keymap.set({ "x", "o" }, "as", sel("@local.scope", "locals"),
      { desc = "Select language scope" })

    -- Movement (normal + visual + operator-pending). Bindings preserved
    -- from the legacy config — note the unconventional [f / ]f swap.
    local m = { "n", "x", "o" }
    vim.keymap.set(m, "[f", function() move.goto_next_start("@function.outer", "textobjects") end)
    vim.keymap.set(m, "][", function() move.goto_next_start("@class.outer", "textobjects") end)
    vim.keymap.set(m, "]f", function() move.goto_previous_start("@function.outer", "textobjects") end)
    vim.keymap.set(m, "[[", function() move.goto_previous_start("@class.outer", "textobjects") end)
    vim.keymap.set(m, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end)
    vim.keymap.set(m, "[]", function() move.goto_previous_end("@class.outer", "textobjects") end)
  end,
}
