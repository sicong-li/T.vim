" SECTION: vars {{{1
let s:resourcePath = expand(fnamemodify(expand('<sfile>'), ":~:h:h") . '/resource')
let s:displayBufName = "_Translate_Result_"


" FUNCTION: s:loadE2CDict {{{1
" load English 2 chinese dict
function! s:loadE2CDict() 
    "word, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio
    let g:dictionary = {}
    let l:start = reltime()
    for line in readfile(s:resourcePath . '/dict.txt')
        let l:words = split(l:line, 'ç')
        if len(l:words) != 12
            throw 'T.ErrorDataFormat: file ' . s:resourcePath . '/dict.txt' . 'should have 12 columns' 
        endif
        let l:wordDict = {"word" : l:words[0], "phonetic" : l:words[1], "translation" : l:words[3]}
        let g:dictionary[l:words[0]] = l:wordDict
    endfor
    let l:timecost = reltimestr(reltime(l:start))
    call util#log('LoadE2CDict time cost: ' . l:timecost . ' s')
endfunction

" FUNTION: s:loadCollins {{{1
" load the collins dict which describes the importance of thirty thousand words
function! s:loadCollins()
    let g:collins  = {}
    let l:start = reltime()
    for line in readfile(s:resourcePath . '/collins.txt')
        let l:wordStar = split(l:line, '=')
        let g:collins[l:wordStar[0]] = l:wordStar[1]
    endfor
    let l:timecost = reltimestr(reltime(l:start))

    call util#log('Load Collins times cost: ' . l:timecost . ' s')
endfunction

" FUNCTION: s:loadSource {{{1
function! s:loadSource()
    if !exists('g:dictionary')
        call s:loadE2CDict()
    endif
    if !exists('g:collins')
        call s:loadCollins()
    endif
endfunction

"FUNCTION: s:getCollinsStar {{{1
"change collins num star to char star for display
function! s:getCollinsStar(word) abort
    let l:starStr = ""
    if !g:UseGrep
        try
            let l:starNum = g:collins[a:word]
        catch /^Vim\%((\a\+)\)\=:E716:/
            return "☆"
        endtry
    else
        let l:collinStar = systemlist("grep -i ^" . a:word . "= " . s:resourcePath . "/collins.txt")
        if !empty(l:collinStar)
            let l:starNum = split(l:collinStar[0], "=")[1]
        else
            return "☆"
        endif
    endif

    for i in range(l:starNum)
        let l:starStr = l:starStr . "★"
    endfor
    return l:starStr
endfunction


" FUNCTION: s:getTranslate {{{1
function! s:getTranslate(word) 
    try
        if !g:UseGrep
            return g:dictionary[a:word]
        else
            let result = systemlist("grep -i ^" . a:word . "ç " . s:resourcePath . "/dict.txt")
            let l:words = split(result[0], 'ç')
            let l:wordDict = {"word" : l:words[0],  "phonetic" : l:words[1],  "translation" : l:words[3]}
            return l:wordDict
        endif
    catch /.*/
        throw 'T.NotFoundWordError: ' . a:word
    endtry
endfunction

" FUNCTION: s:preProcess {{{1
"pre process the input word that will be translation 
function! s:preProcess(word)
    let l:word  = tolower(a:word)
    let l:rt  = ''
    for i in range(len(l:word))
        if l:word[i]  =~# '[a-z-]'
            let l:rt  = l:rt . l:word[i]
        endif
    endfor

    return l:rt
endfunction

" FUNCTION: T#FindWord{{{1
"translate the words: first search for word in E2C dictionnary,if not find then
"second: serach for source word in lemma.txt
"
function! s:findWord(word) 
    if !g:UseGrep
        call s:loadSource()
    endif
    let l:word  = s:preProcess(a:word)
    let l:start = reltime()
    let l:transResult = []
    try
        "let transResult = [g:dictionary[l:word]]
        call add(l:transResult, s:getTranslate(l:word))
        
    catch /T.NotFoundWordError/
        "throw 'T.WordNotFind: can not find this word :' . l:word  i
        let l:lemmas = systemlist("grep -wi " . l:word . " " . s:resourcePath . "/lemma.txt")
        if !empty(l:lemmas)
            for tmp in l:lemmas
                let l:srcWord = split(l:tmp, " ")[0]
                try
                    call add(l:transResult, s:getTranslate(l:srcWord))
                catch /.*/
                endtry
            endfor
        endif
    endtry
    let l:timecost = reltimestr(reltime(l:start))
    call util#log('FindWord ' . l:word . ' time cost: ' . l:timecost . ' s')
    "call s:displayResult(l:transResult)
    if len(l:transResult) > 0
        call s:addRecord(deepcopy(l:transResult[0]))
    endif
    return l:transResult
endfunction

