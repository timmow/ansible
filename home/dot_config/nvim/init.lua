vim.cmd([[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
]])

-- require('mason.settings').set({
--  pip = {
--         -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
--         -- and is not recommended.
--         --
--         -- Example: { "--proxy", "https://proxyserver" }
--         install_args = {"--index-url", "https://pypi.python.org/simple"},
--     },
-- })

-- local lsp = require('lsp-zero')
-- lsp.set_preferences({
--   suggest_lsp_servers = true,
--   setup_servers_on_start = true,
--   set_lsp_keymaps = false,
--   configure_diagnostics = true,
--   cmp_capabilities = true,
--   manage_nvim_cmp = true,
--   call_servers = 'local',
--   sign_icons = {
--     error = '✘',
--     warn = '▲',
--     hint = '⚑',
--     info = ''
--   }
-- })

-- lsp.on_attach(function(client, bufnr)
--   local noremap = {buffer = bufnr, remap = false}
--   local bind = vim.keymap.set
-- 
--   -- hack - lsp and vim tmux navigator conflict so map this key again
--   bind('n', '<c-k>', ':TmuxNavigateUp<cr>', noremap)
-- end)
-- lsp.setup()

-- require'lspconfig'.pylsp.setup{}
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
  end


  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    }),
    
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
  --    { name = 'vsnip' }, -- For vsnip users.
      { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path',
        option = {
          trailing_slash = false
        },
      }
    },
    {
      { name = 'cmdline'
      },
    })
  })

  require("mason").setup()
  require("mason-lspconfig").setup()
  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.

  local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'

if not configs.pyls then
configs.pyls = {

  default_config = {
    cmd = { 'pyls' },
    filetypes = { 'python' },
    root_dir = function(fname)
      return vim.fn.getcwd()
    end,
  },
  docs = {
    package_json = 'https://raw.githubusercontent.com/palantir/python-language-server/develop/vscode-client/package.json',
    description = [[
https://github.com/palantir/python-language-server
`python-language-server`, a language server for Python.
The language server can be installed via `pipx install 'python-language-server[all]'`.
    ]],
    default_config = {
      root_dir = "vim's starting directory",
    },
  },
}
end
  lspconfig['pyls'].setup {}

  require('lspconfig').pyls.setup {
    cmd = { 'pyls' },
    filetypes = { 'python' },
    root_dir = function(fname)
      return vim.fn.getcwd()
    end,
  }
require('lspconfig')['jsonnet_ls'].setup {
  on_attach = on_attach,
  cmd = {
    'jsonnet-language-server',
    '--tanka',
    '--eval-diag',
    }
  }
require("trouble").setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}
