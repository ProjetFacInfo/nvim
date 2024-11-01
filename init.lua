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
 	-- file explorer
	{
		"stevearc/oil.nvim",
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

		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/nvim-cmp',
			'L3MON4D3/LuaSnip',
		},

		config = function()

			local lsp_zero = require('lsp-zero')

			lsp_zero.on_attach(function(client, bufnr)
				lsp_zero.default_keymaps({buffer = bufnr, exclude = 'gl'})
			end)


			lsp_zero.set_sign_icons({
				error = '✘',
				warn = '▲',
				hint = '⚑',
				info = '🛈'
			})


		end,

		ft = {
			'haskell',
			'asm',
			'sh',
			'ocaml',
			'c', 'cpp',
			'lua',
			'html', 'css', 'js', 'php', 'sql',
			'rust',
			'java',
			'python',
		},

		keys = {
			{ '<leader>i', mode = 'n', function() vim.diagnostic.open_float() end, },
		}
	},
	{
		'williamboman/mason.nvim',
		lazy = false,
		opts = {},
	},
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
					'pyright',
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
	-- Autocompletion
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			'rafamadriz/friendly-snippets',
			'onsails/lspkind.nvim',
		},

		config = function()
			local cmp = require('cmp')
			local cmp_action = require('lsp-zero').cmp_action()
			local cmp_format = require('lsp-zero').cmp_format({details = true})

			require('luasnip.loaders.from_vscode').lazy_load()

			cmp.setup({
				sources = {
					{name = 'nvim_lsp'},
					{name = 'buffer'},
					{name = 'luasnip'},
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					-- confirm completion
					-- select = true : confirm without selecting the item
					-- ['<C-y>'] = cmp.mapping.confirm({select = true}),
					['<CR>'] = cmp.mapping.confirm({select = false}),

					-- scroll up and down the documentation window
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),

					-- snippet
					['<C-f>'] = cmp_action.luasnip_jump_forward(),
					['<C-b>'] = cmp_action.luasnip_jump_backward(),
				}),
				snippet = {
					expand = function(args)
						-- vim.snippet.expand(args.body)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				--- (Optional) Show source name in completion menu
				-- formatting = cmp_format,
				formatting = {
					fields = {'abbr', 'kind', 'menu'},
					format = require('lspkind').cmp_format({
						mode = 'symbol', -- show only symbol annotations
						maxwidth = 50, -- prevent the popup from showing more than provided characters
						ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
					})
				},
			})
		end
	},
	-- Tresitter
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
	{
		'windwp/nvim-autopairs',
		event = { 'InsertEnter', 'CmdlineEnter' },
		config = function()
			require('nvim-autopairs').setup({
				enable_check_bracket_line = false,
				ignored_next_char = "[%w%.]",
			})
		end,
	},
})



-------------
-- Setting --
-------------

vim.opt.fileencoding = "UTF-8"

vim.opt.clipboard = "unnamedplus"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.title = true

vim.opt.shortmess = 'a'

vim.opt.lazyredraw = true

vim.opt.scrolloff = 4

vim.opt.cursorline = true

vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = '↳ '

vim.opt.equalalways = false
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true

-- These settings are great with auto-save.nvim. It makes it so you can't loose
-- code, it does increase the ammounts of write on your disk though so if
-- you're using a hard drive you might want to reconsider autosave
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.undolevels = 5000
vim.opt.undofile = true
vim.opt.autoread = true

-- Indentation
vim.opt.expandtab = false
vim.opt.smartindent = true

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Set indentation settings for haskell',
	pattern = '*.hs',
	callback = function()
		vim.opt.expandtab = true
		vim.opt.smartindent = true
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
	end,
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Set indentation settings for curly brace languages',
	pattern = { '*.c', '*.cpp','*.h','*.hpp','*.lua','*.js','*.php', '*.sh', '.y', '.yy', '.l', '.ll'},
	callback = function()
		vim.opt.expandtab = false
		vim.opt.cindent = true
		vim.opt.tabstop = 4
		vim.opt.shiftwidth = 4
	end,
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
	desc = 'Set indentation settings for web stuff',
	pattern = { '*.html', '*.css'},
	callback = function()
		vim.expandtab = false
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
	end,
})

-- color scheme
vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
-- vim.cmd.colorscheme("base16-tender") 	-- orange, red, yellow
vim.cmd.colorscheme("base16-danqing") -- orange, red, mauve
-- vim.cmd.colorscheme("base16-darcula")	-- orange, blue, green,


vim.api.nvim_create_autocmd('BufWritePre', {
	desc = 'Remove trailing spaces',
	-- pattern = '^(.*.diff)', -- for `git add -p` when you edit to remove '-' lines TODO: fix
	callback = function()
		vim.cmd([[%s/\s\+$//e]])
	end
})

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

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', '<esc>', '<cmd>noh<cr>', { noremap = true })
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<cr>')


-- Select All text in buffer
vim.keymap.set('n', '<c-a>', 'ggVG')

-- Save file
vim.keymap.set('n', '<c-w>', ':w<cr>')

-- Pass terminal mode to normal mode with escape
vim.keymap.set( 't', '<esc>', '<c-\\><c-n>')


-- Splits
vim.keymap.set("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<Leader>s", "<C-w>s", opt)
vim.keymap.set('n', '<Leader>t', ':vs |:terminal<cr>', opt) -- Conflicts with oil
vim.keymap.set('n', '<Leader>c', ':close<cr>', opt)

--Navigation
vim.keymap.set("n", "<Leader>h", "<C-w>h", opt)
vim.keymap.set("n", "<Leader>l", "<C-w>l", opt)
vim.keymap.set("n", "<Leader>j", "<C-w>j", opt)
vim.keymap.set("n", "<Leader>k", "<C-w>k", opt)

-- resize
vim.keymap.set('n', '<c-h>', '5<c-w>>', opt)
vim.keymap.set('n', '<c-j>', '5<c-w>+', opt)
vim.keymap.set('n', '<c-k>', '5<c-w>-', opt)
vim.keymap.set('n', '<c-l>', '5<c-w><', opt)
vim.keymap.set('n', '<c-e>', '5<c-w>=', opt)


-- Jump line depend on size of terminal windows
-- https://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
vim.keymap.set("n", "j", [[v:count ? "j" : "gj"]], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? "k" : "gk"]], { noremap = true, expr = true })

 -- Center cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('i', '<esc>', '<esc>l')
