if exists('s:loaded')
  finish
endif
let s:loaded = 1

let s:use_default_surround_config = get(g:, 'use_default_surround_config', 1)
let s:use_toggle_surround = get(g:, 'use_toggle_surround', 1)
if s:use_default_surround_config == 1
    " 快速添加、去除、修改pairs
    " add、remove、update pairs
    nnoremap <silent> ys :call SurroundAddPairs(SurroundGetLR())<CR>
    nnoremap <silent> yS :call SurroundAddLinePairs(SurroundGetLR())<CR>
    nnoremap <silent> ds :call SurroundDelPairs(SurroundGetLR())<CR>
    nnoremap <silent> cs :call SurroundChangePairs(SurroundGetLR(), SurroundGetLR())<CR>

    " visual模式下快速添加pairs
    " visual mode - add pairs
    snoremap <silent> ' <c-g>:<c-u>call SurroundVaddPairs("'", "'")<cr>
    snoremap <silent> " <c-g>:<c-u>call SurroundVaddPairs('"', '"')<cr>
    snoremap <silent> ` <c-g>:<c-u>call SurroundVaddPairs('`', '`')<cr>
    snoremap <silent> { <c-g>:<c-u>call SurroundVaddPairs('{', '}')<cr>
    snoremap <silent> } <c-g>:<c-u>call SurroundVaddPairs('{', '}')<cr>
    snoremap <silent> [ <c-g>:<c-u>call SurroundVaddPairs('[', ']')<cr>
    snoremap <silent> ] <c-g>:<c-u>call SurroundVaddPairs('[', ']')<cr>
    snoremap <silent> ( <c-g>:<c-u>call SurroundVaddPairs('(', ')')<cr>
    snoremap <silent> ) <c-g>:<c-u>call SurroundVaddPairs('(', ')')<cr>
    xnoremap <silent> '      :<c-u>call SurroundVaddPairs("'", "'")<cr>
    xnoremap <silent> "      :<c-u>call SurroundVaddPairs('"', '"')<cr>
    xnoremap <silent> `      :<c-u>call SurroundVaddPairs('`', '`')<cr>
    xnoremap <silent> {      :<c-u>call SurroundVaddPairs('{', '}')<cr>
    xnoremap <silent> }      :<c-u>call SurroundVaddPairs('{', '}')<cr>
    xnoremap <silent> [      :<c-u>call SurroundVaddPairs('[', ']')<cr>
    xnoremap <silent> ]      :<c-u>call SurroundVaddPairs('[', ']')<cr>
    xnoremap <silent> (      :<c-u>call SurroundVaddPairs('(', ')')<cr>
    xnoremap <silent> )      :<c-u>call SurroundVaddPairs('(', ')')<cr>
endif

