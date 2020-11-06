if exists('s:loaded')
  finish
endif
let s:loaded = 1

" select模式下快速添加pairs
snoremap <silent> ' <c-g>:<c-u>call SurroundVaddPairs("'", "'", -1)<cr>
snoremap <silent> " <c-g>:<c-u>call SurroundVaddPairs('"', '"', -1)<cr>
snoremap <silent> ` <c-g>:<c-u>call SurroundVaddPairs('`', '`', -1)<cr>
snoremap <silent> { <c-g>:<c-u>call SurroundVaddPairs('{', '}', -1)<cr>
snoremap <silent> } <c-g>:<c-u>call SurroundVaddPairs('{', '}', -1)<cr>
snoremap <silent> [ <c-g>:<c-u>call SurroundVaddPairs('[', ']', -1)<cr>
snoremap <silent> ] <c-g>:<c-u>call SurroundVaddPairs('[', ']', -1)<cr>
snoremap <silent> ( <c-g>:<c-u>call SurroundVaddPairs('(', ')', -1)<cr>
snoremap <silent> ) <c-g>:<c-u>call SurroundVaddPairs('(', ')', -1)<cr>
xnoremap <silent> '      :<c-u>call SurroundVaddPairs("'", "'", -1)<cr>
xnoremap <silent> "      :<c-u>call SurroundVaddPairs('"', '"', -1)<cr>
xnoremap <silent> `      :<c-u>call SurroundVaddPairs('`', '`', -1)<cr>
xnoremap <silent> {      :<c-u>call SurroundVaddPairs('{', '}', -1)<cr>
xnoremap <silent> }      :<c-u>call SurroundVaddPairs('{', '}', -1)<cr>
xnoremap <silent> [      :<c-u>call SurroundVaddPairs('[', ']', -1)<cr>
xnoremap <silent> ]      :<c-u>call SurroundVaddPairs('[', ']', -1)<cr>
xnoremap <silent> (      :<c-u>call SurroundVaddPairs('(', ')', -1)<cr>
xnoremap <silent> )      :<c-u>call SurroundVaddPairs('(', ')', -1)<cr>
func! SurroundVaddPairs(left, right, col)
    let [l:col1, l:line1, l:col2, l:line2] = [col("'<"), line("'<"), col("'>"), line("'>")]
    let [l:line1_content, l:line2_content] = [getline(l:line1), getline(l:line2)]
    if l:line1 == l:line2 || !s:isSelectLines()
        let l:l_content = l:col1 - 2 >= 0 ? l:line1_content[: l:col1 - 2] : ''
        let l:c_content = l:line1_content[l:col1 - 1: l:col2 - 2]
        let l:r_content = l:line1_content[l:col2 - 1: ]
        call setline(l:line1, l:l_content . a:left . l:c_content . a:right . l:r_content)
    else
        let l:col = a:col >= 0 ? a:col : s:getCol(l:line1, l:line2)
        for num in range(l:line1, l:line2)
            let l:line = getline(num)
            call setline(num, s:getEmptyStr(&shiftwidth) . l:line)
        endfor
        call appendbufline('%', l:line1 - 1, s:getEmptyStr(l:col) . a:left)
        call appendbufline('%', l:line2 + 1, s:getEmptyStr(l:col) . a:right)
    endif
endf

" 快速添加、去除、修改pairs
nnoremap <silent> ys :call SurroundAddPairs(SurroundGetLR())<CR>
nnoremap <silent> yS :call SurroundAddLinePairs(SurroundGetLR())<CR>
nnoremap <silent> ds :call SurroundDelPairs(SurroundGetLR())<CR>
nnoremap <silent> cs :call SurroundChangePairs(SurroundGetLR(), SurroundGetLR())<CR>
func! SurroundAddPairs(pairs)
    let [l:left, l:right] = a:pairs
    if [l:left, l:right] != [0, 0]
        exe 'norm! wbi' . l:left
        exe 'norm! ea' . l:right
    endif
endf
func! SurroundAddLinePairs(pairs)
    let [l:left, l:right] = a:pairs
    if  [l:left, l:right] != [0, 0]
        if index(['"', "\'", '`'], l:left) != -1
            exe 'norm! ^i' . l:left
            exe 'norm! $a' . l:right
        else
            let  l:line = line('.')
            let  l:col = s:getCol(l:line, l:line)
            call setline(l:line, s:getEmptyStr(&shiftwidth) . getline(l:line))
            call appendbufline('%', l:line - 1, s:getEmptyStr(col) . l:left)
            call appendbufline('%', l:line + 1, s:getEmptyStr(col) . l:right)
        endif
    endif
endf
func! SurroundDelPairs(pairs)
    let [l:left, l:right] = a:pairs
    if  [l:left, l:right] != [0, 0]
        exe 'norm! F' . l:left . 'xf' . l:right . 'x'
    endif
endf
func! SurroundChangePairs(pairs1, pairs2)
    let [l:left, l:right] = a:pairs1
    let [l:left2, l:right2] = a:pairs2
    redraw!
    if [l:left, l:right] != [0, 0] && [l:left2, l:right2] != [0, 0]
        exe 'norm! F' . l:left . 'r' . l:left2 . 'f' . l:right . 'r' . l:right2
    endif
endf
func! SurroundGetLR()
    let l:c = getchar()
    let l:c = l:c =~ '^\d\+$' ? nr2char(l:c) : ''
    let l:leftlist = ['(', '[', '{', '<', '"', "\'", '`']
    let l:rightlist = [')', ']', '}', '>', '"', "\'", '`']
    let [l:left, l:right] = [0, 0]
    let l:lindex = index(l:leftlist, l:c)
    let l:rindex = index(l:rightlist, l:c)
    if l:lindex != -1
        let l:left = l:c
        let l:right = l:rightlist[l:lindex]
    elseif l:rindex != -1
        let l:left = l:leftlist[l:rindex]
        let l:right = l:c
    endif
    return [l:left, l:right]
endf

func! s:getCol(num1, num2)
    let l:col = 999
    for num in range(a:num1, a:num2)
        let l:line = getline(num)
        let l:line2 = substitute(l:line, '^\s*', '', '')
        let l:col = trim(l:line) ==# '' ? l:col : min([l:col, len(l:line) - len(l:line2)])
    endfor
    return col
endf

func! s:getEmptyStr(len)
    let l:str = ''
    for i in range(1, a:len)
        let l:str .= ' '
    endfor
    return l:str
endf

func! s:isSelectLines()
    return col("'<") == 1 && col("'>") == len(getline(line("'>"))) + 1
endf
