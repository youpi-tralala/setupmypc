-- ~/.config/nvim/init.lua

-------------------------------------------------
-- Bootstrap packer.nvim + auto PackerSync
-------------------------------------------------
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

local packer_bootstrap = false

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = true
  fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  vim.cmd("packadd packer.nvim")
end

-------------------------------------------------
-- Plugins
-------------------------------------------------
require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- LSP
  use "neovim/nvim-lspconfig"

  -- Autocomplétion
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"

  if packer_bootstrap then
    require("packer").sync()
  end
end)

-------------------------------------------------
-- Options terminal (popup texte)
-------------------------------------------------
vim.o.completeopt = "menu,menuone,noselect"
vim.o.pumheight = 10

-------------------------------------------------
-- nvim-cmp (autocomplétion)
-------------------------------------------------
local cmp = require("cmp")

cmp.setup({
  mapping = {
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<CR>"]  = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-------------------------------------------------
-- LSP (Neovim ≥ 0.11, API native)
-------------------------------------------------
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("bashls", {
  capabilities = capabilities,
})

vim.lsp.enable("bashls")
