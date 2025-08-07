-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Basic configs
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.scrolloff = 5
vim.opt.syntax = "enable"
vim.opt.linebreak = true -- break on words, not characters

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    "ibhagwan/fzf-lua",
    'nvim-treesitter/nvim-treesitter',
    'nvim-lualine/lualine.nvim',
    'rust-lang/rust.vim',
    'nvim-tree/nvim-web-devicons',
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
      -- RUST
      'mrcjkb/rustaceanvim',
      version = '^6', -- Recommended
      lazy = false, -- This plugin is already lazy
    },
    { 
      -- LSP Hints
      "chrisgrieser/nvim-lsp-endhints", 
      event = "LspAttach", 
      opts = {}, -- required, even if empty
    },
    {
      -- more languages
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require('lspconfig')
    
    -- Configure the LSPs for prettier formatting
    -- add in html and other LSPs
    -- For HTML, CSS, JSON
    -- npm install -g vscode-langservers-extracted
    -- # For JavaScript/TypeScript  
    -- npm install -g typescript-language-server typescript
    -- # For general formatting (includes prettier)
    -- npm install -g @fsouza/prettierd
    lspconfig.html.setup{}
    lspconfig.cssls.setup{}
    lspconfig.jsonls.setup{}
    lspconfig.ts_ls.setup{}
  end,
}
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})


-- Alright, now we're getting into configuration town!
vim.cmd.colorscheme "catppuccin"

-- Lualine
require('lualine').setup {
  tabline = {
    lualine_a = {'buffers'}
  },
  tabline_buffers_highlight = {
    active = {
      bg = '#FFFF00', -- Yellow background
      fg = '#000000', -- Black text for contrast
      gui = 'bold'
    }
  }
}

-- Use the LSP for format the buffer on write
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Enable automatic reading of files when changed outside of Vim
vim.opt.autoread = true

-- Trigger autoread when files change on disk
vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI'}, {
  pattern = '*',
  command = "if mode() !~ '\\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif",
})

-- Notification after file change
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  callback = function()
    vim.api.nvim_echo({{'File changed on disk. Buffer reloaded.', 'WarningMsg'}}, true, {})
  end,
})

-- Custom keybindings
vim.keymap.set('n', '<C-p>', ':FzfLua git_files<CR>', { noremap = true, silent = true }) -- file browser
vim.keymap.set('n', '<C-n>', ':bprevious<CR>', { noremap = true, silent = true }) -- previous buffer
vim.keymap.set('n', '<C-m>', ':bnext<CR>', { noremap = true, silent = true }) -- next buffer
vim.keymap.set('n', '<C-w>', ':bdelete<CR>', { noremap = true, silent = true }) -- close buffer

vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true, desc = 'LSP Rename' })
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { noremap = true, silent = true, desc = 'Diagnostic Message' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = 'Next diagnostic' })

require('latex-config')