" visual mode add pairs
func! SurroundVaddPairs(left, right)
    let [c1, l1, c2, l2] = [col("'<"), line("'<"), col("'>"), line("'>")]
    let c2 = &selection == "exclusive" ? c2 - 1 : c2
    let [content1, content2] = [getline(l1), getline(l2)]
    if s:isSelectLines()

        " if getline(l1 - 1) = ^\s*[a:left]$ && getline(l2 + 1) = ^\s*[a:right]$ then remove pairs
        if s:use_toggle_surround && getline(l1 - 1) =~# '^\s*' . a:left . '$' && getline(l2 + 1) =~# '^\s*' . a:right . '$'
            call deletebufline('%', l2 + 1)
            call deletebufline('%', l1 - 1)
            normal! gv<
        else
            let emptyStr = s:getEmptyStr(s:getCol(l1, l2))
            call appendbufline('%', l1 - 1, emptyStr . a:left)
            call appendbufline('%', l2 + 1, emptyStr . a:right)
            normal! gv>
        endif
    else 
        if l1 == l2
            let content_1 = c1 - 2 >= 0 ? content1[: c1 - 2] : ''
            let content_2 = content1[c1 - 1: c2 - 1]
            let content_3 = content1[c2: ]

            " if content_1 endwith(a:left) && content_3 startwith(a:right) then remove pairs
            let afterac = "b"
            if s:use_toggle_surround && content_1 =~ a:left . '$' && content_3 =~ '^' . a:right
                let content_1 = substitute(content_1, a:left . '$', '', '')
                let content_3 = substitute(content_3, '^' . a:right, '', '')
            else
                let content_1 = content_1 . a:left
                let content_3 = a:right . content_3
                let afterac = "w"
            end

            call setline(l1, content_1 . content_2 . content_3)
            execute("normal! " . afterac)
        else
            let content1_1 = c1 - 2 >= 0 ? content1[: c1 - 2] : ''
            let content2_1 = c2 - 1 >= 0 ? content2[: c2 - 1] : ''
            let content1_2 = content1[c1 - 1:]
            let content2_2 = content2[c2:]

            " if content1_1 endwith(a:left) && content2_2 startwith(a:right) then remove pairs
            let afterac = ""
            if s:use_toggle_surround && content1_1 =~ a:left . '$' && content2_2 =~ '^' . a:right
                let content1_1 = substitute(content1_1, a:left . '$', '', '')
                let content2_2 = substitute(content2_2, '^' . a:right, '', '')
            else
                let content1_1 = content1_1 . a:left
                let content2_2 = a:right . content2_2
                let afterac = "w"
            end

            call setline(l1, content1_1 . content1_2)
            call setline(l2, content2_1 . content2_2)
            if afterac != "" | execute("normal! " . afterac) | endif
        endif
    endif
endf

" normal mode add pairs
func! SurroundAddPairs(pairs)
    let [left, right] = a:pairs
    if [left, right] != [0, 0]
        exe 'norm! wbi' . left
        exe 'norm! ea' . right
    endif
endf

" normal mode line add pairs
func! SurroundAddLinePairs(pairs)
    let [left, right] = a:pairs
    if  [left, right] != [0, 0]
        if index(['"', "\'", '`'], left) != -1
            exe 'norm! ^i' . left
            exe 'norm! $a' . right
        else
            let  l = line('.')
            let  col = s:getCol(l, l)
            call setline(l, s:getEmptyStr(&shiftwidth) . getline(l))
            call appendbufline('%', l - 1, s:getEmptyStr(col) . left)
            call appendbufline('%', l + 1, s:getEmptyStr(col) . right)
        endif
    endif
endf

" normal mode delete pairs
func! SurroundDelPairs(pairs)
    let [left, right] = a:pairs
    if  [left, right] != [0, 0]
        exe 'norm! F' . left . 'xf' . right . 'x'
    endif
endf

" normal mode change pairs
func! SurroundChangePairs(pairs1, pairs2)
    let [left, right] = a:pairs1
    let [left2, right2] = a:pairs2
    redraw!
    if [left, right] != [0, 0] && [left2, right2] != [0, 0]
        exe 'norm! F' . left . 'r' . left2 . 'f' . right . 'r' . right2
    endif
endf

func! SurroundGetLR()
    let c = getchar()
    let c = c =~ '^\d\+$' ? nr2char(c) : ''
    let leftlist = ['(', '[', '{', '<', '"', "\'", '`']
    let rightlist = [')', ']', '}', '>', '"', "\'", '`']
    let [left, right] = [0, 0]
    let lindex = index(leftlist, c)
    let rindex = index(rightlist, c)
    if lindex != -1
        let left = c
        let right = rightlist[lindex]
    elseif rindex != -1
        let left = leftlist[rindex]
        let right = c
    endif
    return [left, right]
endf

func! s:getCol(n1, n2)
    let c = 999
    for num in range(a:n1, a:n2)
        let pre = getline(num)
        let after = substitute(pre, '^\s*', '', '')
        let c = trim(pre) ==# '' ? c : min([c, len(pre) - len(after)])
    endfor
    return c
endf

func! s:getEmptyStr(len)
    let str = ''
    for i in range(1, a:len)
        let str .= ' '
    endfor
    return str
endf

func! s:isSelectLines()
    return col("'<") == 1 && col("'>") == len(getline(line("'>"))) + 1
endf
