vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)


-- shims for remote copy/paste support
vim.g.clipboard = 'osc52'
local opts = { noremap = true, silent = true }
-- yanks and select/copy always save to both os clipboard and register "r"
vim.keymap.set({ 'n', 'x' }, 'y',  '"ry', opts)  -- operator & visual yanks
vim.keymap.set('n', 'Y', '"rY',    opts)          -- line-wise yank (Y)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
        -- name of the register that received the text ("" if unnamed)
    local reg = vim.v.event.regname
    if reg == '' then reg = '"' end          -- unnamed register
    if reg == '_' then return end            -- ignore black-hole deletes

    local txt     = vim.fn.getreg(reg)
    local regtype = vim.fn.getregtype(reg)

    vim.fn.setreg('r', txt, regtype)         -- private clipboard
    vim.fn.setreg('+', txt, regtype)         -- OSC-52 / system clipboard
  end,
})
-- pastes via 'p' in normal/visual mode come from the "r" register
-- pastes via insert + C-v come from os clipboard
vim.keymap.set('x', '<C-c>', '"ry', opts)
vim.keymap.set({ 'n', 'x' }, 'p',  '"rp', opts)   -- paste after
vim.keymap.set({ 'n', 'x' }, 'P',  '"rP', opts)   -- paste before

