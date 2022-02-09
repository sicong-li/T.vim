
" ^ 94, | 124, ` 96, @ 64, 
" ^word^
syntax match conceal64  #\%d64# conceal
syntax match conceal94  #\%d94# conceal
syntax match conceal96  #\%d96# conceal
syntax match conceal124 #\%d124# conceal


syntax match word     #\%d64.*\%d64# contains=conceal64
syntax match phonetic #\%d94.*\%d94# contains=conceal94
syntax match star     #\%d96.*\%d96# contains=conceal96
syntax match content  #\%d124.*\%d124# contains=conceal124


highlight link word     pandocTitleComment
highlight link phonetic hsType
highlight link star     WarningMsg
highlight link content  ToolbarLine

setlocal conceallevel=2 concealcursor =nic
