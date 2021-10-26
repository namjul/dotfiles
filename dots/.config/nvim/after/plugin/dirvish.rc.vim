
command! -nargs=? -complete=dir Explore Dirvish <args>
command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>

let g:dirvish_mode = ':sort ,^.*[\/],'

" call dirvish#add_icon_fn({p -> p[-1:]=='/'?'  ':'  '})
