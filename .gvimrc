colorscheme solarized
set background=light

" set font for each system
let os = substitute(system('uname'), '\n', '', '')
if os == 'Darwin' || os == 'Mac'
  " MacVim-specific settings go here
  set guifont=DejaVu_Sans_Mono_for_Powerline:h14
elseif os == 'Linux'        
  " GVim-specific settings go here
  set guifont=Monaco\ for\ Powerline\ 11
endif

set linespace=6
set antialias
set guioptions-=m  "menu bar
set guioptions-=T  "toolbar
set guioptions-=r  "scrollbar
set guioptions-=L  "scrollbar
