if exists('s:loaded')
  finish
endif
let s:loaded = 1

" select模式下快速添加pairs
snoremap ' <c-g> :<c-u>call <SID>vaddPairs("'", "'")<cr>
snoremap " <c-g> :<c-u>call <SID>vaddPairs('"', '"')<cr>
snoremap ` <c-g> :<c-u>call <SID>vaddPairs('`', '`')<cr>
snoremap { <c-g> :<c-u>call <SID>vaddPairs('{', '}')<cr>
snoremap } <c-g> :<c-u>call <SID>vaddPairs('{', '}')<cr>
snoremap [ <c-g> :<c-u>call <SID>vaddPairs('[', ']')<cr>
snoremap ] <c-g> :<c-u>call <SID>vaddPairs('[', ']')<cr>
snoremap ( <c-g> :<c-u>call <SID>vaddPairs('(', ')')<cr>
snoremap ) <c-g> :<c-u>call <SID>vaddPairs('(', ')')<cr>
xnoremap ' :<c-u>call <SID>vaddPairs("'", "'")<cr>
xnoremap " :<c-u>call <SID>vaddPairs('"', '"')<cr>
xnoremap ` :<c-u>call <SID>vaddPairs('`', '`')<cr>
xnoremap { :<c-u>call <SID>vaddPairs('{', '}')<cr>
xnoremap } :<c-u>call <SID>vaddPairs('{', '}')<cr>
xnoremap [ :<c-u>call <SID>vaddPairs('[', ']')<cr>
xnoremap ] :<c-u>call <SID>vaddPairs('[', ']')<cr>
xnoremap ( :<c-u>call <SID>vaddPairs('(', ')')<cr>
xnoremap ) :<c-u>call <SID>vaddPairs('(', ')')<cr>
func! s:vaddPairs(left, right)
    let [l:col1, l:line1, l:col2, l:line2] = [col("'<"), line("'<"), col("'>"), line("'>")]
    let [l:line1_content, l:line2_content] = [getline(l:line1), getline(l:line2)]
    if l:line1 == l:line2
        let l:l_content = l:col1 - 2 >= 0 ? l:line1_content[: l:col1 - 2] : ''
        let l:c_content = l:line1_content[l:col1 - 1: l:col2 - 2]
        let l:r_content = l:line1_content[l:col2 - 1: ]
        call setline(l:line1, l:l_content . a:left . l:c_content . a:right . l:r_content)
    else
        let l:line1_l_content = l:col1 - 2 >= 0 ? l:line1_content[: l:col1 - 2] : ''
        let l:line2_l_content = l:col2 - 2 >= 0 ? l:line2_content[: l:col2 - 2] : ''
        let l:line1_r_content = l:line1_content[l:col1 - 1:]
        let l:line2_r_content = l:line2_content[l:col2 - 1:]
        call setline(l:line1, l:line1_l_content . a:left . l:line1_r_content)
        call setline(l:line2, l:line2_l_content . a:right . l:line2_r_content)
    endif
endf

" 快速添加、去除、修改pairs
nnoremap <silent> ys :call <SID>addPairs()<CR>
nnoremap <silent> yS :call <SID>AddPairs()<CR>
nnoremap <silent> ds :call <SID>delPairs()<CR>
nnoremap <silent> cs :call <SID>changePairs()<CR>
func! s:addPairs()
    let [l:left, l:right] = s:getLR()
    if [l:left, l:right] != [0, 0]
        exe 'norm! wbi' . l:left
        exe 'norm! ea' . l:right
    endif
endf
func! s:AddPairs()
    let [l:left, l:right] = s:getLR()
    if [l:left, l:right] != [0, 0]
        if index(['"', "\'", '`'], l:left) != -1
            exe 'norm! ^i' . l:left
            exe 'norm! $a' . l:right
        else
            exe 'norm! o' . l:right
            exe 'norm! kO' . l:left
        endif
    endif
endf
func! s:delPairs()
    let [l:left, l:right] = s:getLR()
    if [l:left, l:right] != [0, 0]
        exe 'norm! F' . l:left . 'xf' . l:right . 'x'
    endif
endf
func! s:changePairs()
    let [l:left, l:right] = s:getLR()
    let [l:left2, l:right2] = s:getLR()
    redraw!
    if [l:left, l:right] != [0, 0] && [l:left2, l:right2] != [0, 0]
        exe 'norm! F' . l:left . 'r' . l:left2 . 'f' . l:right . 'r' . l:right2
    endif
endf
func! s:getLR()
    let l:c = getchar()
    let l:c = l:c =~ '^\d\+$' ? nr2char(l:c) : ''
    let l:leftlist = ['(', '[', '{', '<', '"', "\'", '`']
    let l:rightlist = [')', ']', '}', '>', '"', "\'", '`']
    let [l:left, l:right] = [0, 0]
    let l:lindex = index(l:leftlist, c)
    let l:rindex = index(l:rightlist, c)
    if l:lindex != -1
        let l:left = c
        let l:right = l:rightlist[l:lindex]
    elseif l:rindex != -1
        let l:left = l:leftlist[l:rindex]
        let l:right = l:c
    endif
    return [l:left, l:right]
endf
