-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/nam/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/nam/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/nam/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/nam/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/nam/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  MatchTagAlways = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/MatchTagAlways"
  },
  ale = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/ale"
  },
  ["auto-pairs"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/auto-pairs"
  },
  ["bullets.vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/bullets.vim"
  },
  ["committia.vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/committia.vim"
  },
  ["deoplete.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/deoplete.nvim"
  },
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/editorconfig-vim"
  },
  fzf = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/fzf"
  },
  ["gist-vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/gist-vim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["glow.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/glow.nvim"
  },
  ["goyo.vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/goyo.vim"
  },
  ["gruvbox.nvim"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\24colorscheme gruvbox\bcmd\bvim\0" },
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/gruvbox.nvim"
  },
  ["lens.vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/lens.vim"
  },
  loupe = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/loupe"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/lush.nvim"
  },
  neoterm = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/neoterm"
  },
  ["notational-fzf-vim"] = {
    loaded = true,
    needs_bufread = false,
    path = "/home/nam/.local/share/nvim/site/pack/packer/opt/notational-fzf-vim"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua"
  },
  ["nvim-luapad"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/nvim-luapad"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-ts-autotag"] = {
    config = { "\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\20nvim-ts-autotag\frequire\0" },
    loaded = true,
    needs_bufread = false,
    path = "/home/nam/.local/share/nvim/site/pack/packer/opt/nvim-ts-autotag"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  pinnacle = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/pinnacle"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  scalpel = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/scalpel"
  },
  tabular = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/tabular"
  },
  tcomment_vim = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/tcomment_vim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim"
  },
  ["telescope-fzf-writer.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/telescope-fzf-writer.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["trailertrash.vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/trailertrash.vim"
  },
  ultisnips = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/ultisnips"
  },
  ["vim-cutlass"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-cutlass"
  },
  ["vim-dirvish"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-dirvish"
  },
  ["vim-flog"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-flog"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-highlightedyank"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-highlightedyank"
  },
  ["vim-markdown"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-markdown"
  },
  ["vim-node"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-node"
  },
  ["vim-numbertoggle"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-numbertoggle"
  },
  ["vim-obsession"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-obsession"
  },
  ["vim-polyglot"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-polyglot"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-rhubarb"
  },
  ["vim-sensible"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-sensible"
  },
  ["vim-snippets"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-snippets"
  },
  ["vim-subversive"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-subversive"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-unimpaired"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-unimpaired"
  },
  ["vim-yoink"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vim-yoink"
  },
  vimpeccable = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vimpeccable"
  },
  vimux = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vimux"
  },
  ["vimux-jest-test"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/vimux-jest-test"
  },
  ["webapi-vim"] = {
    loaded = true,
    path = "/home/nam/.local/share/nvim/site/pack/packer/start/webapi-vim"
  },
  winresizer = {
    loaded = true,
    needs_bufread = false,
    path = "/home/nam/.local/share/nvim/site/pack/packer/opt/winresizer"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: winresizer
time([[Setup for winresizer]], true)
try_loadstring("\27LJ\2\n<\0\0\2\0\4\0\0056\0\0\0009\0\1\0'\1\3\0=\1\2\0K\0\1\0\n<C-T>\25winresizer_start_key\6g\bvim\0", "setup", "winresizer")
time([[Setup for winresizer]], false)
time([[packadd for winresizer]], true)
vim.cmd [[packadd winresizer]]
time([[packadd for winresizer]], false)
-- Setup for: notational-fzf-vim
time([[Setup for notational-fzf-vim]], true)
try_loadstring("\27LJ\2\n±\1\0\0\2\0\6\0\t6\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0005\1\5\0=\1\4\0K\0\1\0\1\3\0\0\vassets\t.git\22nv_ignore_pattern\1\5\0\0\27~/Dropbox/dendron/wiki\22~/Dropbox/journal\20~/Dropbox/notes\21~/Dropbox/drafts\20nv_search_paths\6g\bvim\0", "setup", "notational-fzf-vim")
time([[Setup for notational-fzf-vim]], false)
time([[packadd for notational-fzf-vim]], true)
vim.cmd [[packadd notational-fzf-vim]]
time([[packadd for notational-fzf-vim]], false)
-- Config for: gruvbox.nvim
time([[Config for gruvbox.nvim]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\24colorscheme gruvbox\bcmd\bvim\0", "config", "gruvbox.nvim")
time([[Config for gruvbox.nvim]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
