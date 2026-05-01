-- Nvim config — Alex's sometimes-editor.
--
-- IntelliJ is the primary editor for engineering work. Nvim is used for
-- reading markdown spec/plan files in the terminal, scratch edits, git
-- commit messages, and other on-the-fly file work. Kept intentionally
-- light: a Night Owl colorscheme matching the Ghostty terminal, plus
-- nvim-treesitter for proper syntax highlighting (including in fenced
-- markdown code blocks). NOT an IDE replacement — no LSP, no completion,
-- no diagnostics.

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
  -- nvim-treesitter (main branch — the 1.0 rewrite for nvim 0.10+).
  -- Provides full per-token syntax highlighting (strings, identifiers,
  -- function names, types, comments) instead of just regex keyword matching.
  -- Markdown injections work natively: a ```java fence inside a .md file gets
  -- the Java parser applied to its contents. Requires `tree-sitter` CLI on
  -- PATH (provided by the tree-sitter-cli brew formula in Brewfile).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local langs = {
        "markdown", "markdown_inline",
        "java", "groovy", "sql", "json", "yaml",
        "javascript", "typescript", "python",
        "bash", "html", "xml", "ruby", "lua",
      }
      require("nvim-treesitter").install(langs)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "markdown", "java", "groovy", "sql", "json", "yaml",
          "javascript", "typescript", "python", "bash", "sh",
          "html", "xml", "ruby", "lua",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
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
