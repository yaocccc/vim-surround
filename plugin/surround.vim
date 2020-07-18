" select模式下快速添加pairs
    snoremap ' <c-g>di''<esc>P
    snoremap " <c-g>di""<esc>P
    snoremap ` <c-g>di``<esc>P
    snoremap { <c-g>di{}<esc>P
    snoremap } <c-g>di{}<esc>P
    snoremap [ <c-g>di[]<esc>P
    snoremap ] <c-g>di[]<esc>P
    snoremap ( <c-g>di()<esc>P
    snoremap ) <c-g>di()<esc>P
    xnoremap ' di''<esc>P
    xnoremap " di""<esc>P
    xnoremap ` di``<esc>P
    xnoremap { di{}<esc>P
    xnoremap } di{}<esc>P
    xnoremap [ di[]<esc>P
    xnoremap ] di[]<esc>P
    xnoremap ( di()<esc>P
    xnoremap ) di()<esc>P

" 快速添加、去除、修改pairs
    nnoremap <silent> ys :call <SID>addPairs()<CR>
    nnoremap <silent> ds :call <SID>delPairs()<CR>
    nnoremap <silent> cs :call <SID>changePairs()<CR>
    func! s:addPairs()
        let [left, right] = s:getLR()
        if [left, right] != [0, 0]
            exe 'norm! wbi' . left
            exe 'norm! ea' . right
        endif
    endf
    func! s:delPairs()
        let [left, right] = s:getLR()
        if [left, right] != [0, 0]
            exe 'norm! F' . left . 'xf' . right . 'x'
        endif
    endf
    func! s:changePairs()
        let [left, right] = s:getLR()
        let [left2, right2] = s:getLR()
        redraw!
        if [left, right] != [0, 0] && [left2, right2] != [0, 0]
            exe 'norm! F' . left . 'r' . left2 . 'f' . right . 'r' . right2
        endif
    endf
    func! s:getLR()
        echo '-- '
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
