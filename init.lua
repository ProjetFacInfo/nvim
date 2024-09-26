local set = vim.o

-------------
-- Setting --
-------------

set.number = true
set.encoding = "UTF-8"
set.relativenumber = true
set.clipboard = "unnamed"

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})

-----------------
-- keybindings --
-----------------

local opt = { noremap = true, silent = true }
vim.g.mapleader = " "

-- Splits / Navigation --
vim.keymap.set("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<Leader>s", "<C-w>s", opt)
vim.keymap.set("n", "<Leader>h", "<C-w>h", opt)
vim.keymap.set("n", "<Leader>l", "<C-w>l", opt)
vim.keymap.set("n", "<Leader>h", "<C-w>h", opt)
vim.keymap.set("n", "<Leader>j", "<C-w>j", opt)
vim.keymap.set("n", "<Leader>k", "<C-w>k", opt)

-- Jump line depend on size of terminal windows
-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })


