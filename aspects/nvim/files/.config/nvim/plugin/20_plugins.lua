local minideps = require('mini.deps')
local add, now, later = minideps.add, minideps.now, minideps.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

-- Step one ===
add({ name = 'mini.nvim' })

now(function()
  require('mini.basics').setup({
    options = { basic = false }, -- Manage options manually in a spirit of transparency
    mappings = { windows = false, move_with_alt = true, option_toggle_prefix = [[yo]] },
  })
end)

now(function() require('mini.icons').setup() end)

now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify()
end)

now(function() require('mini.statusline').setup() end)

now(function() require('mini.tabline').setup({ tabpage_section = 'right' }) end)

now_if_args(function()
  -- TODO
  -- if vim.fn.filereadable('/usr/local/bin/python3') == 1 then
  --   -- Avoid search, speeding up start-up.
  --   vim.g.python3_host_prog = '/usr/local/bin/python3'
  -- end

  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Use 'master' while monitoring updates in 'main'
    checkout = 'master',
    monitor = 'main',
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  -- add('nvim-treesitter/nvim-treesitter-textobjects')
  add('nvim-treesitter/nvim-treesitter-context')

  require('nvim-treesitter.configs').setup({

    modules = {},

    ignore_install = {},

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = { 'markdown' },
    },
    -- Indentation based on treesitter for the = operator. NOTE: This is an experimental feature.
    indent = { enable = true, disable = { 'python' } },
    ensure_installed = {
      'tsx',
      'typescript',
      'javascript',
      'toml',
      'fish',
      'markdown',
      'bash',
      'rust',
      'php',
      'json',
      'http',
      'graphql',
      'yaml',
      'html',
      'lua',
      'scss',
      'css',
      'glimmer',
      'mermaid',
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-m>',
        node_incremental = '<c-m>',
        scope_incremental = '<c-s>',
        node_decremental = '<c-n>',
      },
      -- fix from https://github.com/nvim-treesitter/nvim-treesitter/issues/2634#issuecomment-1362479800
      is_supported = function()
        local ct = vim.fn.getcmdwintype()
        if ct ~= '' then return false end
        return true
      end,
    },
  })

  vim.treesitter.language.register('markdown', 'mdx') -- the someft filetype will use the python parser and queries.
end)