"FUNCTION: s:renderWords {{{1
"render Words with highlight group
function! s:renderWords(words) abort
    let l:output = ''
    if !empty(a:words)
        for l:word in a:words
            let l:star = s:getCollinsStar(l:word['word'])
            let l:output = l:output . nr2char(g:TWordWrapChar) . l:word['word'] .nr2char(g:TWordWrapChar) . "  "
            let l:output = l:output . nr2char(g:TPhoneticWrapChar) . "[" . l:word['phonetic'] . "]" . nr2char(g:TPhoneticWrapChar) . "  "
            let l:output = l:output . nr2char(g:TStarWrapChar) . l:star . nr2char(g:TStarWrapChar) . "  "
            if index(keys(l:word), "time") >= 0
                let l:output = l:output . strftime("%m月%d日 %H时:%M分", l:word["time"]) 
            endif
            let l:output = l:output . "\n"
            let l:rtList = split(l:word['translation'], '\\n')
            for item in l:rtList
                let l:output = l:output . "\t" . nr2char(g:TContentWrapChar) . l:item . nr2char(g:TContentWrapChar)  ."\n"
            endfor
        endfor
    else
        let l:output = nr2char(g:TStarWrapChar) . "No Result Found" . nr2char(g:TStarWrapChar) . "\n"
    endif
    return l:output
endfunction

" FUNCTION: s:displayResult {{{1
" show result in tab 
function! s:displayResult(transResult, recentWords)
    if bufwinnr(s:displayBufName)  == -1
        execute g:TWinSize . g:SplitMethod . s:displayBufName
        nnoremap <buffer> q :q<cr>
        setlocal filetype=DisplayTrans
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        setlocal nolist
        setlocal nobuflisted
        setlocal nocursorline
        setlocal nonumber
        setlocal norelativenumber
        setlocal winfixwidth
    else
        execute bufwinnr(s:displayBufName) . "wincmd w"
    endif
    normal! ggdG

    if !empty(a:transResult)
        silent put = s:renderWords(a:transResult)
    endif
    
    if !empty(a:recentWords)
        call append(line("$"), ["", "", "", "Recent Search:-----------"])
        normal! G
        silent put = s:renderWords(a:recentWords)
    endif

    silent 1,1delete
    execute winnr("#") . "wincmd w"
endfunction

"FUNCTION: s:serializeWord(wordDict){{{1
function! s:writeRecordWord(wordList)
    function! s:wordCompare(A, B)
        return a:A["time"] == a:B["time"] ? 0 : a:A["time"] > a:B["time"] ? 1 : -1
    endfunction
    
    "call sort(wordList, "wordCompare")
    call sort(copy(a:wordList), "s:wordCompare")
    let l:content = []
    let fieldSep = '@@'
    for l:word in a:wordList
        let l:content += [ l:word["word"] . l:fieldSep . l:word["phonetic"] . l:fieldSep . l:word["translation"] . l:fieldSep . l:word["time"] ]
    endfor
    call writefile(l:content, s:resourcePath . "/records.txt", "s")
endfunction

"FUNCTION: s:readRecordWord(){{{1
function! s:readRecordWord()
    let l:recentWords = []
    for line in readfile(s:resourcePath . '/records.txt')
        let splitResult = split(line, "@@")
        let word = {"word" : splitResult[0], "phonetic" : splitResult[1], "translation" : splitResult[2], "time" : splitResult[3]}
        call add(l:recentWords, word)
    endfor
    return l:recentWords
endfunction

"FUNCTION: s:addRecord(){{{1
function! s:addRecord(word)
    let l:word = a:word
    let l:word["time"] = reltimestr(reltime())
    if index(keys(g:), "recentRecords") == -1
        let g:recentRecords = s:readRecordWord()
        let g:recentList = []
        for tmp in g:recentRecords
            call add(g:recentList, tmp["word"])
        endfor
    endif

    if index(g:recentList, a:word["word"]) < 0
        if len(g:recentRecords) > g:totalRecentNum
            let g:recentRecords = g:recentRecords[1:]
            let g:recentList = g:recentList[1:]
        endif 
        let g:recentRecords += [l:word]
        let g:recentList += [l:word["word"]]
    else
        let index = index(g:recentList,  l:word)
        let l:tmp = remove(g:recentRecords, index)
        let l:tmp["time"] = reltimestr(reltime())
        let g:recentRecords += [l:tmp]
        call remove(g:recentList, index)
        let g:recentList += [l:word["word"]]
    endif
    call s:writeRecordWord(g:recentRecords)
endfunction

" FUNCTION: T#Main {{{1
function! T#Main(word)
    let l:recentWords = []
    if index(keys(g:), "recentRecords") >= 0
        let l:recentWords += g:recentRecords[-g:displayRecentNum:]
    endif
    call reverse(l:recentWords)
    call s:displayResult(s:findWord(a:word), l:recentWords)
endfunction

" FUNCTION: T#VisualSearch{{{1
function! T#VisualSearch(type)
    let l:saved_unnamed_register = @@
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    call T#Main(@@)

    let @@ = l:saved_unnamed_register
endfunction

" FUNCTION: T#DisplayRecent {{{1
function! T#DisplayRecent()
    if index(keys(g:), "recentRecords") == -1
        call s:readRecordWord()
    endif

    let l:displayRecentNum = g:displayRecentNum
    let g:displayRecentNum  = len(g:displayRecentNum)
    call s:displayResult([], g:recentRecords)
    let g:displayRecentNum = l:displayRecentNum
endfunction


