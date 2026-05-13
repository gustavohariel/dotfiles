-- Run Biome on save (format + organize imports) via Conform's built-in biome-check.
-- Uses Prettier when project has Prettier config. No LSP override = inline lint stays as before.
-- Refs: https://github.com/LazyVim/LazyVim/issues/2116
--       https://github.com/stevearc/conform.nvim/issues/585#issuecomment-2504734402

local function find_config(bufnr, config_files)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil
  end
  return vim.fs.find(config_files, {
    upward = true,
    path = vim.fs.dirname(path),
  })[1]
end

local function biome_or_prettier(bufnr)
  if find_config(bufnr, { "biome.json", "biome.jsonc" }) then
    return { "biome-check", stop_after_first = true }
  end

  if find_config(bufnr, {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
  }) then
    return { "prettier", stop_after_first = true }
  end

  -- Default to Biome when no project config
  return { "biome-check", stop_after_first = true }
end

local filetypes_with_dynamic_formatter = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
  "css",
  "scss",
  "less",
  "html",
  "json",
  "jsonc",
  "yaml",
  "markdown",
  "markdown.mdx",
  "graphql",
  "handlebars",
}

return {
  -- Conform: use built-in biome-check (format + organize imports), Prettier when project has Prettier config
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(filetypes_with_dynamic_formatter) do
        opts.formatters_by_ft[ft] = biome_or_prettier
      end
      return opts
    end,
  },

  -- Mason: ensure Biome CLI is installed (biome-check formatter uses it)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "biome" })
      return opts
    end,
  },
}