now_if_args(function()
  local minifiles = require('mini.files')
  minifiles.setup({
    windows = { preview = true },

    mappings = {
      go_in = 'L',
      go_in_plus = '<CR>',
      go_out = '-',
      go_out_plus = '',
    },

    options = {
      use_as_default_explorer = true,
    },
  })

  local set_cwd = function()
    local path = (minifiles.get_fs_entry() or {}).path
    if path == nil then return vim.notify('Cursor is not on valid entry') end
    vim.fn.chdir(vim.fs.dirname(path))
  end

  -- Yank in register full path of entry under cursor
  local yank_path = function()
    local path = (minifiles.get_fs_entry() or {}).path
    if path == nil then return vim.notify('Cursor is not on valid entry') end
    vim.fn.setreg(vim.v.register, path)
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      local b = args.data.buf_id
      -- TODO add keymap to navigate to cwd
      vim.keymap.set('n', 'cd', set_cwd, { buffer = b, desc = 'Set cwd' })
      vim.keymap.set('n', 'gy', yank_path, { buffer = b, desc = 'Yank path' })
    end,
  })

  local dotfiles_augroup = vim.api.nvim_create_augroup('dotfiles', {})
  vim.api.nvim_create_autocmd('User', {
    group = dotfiles_augroup,
    pattern = 'MiniFilesExplorerOpen',
    callback = function()
      minifiles.set_bookmark('d', vim.fs.normalize('~/.dotfiles'), { desc = 'Dotfiles' })
      minifiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
      minifiles.set_bookmark('p', vim.fn.stdpath('data') .. '/site/pack/deps/opt', { desc = 'Plugins' })
      minifiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
      minifiles.set_bookmark('m', vim.fs.normalize('~/Dropbox/memex/'), { desc = 'Memex' })
    end,
  })

  -- currently not possible: https://github.com/nvim-mini/mini.nvim/discussions/2025#discussioncomment-14515019
  --
  -- local capabilities = {
  --   willRenameFiles = 'willRename',
  --   willCreateFiles = 'willCreate',
  --   willDeleteFiles = 'willDelete',
  -- }
  --
  -- local miniEvents = {
  --   willRenameFiles = { 'MiniFilesActionRename' },
  --   willCreateFiles = { 'MiniFilesActionCreate' },
  --   willDeleteFiles = { 'MiniFilesActionDelete' },
  -- }
  --
  -- local function setup_events(subscribe)
  --   for capability in pairs(capabilities) do
  --     subscribe(capability, miniEvents[capability])
  --   end
  -- end
  --
  -- local lsp_file_operations_augroup = vim.api.nvim_create_augroup('mini-lsp-file-operations', {})
  -- setup_events(function(capability, event)
  --   vim.api.nvim_create_autocmd('User', {
  --     group = lsp_file_operations_augroup,
  --     pattern = event,
  --     callback = function(args)
  --       local clients = vim.lsp.get_clients()
  --       local method = 'workspace/' .. capability
  --       local operation = capabilities[capability]
  --
  --       -- Check if any client supports this operation
  --       local has_support = false
  --       for _, client in ipairs(clients) do
  --         local caps = client.server_capabilities
  --         if caps.workspace and caps.workspace.fileOperations and caps.workspace.fileOperations[operation] then
  --           has_support = true
  --           break
  --         end
  --       end
  --
  --       if not has_support then return end
  --
  --       -- Build params
  --       local params = { files = {} }
  --
  --       if capability == 'willRenameFiles' then
  --         table.insert(params.files, {
  --           oldUri = vim.uri_from_fname(args.data.from),
  --           newUri = vim.uri_from_fname(args.data.to),
  --         })
  --       else
  --         table.insert(params.files, {
  --           uri = vim.uri_from_fname(args.data.path),
  --         })
  --       end
  --
  --       -- Send to all supporting clients
  --       for _, client in ipairs(clients) do
  --         local caps = client.server_capabilities
  --         if caps.workspace and caps.workspace.fileOperations and caps.workspace.fileOperations[operation] then
  --           client.request(method, params, function(err, result)
  --             print('vim.lsp.util.apply_workspace_edit', result, client.offset_encoding)
  --             if result then vim.lsp.util.apply_workspace_edit(result, client.offset_encoding) end
  --           end)
  --         end
  --       end
  --     end,
  --   })
  -- end)
end)

-- Step two ===
later(function() require('mini.extra').setup() end)

later(function() require('mini.bracketed').setup() end)

later(function() require('mini.bufremove').setup() end)

later(function() require('mini.cursorword').setup() end)

later(function() require('mini.move').setup() end)

later(function()
  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },

      -- `[` and `]` keys
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },

      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },

      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end)

later(function()
  local minimisc = require('mini.misc')
  minimisc.setup()
  minimisc.setup_auto_root({ '.git', 'Makefile', '.hg' })
end)

later(function()
  require('mini.diff').setup({
    view = {
      style = 'sign',
    },
  })
end)

later(function()
  local map_multistep = require('mini.keymap').map_multistep
  map_multistep('i', '<CR>', { 'minipairs_cr' })
  map_multistep('i', '<BS>', { 'hungry_bs', 'minipairs_bs' })
end)

later(function()
  require('mini.surround').setup({
    mappings = {
      add = 'sa', -- Add surrounding in Normal and Visual modes
      delete = 'sd', -- Delete surrounding
      find = 'sf', -- Find surrounding (to the right)
      find_left = 'sF', -- Find surrounding (to the left)
      highlight = 'sh', -- Highlight surrounding
      replace = 'sr', -- Replace surrounding
      update_n_lines = 'sn', -- Update `n_lines`
      suffix_last = 'l', -- Suffix to search with "prev" method
      suffix_next = 'n', -- Suffix to search with "next" method
    },
  })
end)

later(function() require('mini.indentscope').setup() end)

