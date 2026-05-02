-- nvim-treesitter v1.0 (main branch).
--
-- v1.0 is a rewrite: there is no `nvim-treesitter.configs.setup{}` and no
-- `ensure_installed` field. Parsers are installed via the imperative
-- `install()` call below, and highlight/indent are enabled per-buffer via
-- the FileType autocmd (the way Neovim core treesitter expects it).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- upstream guidance: do not lazy-load
  build = ":TSUpdate",
  config = function()
    -- Install (async) the parsers this config relies on. New parsers added
    -- to the list will install on next startup; missing ones never block.
    require("nvim-treesitter").install({
      "typst", "purescript", "nix", "nim", "vimdoc",
      "go", "rust", "c", "lua", "python",
      "html", "css", "javascript", "typescript", "prisma",
      "haskell", "zig", "gleam", "wgsl", "php",
      "sql", "markdown", "latex", "gdscript", "gdshader",
    })

    -- Enable treesitter highlight + indent on any filetype that has a
    -- parser installed. pcall guards against filetypes without one.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        if pcall(vim.treesitter.start) then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
