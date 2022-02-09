function! Convert()
    "word, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio
    let list = []
    let start = reltime()
    for line in readfile('./filter2.csv')
        let words = split(line, 'ç')
        call assert_equal(12, len(words), 'words len should equal 12')
        let wordDict =  words[0] . "ç" . words[1] . "ç" . words[3]
        call add(list, wordDict) 
    endfor

    call writefile(list, 'dict.bin', 'b')
    let timecost = reltimestr(reltime(start))
    "echom dictionary
    echo 'LoadE2CDict time cost: ' . timecost . ' s'
endfunction

function! LoadDictBin()
    let g:dictionary = {}
    let start = reltime()
    for line in readfile('./dict.bin', 'b')
        let words = split(line, 'ç', 1)
        if len(words) < 3
            echo words
        endif
        let wordDict   = {"word" : words[0],  "phonetic" : words[1], "translation" : words[2]}
        let g:dictionary[words[0]]  = wordDict
    endfor
    let timecost = reltimestr(reltime(start))
    echo 'LoadE2CDict time cost: ' . timecost . ' s'
endfunction

function! util#log(msg)
    if g:ShowLog
        echom a:msg
    endif
endfunction