later(function() require('mini.ai').setup() end)

later(function() require('mini.pairs').setup() end)

later(function() require('mini.trailspace').setup() end)

later(function() require('mini.operators').setup() end)

later(function() require('mini.splitjoin').setup() end)

later(function() require('mini.jump').setup() end)

later(function() require('mini.git').setup() end)

later(function()
  local hipatterns = require('mini.hipatterns')
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = '[Xx][Xx][Xx]', group = 'MiniHipatternsFixme' },
      hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
      todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
      note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Install LSP/formatting/linter executables ===
later(function() add('mason-org/mason.nvim') end)

-- Language server configurations ===
later(function()
  add('neovim/nvim-lspconfig')
  add('mason-org/mason-lspconfig.nvim')
  add('WhoIsSethDaniel/mason-tool-installer.nvim')
  namjul.lsp.init()
end)

-- Linting ===
later(function()
  add('mfussenegger/nvim-lint')

  local function find_nodemodules_bin(binary_name)
    local current_dir = vim.fn.getcwd()

    local matcher = function(dir)
      local binary_path = dir .. '/node_modules/.bin/' .. binary_name
      if vim.fn.filereadable(binary_path) == 1 then return binary_path end
      return nil
    end

    local start_match = matcher(current_dir)
    if start_match then return start_match end

    for path in vim.fs.parents(current_dir) do
      local match = matcher(path)
      if match then return match end
    end

    return nil -- Not found
  end

  local get_lsp_client = function()
    -- Get lsp client for current buffer
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if next(clients) == nil then return nil end

    for _, client in pairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then return client end
    end

    return nil
  end

  local has_lint, lint = pcall(require, 'lint')
  if has_lint then
    local linters = {
      eslint = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'vue',
      },
    }

    local eslint = require('lint').linters.eslint
    eslint.cmd = function()
      local binary_name = 'eslint'
      local local_binary = find_nodemodules_bin(binary_name)
      return local_binary or binary_name
    end

    -- register each linter by filetype
    for linter, filetypes in pairs(linters) do
      for _, ft in ipairs(filetypes) do
        lint.linters_by_ft[ft] = { linter }
      end
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable then
          local client = get_lsp_client() or {}
          -- check if linter is is available
          for linter in pairs(linters) do
            if vim.fn.executable(lint.linters[linter].cmd()) == 1 then
              lint.try_lint(linter, { cwd = client.root_dir }) -- `try_lint` includes a filetypecheck which `lint.try_lint(linter)` does not
            end
          end
        end
      end,
    })
  end
end)

later(function()
  add('wincent/shannon')
  require('wincent.shannon').setup({
    keymaps = true,
    prefix = '<Localleader>s',
    agents = { 'pi', 'claude' },
  })
end)

-- Formatting ===
later(function()
  add('stevearc/conform.nvim')

  ---@param bufnr integer
  ---@param ... string
  ---@return string
  local function first(bufnr, ...)
    local conform = require('conform')
    for i = 1, select('#', ...) do
      local formatter = select(i, ...)
      if conform.get_formatter_info(formatter, bufnr).available then return formatter end
    end
    return select(1, ...)
  end

  require('conform').setup({
    notify_on_error = true,
    format_on_save = true,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = function(bufnr)
        if require('conform').get_formatter_info('ruff_format', bufnr).available then
          return { 'ruff_format' }
        else
          return { 'isort', 'black' }
        end
      end,
      javascript = function(bufnr) return { first(bufnr, 'deno', 'biome', 'prettierd', 'prettier') } end,
      typescript = function(bufnr) return { first(bufnr, 'deno', 'biome', 'prettierd', 'prettier') } end,
      vue = function(bufnr) return { first(bufnr, 'biome', 'prettierd', 'prettier') } end,
    },
  })
end)

-- Git: fugitive ===
later(function()
  add('tpope/vim-fugitive')
  add('shumphrey/fugitive-gitlab.vim') -- open files on gitlab
  vim.g.fugitive_gitlab_domains = { 'https://gitlab.tools.wienfluss.net/' }
end)

