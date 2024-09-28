-------------
-- Plugins --
-------------

vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"RRethy/nvim-base16", -- color scheme
		lazy = true,
	},
	{
		"ibhagwan/fzf-lua",   -- fuzzy finder 
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- search file with file name
			{ "<c-f>", mode = "n", function() require("fzf-lua").files() end, desc = "Fzf" },
			{ "<c-b>", mode = "n", function() require("fzf-lua").buffers() end, desc = "Fzf buffers" },
			-- search file with key word in file 
			{ "<c-g>", mode = "n", function() require("fzf-lua").live_grep() end, desc = "Fzf grep" }
		},
	},
	{
		"stevearc/oil.nvim", 	-- file explorer
		lazy = false, 		
		config = function()
			require("oil").setup {
				keymaps = {
					["gt"] = "actions.open_terminal",
					["g."] = "actions.toggle_hidden",
				}
			}
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrw_Plugin = 1
		end,
		keys = {
			{ "-", mode = "n", function() require("oil").open(nil) end, desc = "Oil file manager" },
		},
		ft = { "netrw", "oil" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
})

-------------
-- Setting --
-------------

vim.opt.encoding = "UTF-8"
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.scrolloff = 4

-- color scheme
vim.opt.termguicolors = true
-- vim.cmd.colorscheme("base16-tender") 	-- orange, red, yellow
vim.cmd.colorscheme("base16-danqing") 		-- orange, red, mauve
-- vim.cmd.colorscheme("base16-darcula")	-- orange, blue, green,

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
vim.keymap.set("n", "j", [[v:count ? "j" : "gj"]], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? "k" : "gk"]], { noremap = true, expr = true })
