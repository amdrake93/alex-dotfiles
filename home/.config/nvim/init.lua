-- Nvim config — Alex's sometimes-editor.
--
-- IntelliJ is the primary editor for engineering work. Nvim is used for
-- reading markdown spec/plan files in the terminal, scratch edits, git
-- commit messages, and other on-the-fly file work. Kept intentionally
-- light: a colorscheme matching the Ghostty Night Owl theme and a
-- markdown filetype plugin. NOT an IDE replacement — no LSP, no
-- completion, no diagnostics.

-- Bootstrap lazy.nvim (auto-clones on first run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key must be set before lazy.nvim loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim-markdown plugin globals (must be set before plugin loads)
vim.g.markdown_fenced_languages = {
  "java", "groovy", "sql", "json", "yaml",
  "javascript", "typescript", "python",
  "bash=sh", "sh", "html", "xml", "ruby",
}
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_conceal_code_blocks = 0

-- Plugins
require("lazy").setup({
  {
    "oxfist/night-owl.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("night-owl")
    end,
  },
  {
    "preservim/vim-markdown",
    ft = { "markdown" },
    dependencies = { "godlygeek/tabular" },
  },
})

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- UI
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false

-- Misc
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- Markdown buffer settings: soft-wrap prose at word boundaries, no folding
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.foldenable = false
  end,
})