later(function()
  local build = function() vim.fn['mkdp#util#install']() end
  add({
    source = 'iamcco/markdown-preview.nvim',
    hooks = {
      post_install = function() later(build) end,
      post_checkout = build,
    },
  })
  -- Do not close the preview tab when switching to other buffers
  vim.g.mkdp_auto_close = 0
end)

now(function()
  add('ellisonleao/gruvbox.nvim')
  vim.cmd('colorscheme custom_gruvbox')
end)

later(function()
  add('tpope/vim-abolish')
  vim.cmd([[
  Abolish teh the
  Abolish functoin function
  Abolish fucnton function
  Abolish fucntion function
  Abolish fuction function
  Abolish sord sort
]])
end)

later(function() add('andreshazard/vim-freemarker') end)

-- seperate `cut` form `delete`
later(function() add('svermeulen/vim-cutlass') end)

-- support editor config files (https://editorconfig.org/)
later(function() add('tpope/vim-sleuth') end)

later(function()
  add('windwp/nvim-ts-autotag')
  require('nvim-ts-autotag').setup()
end)

later(function() require('namjul/translator') end)

later(function()
  add('TobinPalmer/pastify.nvim')
  require('pastify').setup({
    opts = {
      absolute_path = false, -- use absolute or relative path to the working directory
      local_path = './assets/images', -- The path to put local files in, ex <cwd>/assets/images/<filename>.png
      save = 'local', -- Either 'local' or 'online' or 'local_file'
      filename = function()
        vim.fn.inputsave()
        local name = vim.fn.input('Name: ')
        vim.fn.inputrestore()
        return name
      end,
      default_ft = 'markdown', -- Default filetype to use
    },
  })
end)

later(function()
  add({ source = 'saghen/blink.cmp', checkout = 'v1.6.0' })
  require('blink.cmp').setup({
    snippets = { preset = 'luasnip' },
    keymap = {
      preset = 'none',
      ['<C-o>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
      ['<C-n>'] = {
        function(cmp)
          if cmp.is_menu_visible() then
            cmp.select_next()
          else
            cmp.accept()
          end
        end,
      },
    },
    sources = {
      providers = {
        snippets = {
          score_offset = 10,
        },
      },
    },
    completion = {
      menu = {
        border = 'none',
        auto_show = false, -- only show menu on manual <C-space>
      },
      documentation = { window = { border = 'double' } },
      ghost_text = {
        enabled = true,
        show_with_menu = false, -- only show when menu is closed
      },
    },
    signature = { window = { border = 'double' } },
  })
end)

later(function()
  add('nvim-tree/nvim-tree.lua')
  namjul.plugin.lazy('nvim-tree.lua', {
    afterload = function()
      require('nvim-tree').setup({
        actions = {
          open_file = {
            window_picker = { enable = false },
          },
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              git = false,
              folder = false,
              folder_arrow = false,
            },
          },
          special_files = {
            enable = false,
          },
        },
        git = {
          enable = false,
        },
      })
    end,
    commands = {
      'NvimTreeFindFile',
      'NvimTreeToggle',
      'NvimTreeOpen',
    },
    keymap = {
      { 'n', '<LocalLeader>f', ':NvimTreeFindFile<CR>', { silent = true } },
      { 'n', '<LocalLeader>t', ':NvimTreeToggle<CR>', { silent = true } },
    },
  })
end)

later(function()
  add('yousefakbar/notmuch.nvim')
  namjul.plugin.lazy('notmuch.nvim', {
    afterload = function()
      require('notmuch').setup({
        notmuch_db_path = '/home/hobl/.mail',
      })
    end,
    commands = {
      'Notmuch',
    },
  })
end)

later(function()
  add({ source = 'stevearc/overseer.nvim', checkout = 'v1.6.0' })
  namjul.plugin.lazy('overseer.nvim', {
    afterload = function() require('overseer').setup() end,
    commands = {
      'OverseerRun',
      'OverseerOpen',
      'OverseerToggle',
    },
    keymap = {
      { 'n', 'yot', 'OverseerToggle', { silent = true, desc = 'Task runner' } },
    },
  })
end)

