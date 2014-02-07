colorscheme solarized
set background=light
set guifont=Menlo:h14
"set guifont=Monaco:h14
set linespace=8
set antialias

set guioptions-=T " No toolbar
set guioptions-=r " No scrollbars
set guioptions-=m " remove menubar 
set go-=L " Removes left hand scroll bar

if has("gui_macvim")
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert
end
