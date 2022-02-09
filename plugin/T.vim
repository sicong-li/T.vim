"/home/lisicong/.vim/plugged/T.vim

" SECTION: set constant var{{{1
" SECTION: define hight char{{{2
let g:TWordWrapChar = 64
let g:TPhoneticWrapChar = 94
let g:TStarWrapChar = 96
let g:TContentWrapChar = 124


" SECTION: define the display attributes{{{2
let g:SplitMethod = 'vsplit'
let g:TWinSize = 50
let g:ShowLog = 0
let g:UseGrep = 1
let g:displayRecentNum = 5
let g:totalRecentNum = 100

" SECTION: mapping{{{1
"call T#Map()

"command! -n=0 T :call T#Main('<cword>')
"nnoremap <leader>t :call T#Main(expand('<cword>'))<cr>