later(function()
  add('mbbill/undotree')
  namjul.plugin.lazy('undotree', {
    beforeload = function()
      vim.g.undotree_HighlightChangedText = 0
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_DiffCommand = 'diff -u'
    end,
    keymap = {
      { 'n', 'you', ':UndotreeToggle', { silent = true } },
    },
  })
end)

-- Snippet collection =========================================================
later(function()
  add({ source = 'L3MON4D3/LuaSnip', checkout = 'v2.4.0' })
  -- Tell LuaSnip to load on demand based on file-type.
  require('luasnip.loaders.from_lua').load({
    lazy_paths = { '~/.config/nvim/lua/namjul/snippets' },
    -- paths = {"~/.config/nvim/lua/namjul/snippets"}
  })
end)

later(function()
  local minipick = require('mini.pick')
  minipick.setup()
  vim.ui.select = minipick.ui_select

  local miniextra = require('mini.extra')

  minipick.registry.projects = function()
    local cwd = vim.fn.expand('~/code')
    local choose = function(item)
      vim.schedule(function() minipick.builtin.files(nil, { source = { cwd = item.path } }) end)
    end
    return miniextra.pickers.explorer({ cwd = cwd }, { source = { choose = choose } })
  end

  minipick.registry.dotfiles = function()
    local cwd = vim.fn.expand('~/.dotfiles')
    return MiniPick.builtin.files(nil, { source = { cwd = cwd } })
  end

  minipick.registry.memex = function()
    local cwd = vim.fn.expand('~/Dropbox/memex')
    -- local mappings = { wipeout = { char = '<C-d>', func = function ()
    --   print('TODO: https://github.com/nvim-telescope/telescope-live-grep-args.nvim')
    -- end  } }
    -- return MiniExtra.pickers.cli({ cwd = cwd }, { mappings = mappings })
    return miniextra.pickers.explorer({ cwd = cwd })
  end
end)

later(function() require('mini.visits').setup() end)

later(function()
  add({
    source = 'ThePrimeagen/harpoon',
    checkout = 'harpoon2',
    depends = { 'nvim-lua/plenary.nvim' },
  })

  local harpoon = require('harpoon').setup()

  vim.keymap.set('n', '<Leader>ha', function() harpoon:list():add() end, { desc = 'Add file to harpoon' })
  vim.keymap.set(
    'n',
    '<Leader>hl',
    function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
    { desc = 'Toggle harpoon menu' }
  )
  vim.keymap.set('n', '<C-h>', function() harpoon:list():select(1) end, { desc = 'Harpoon: Goto(1)' })
  vim.keymap.set('n', '<C-j>', function() harpoon:list():select(2) end, { desc = 'Harpoon: Goto(2)' })
  vim.keymap.set('n', '<C-k>', function() harpoon:list():select(3) end, { desc = 'Harpoon: Goto(3)' })
  vim.keymap.set('n', '<C-l', function() harpoon:list():select(4) end, { desc = 'Harpoon: Goto(4)' })
end)

-- Better built-in terminal ===
later(function()
  add('kassio/neoterm')

  -- Enable bracketed paste
  vim.g.neoterm_bracketed_paste = 1

  -- Don't add extra call to REPL when sending
  vim.g.neoterm_direct_open_repl = 1

  -- Open terminal to the right by default
  vim.g.neoterm_default_mod = 'vertical'

  -- Go into insert mode when terminal is opened
  vim.g.neoterm_autoinsert = 1

  -- Scroll to recent command when it is executed
  vim.g.neoterm_autoscroll = 1

  -- Don't automap keys
  pcall(vim.keymap.del, 'n', ',tt')
end)

-- later(function () add({
--   source = 'subnut/nvim-ghost.nvim',
--   checkout = 'main'
-- }) end)

later(function()
  add('MeanderingProgrammer/render-markdown.nvim')
  vim.api.nvim_set_hl(0, 'MarkdownHighlight', { bg = '#FBF719' })
  require('render-markdown').setup({
    inline_highlight = {
      enabled = true,
      highlight = 'MarkdownHighlight',
    },
  })
end)

