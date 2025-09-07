local vi = vim.v.progname == 'vi'

-- Leader key ===
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- General ===
vim.opt.backup = false -- Don't make backups before writing
vim.opt.writebackup = false -- Don't store backup (better performance)
vim.opt.undofile = true -- Enable persistend undo
vim.opt.mouse = 'a' -- Enable Mouse clicking
vim.opt.switchbuf = 'usetab' -- try to reuse windows/tabs when switching buffers
vim.opt.swapfile = false -- don't create swap files
-- vim.opt.updatetime = 250 -- Decrease update time (CursorHold interval)
-- vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time
-- vim.opt.updatecount = 0 -- update swapfiles every 80 typed chars
vim.opt.visualbell = true -- stop annoying beeping for non-error errors

vim.o.shada        = "'100,<50,s10,:1000,/100,@100,h" -- Limit what is stored in ShaDa file

vim.cmd('filetype plugin indent on') -- Enable filetype detection, plugins, and indentation

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)


-- UI ===
vim.opt.guifont = 'JetBrainsMono Nerd Font'
vim.opt.cursorline = true -- highlight current line
vim.opt.emoji = false -- don't assume all emoji are double width
vim.opt.fillchars = {
  diff = '∙', -- BULLET OPERATOR (U+2219, UTF-8: E2 88 99)
  eob = ' ', -- NO-BREAK SPACE (U+00A0, UTF-8: C2 A0) to suppress ~ at EndOfBuffer
  fold = '·', -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
  vert = ' ', -- BOX DRAWINGS LIGHT VERTICAL (U+2502, UTF-8: E2 94 82)
} -- NOTE { 'eob: ', 'fold:╌', 'horiz:═', 'horizdown:╦', 'horizup:╩', 'vert:║', 'verthoriz:╬', 'vertleft:╣', 'vertright:╠' }
vim.opt.listchars = {
  nbsp = '⦸', -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
  extends = '»', -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
  precedes = '«', -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
  tab = '»·', -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + MIDLINE HORIZONTAL ELLIPSIS (U+22EF, UTF-8: E2 8B AF)
  trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
}
vim.opt.termguicolors = true -- use guifg/guibg instead of ctermfg/ctermbg in terminal
vim.o.winborder = 'double' -- Use double-line as default border
vim.opt.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
vim.o.list = true -- Show helpful character indicators (like whitespace)
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- show relative numbers in gutter
vim.opt.pumheight = 10 -- max number of lines to show in pop-up menu
vim.opt.scrolloff = 3 -- start scrolling 3 lines before edge of viewport
vim.opt.shortmess = vim.opt.shortmess + 'A' -- ignore annoying swapfile messages
vim.opt.shortmess = vim.opt.shortmess + 'I' -- no splash screen
vim.opt.shortmess = vim.opt.shortmess + 'O' -- file-read message overwrites previous
vim.opt.shortmess = vim.opt.shortmess + 'T' -- truncate non-file messages in middle
vim.opt.shortmess = vim.opt.shortmess + 'W' -- don't echo "[w]"/"[written]" when writing
vim.opt.shortmess = vim.opt.shortmess + 'a' -- use abbreviations in messages eg. `[RO]` instead of `[readonly]`
vim.opt.shortmess = vim.opt.shortmess + 'c' -- completion messages
vim.opt.shortmess = vim.opt.shortmess + 'o' -- overwrite file-written messages
vim.opt.shortmess = vim.opt.shortmess + 't' -- truncate file messages at start
vim.opt.showbreak = '↳ ' -- DOWNWARDS ARROW WITH TIP RIGHTWARDS (U+21B3, UTF-8: E2 86 B3)
vim.opt.showmode = false -- Don't show the mode, since it's already in the status line
vim.opt.sidescroll = 0 -- sidescroll in jumps because terminals are slow
vim.opt.sidescrolloff = 3 -- same as scrolloff, but for columns
vim.opt.splitright = true -- open vertical splits to the right of the current window
vim.opt.splitbelow = true -- open horizontal splits below current window
vim.o.wrap = false -- Display long lines as just one line
vim.opt.background = 'light'

require('gruvbox').setup()
vim.cmd('colorscheme gruvbox')

if vim.fn.filereadable(vim.fn.expand('~/.vimrc_background')) ~= 0 then
  vim.cmd('source ~/.vimrc_background')
end

-- Colors ===

-- Editing ===
vim.opt.autoindent = true -- maintain indent of current line
vim.opt.completeopt = 'menu' -- show completion menu (for nvim-cmp)
vim.opt.completeopt = vim.opt.completeopt + 'menuone' -- show menu even if there is only one candidate (for nvim-cmp)
vim.opt.completeopt = vim.opt.completeopt + 'noselect' -- don't automatically select canditate (for nvim-cmp)
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.ignorecase = true -- Ignore case when searching (use `\C` to force not doing that)
vim.opt.hidden = true -- allows you to hide buffers with unsaved changes without being prompted
vim.opt.ignorecase = true -- ignore case in searches
vim.opt.joinspaces = false -- don't autoinsert two spaces after '.', '?', '!' for join command
vim.opt.laststatus = 2 -- always show status line
vim.opt.lazyredraw = true -- don't bother updating screen during macro playback
vim.opt.modelines = 5 -- scan this many lines looking for modeline
vim.opt.shiftround = false -- don't always indent by multiple of shiftwidth
vim.opt.smartcase = true -- don't ignore case in searches if uppercase characters present
vim.opt.smarttab = true -- <tab>/<BS> indent/dedent in leading whitespace
vim.opt.smartindent = true -- Make indenting smart
vim.opt.tabstop = 2 -- spaces per tab
if not vi then
  vim.opt.softtabstop = -1 -- use 'shiftwidth' for tab/bs at end of line
end
vim.opt.virtualedit = 'block' -- Allow going past the end of line in visual block mode
-- vim.opt.whichwrap = 'b,h,l,s,<,>,[,],~' -- allow <BS>/h/l/<Left>/<Right>/<Space>, ~ to cross line boundaries
-- vim.opt.wildcharm = 26 -- ('<C-z>') substitute for 'wildchar' (<Tab>) in macros
-- vim.opt.wildignore = vim.opt.wildignore + '*.o,*.rej,*.so' -- patterns to ignore during file-navigation
-- vim.opt.wildmenu = true -- show options as list when switching buffers etc
-- vim.opt.wildmode = 'longest:full,full' -- shell-like autocomplete to unambiguous portion
vim.opt.gdefault = true -- Add the g flag to search/replace by default

-- Spelling ===
-- -- vim.opt.spellcapcheck = '' -- don't check for capital letters at start of sentence

-- Keyboard layout ===
--
-- Folds ===
vim.opt.foldlevelstart = 99 -- start unfolded
vim.opt.foldmethod = 'indent' -- not as cool as syntax, but faster
-- vim.opt.foldtext = 'v:lua.wincent.foldtext()'
-- vim.opt.formatoptions = vim.opt.formatoptions + 'j' -- remove comment leader when joining comment lines
-- vim.opt.formatoptions = vim.opt.formatoptions + 'n' -- smart auto-indenting inside numbered lists

-- Custom autocommands ===
-- Diagnostics ===
