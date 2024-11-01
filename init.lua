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



-------------
-- Plugins --
-------------

require("lazy").setup({
	{
		"RRethy/nvim-base16", -- color scheme
		lazy = true,
	},
	{
		"ibhagwan/fzf-lua", -- fuzzy finder
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- search file with file name
			{ "<c-f>", mode = "n", function() require("fzf-lua").files() end,     desc = "Fzf" },
			{ "<c-b>", mode = "n", function() require("fzf-lua").buffers() end,   desc = "Fzf buffers" },
			-- search file with key word in file
			{ "<c-g>", mode = "n", function() require("fzf-lua").live_grep() end, desc = "Fzf grep" }
		},
	},
	{
		"stevearc/oil.nvim", -- file explorer
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

	-- LSP
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v4.x',
		lazy = true,
		config = false,
	},
	{
		'williamboman/mason.nvim',
		lazy = false,
		opts = {},
	},

	-- Autocompletion
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		config = function()
			local cmp = require('cmp')

			cmp.setup({
				sources = {
					{name = 'nvim_lsp'},
				},
				mapping = cmp.mapping.preset.insert({
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),
				}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})
		end
	},

	-- LSP
	{
		'neovim/nvim-lspconfig',
		cmd = {'LspInfo', 'LspInstall', 'LspStart'},
		event = {'BufReadPre', 'BufNewFile'},
		dependencies = {
			{'hrsh7th/cmp-nvim-lsp'},
			{'williamboman/mason.nvim'},
			{'williamboman/mason-lspconfig.nvim'},
		},
		init = function()
			-- Reserve a space in the gutter
			-- This will avoid an annoying layout shift in the screen
			vim.opt.signcolumn = 'yes'
		end,
		config = function()
			local lsp_defaults = require('lspconfig').util.default_config

			-- Add cmp_nvim_lsp capabilities settings to lspconfig
			-- This should be executed before you configure any language server
			lsp_defaults.capabilities = vim.tbl_deep_extend(
				'force',
				lsp_defaults.capabilities,
				require('cmp_nvim_lsp').default_capabilities()
			)

			-- LspAttach is where you enable features that only work
			-- if there is a language server active in the file
			vim.api.nvim_create_autocmd('LspAttach', {
				desc = 'LSP actions',
				callback = function(event)
					local opts = {buffer = event.buf}

					vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
					vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
					vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
					vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
					vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
					vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
					vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
					vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
					vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
					vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
				end,
			})

			require('mason-lspconfig').setup({
				ensure_installed = {
					'asm_lsp', 'bashls', 'awk_ls',
					'hls', 'ocamllsp', 'lua_ls',
					'rust_analyzer',
					'clangd', 'jdtls',
					'emmet_ls', 'ts_ls', 'phpactor',
					'pyright'
				},
				handlers = {
					-- this first function is the "default handler"
					-- it applies to every language server without a "custom handler"
					function(server_name)
						require('lspconfig')[server_name].setup({})
					end,
				}
			})
		end
	},


	{
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		config = function()
			require'nvim-treesitter.configs'.setup {
				highlight = { enable = true },

				indent = {
					disable = { 'bash', 'haskell' },
					enable = true,
				},

				additional_vim_regex_highlighting = false,

				ensure_installed = {
					-- linux
					'bash',
					'awk',
					'make',
					'toml',
					'xml',
					'markdown', 'markdown_inline',
					'vim', 'vimdoc',
					'yaml',
					'query',
					'regex',
					-- prog
					'c', 'cpp',
					'lua', 'luadoc', 'luap',
					'python',
					'ocaml',
					'haskell',
					'r',
					'rust',
					'zig',
					'java',
					-- web
					'html',
					'css',
					'javascript', 'jsdoc', 'json',
					'typescript', 'tsx',
					'php',
					'sql',
				},

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = '<space>',
						node_incremental = '<space>',
						scope_incremental = false,
						node_decremental = '<backspace>',
					},
				},
			}
		end,
	},
        {
		'nvim-treesitter/nvim-treesitter-textobjects',
		lazy = false,
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
	},
	{
		'NvChad/nvim-colorizer.lua',
		config = true,
		ft = { 'vim', 'lua', 'html', 'css', 'js', 'php', 'scss', 'dosini' },
	},
	-- { bug endwise range = nil
	-- 	'RRethy/nvim-treesitter-endwise',
	-- 	config = function()
	-- 		require('nvim-treesitter.configs').setup {
	-- 			endwise = { enable = true },
	-- 		}
	-- 	end,
	-- 	ft = { 'lua', 'ruby', 'vimscript', 'sh', 'elixir', 'fish', 'julia' },
	-- 	dependencies = 'nvim-treesitter/nvim-treesitter',
	-- },
	{
		'itchyny/vim-haskell-indent',
		ft = 'haskell',
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
vim.cmd.colorscheme("base16-danqing") -- orange, red, mauve
-- vim.cmd.colorscheme("base16-darcula")	-- orange, blue, green,

vim.api.nvim_create_autocmd(
	{ "TextYankPost" }, 
	{ pattern = { "*" },
		callback = function()
			vim.highlight.on_yank({
				timeout = 300,
			}) end,
	}
)

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


