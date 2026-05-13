-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "SignColumn",
  "LineNr",
  "EndOfBuffer",
  "VertSplit",
  "WinSeparator",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "TabLineSel",
  "Pmenu",
  "PmenuSbar",
  "PmenuThumb",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "TelescopeResultsNormal",
  "TelescopeResultsBorder",
  "TelescopePreviewNormal",
  "TelescopePreviewBorder",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeEndOfBuffer",
  "NeoTreeWinSeparator",
  "WhichKeyFloat",
  "LazyNormal",
  "MasonNormal",
  "NoiceCmdlinePopup",
  "NoiceCmdlinePopupBorder",
  "NoicePopup",
  "NoicePopupmenu",
  "NotifyBackground",
  "DiagnosticVirtualTextError",
  "DiagnosticVirtualTextWarn",
  "DiagnosticVirtualTextInfo",
  "DiagnosticVirtualTextHint",
}

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserTransparentBg", { clear = true }),
  callback = function()
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})