later(function()
  local build = function(pkg)
    print('shellbot', vim.inspect(pkg.path))
    vim.system({ 'cargo', 'build', '--release' }, { cwd = pkg.path })
  end
  add({
    source = 'wincent/shellbot',
    checkout = 'wincent',
    hooks = {
      post_install = function(path)
        later(function() build(path) end)
      end,
      post_checkout = build,
    },
  })

  local has_shellbot, shellbot = pcall(require, 'chatbot')

  if has_shellbot then
    local function get_executable()
      local executable = vim.fn.split((vim.env['SHELLBOT'] or '/dev/null'), ' ')[1]
      print('executable', executable)
      if executable and vim.fn.executable(executable) == 1 then
        return executable
      else
        vim.api.nvim_echo(
          { {
            'error: $SHELLBOT does not appear to be executable',
            'ErrorMsg',
          } },
          true,
          {}
        )
      end
    end

    vim.api.nvim_create_user_command('ChatGPT', function()
      local executable = get_executable()
      if executable then shellbot.chatbot({
        OPENAI_API_KEY = vim.env.OPENAI_API_KEY,
      }) end
    end, {})

    -- Set up an autocmd to stop me from accidentally quitting vim when shellbot is
    -- the only thing running in it. I do this all the time, losing valuable state.
    vim.api.nvim_create_autocmd('QuitPre', {
      pattern = '*',
      callback = function()
        local buftype = vim.bo.buftype
        local filetype = vim.bo.filetype
        local win_count = #vim.api.nvim_tabpage_list_wins(0)

        if filetype == 'shellbot' and buftype == 'nofile' and win_count == 1 then
          vim.notify(
            '\n'
              .. '┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\n'
              .. '┃ Use :q! if you really want to quit the last shellbot window ┃\n'
              .. '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n'
              .. '\n',
            vim.log.levels.WARN
          )

          -- Will make Neovim abort the quit with:
          --
          --    E37: No write since last change
          --    E162: No write since last change for buffer "[No Name]"
          --
          vim.bo.buftype = ''
        end
      end,
    })
  else
    local print_error = function() vim.notify('error: SHELLBOT does not appear to be executable', vim.log.levels.ERROR) end
    vim.api.nvim_create_user_command('ChatGPT', print_error, {})
  end
end)

later(function()
  add({
    source = 'apple/pkl-neovim',
    hooks = { post_install = function() vim.cmd('TSInstall pkl') end },
  })
  -- Configure pkl-lsp
  vim.g.pkl_neovim = {
    start_command = { 'pkl-lsp' },
  }

  -- -- Pfad zum Mason-Binary ermitteln
  -- local mason_bin = vim.fn.stdpath('data') .. '/mason/bin/pkl-lsp'
  --
  -- -- Globale Variable für das Plugin setzen
  -- vim.g.pkl_neovim = {
  --   start_command = { mason_bin },
  --   -- Optional: Pfad zum Pkl CLI (falls ebenfalls über Mason installiert)
  --   pkl_cli_path = vim.fn.stdpath('data') .. '/mason/bin/pkl',
  -- }

  require('pkl-neovim').init()
end)

later(function()
  add('sindrets/diffview.nvim')
  namjul.plugin.lazy('diffview.nvim', {
    commands = {
      'DiffviewOpen',
      'DiffviewFileHistory',
      'DiffviewClose',
    },
    keymap = {
      { 'n', 'yod', ':DiffviewOpen<CR>', { silent = true } },
    },
  })
end)

-- add('navarasu/onedark.nvim')
-- add('rafcamlet/nvim-luapad')
-- add('folke/neodev.nvim')
-- add('rest-nvim/rest.nvim') -- http client in neovim
-- add('monaqa/dial.nvim') -- enhanced increment/decrement plugin for Neovim.
-- add('wsdjeg/vim-fetch') -- enables to process line and column jump specifications
-- add('andrewferrier/debugprint.nvim')
-- add('michaelb/sniprun', build = './install.sh')
-- add('MunifTanjim/nui.nvim')
