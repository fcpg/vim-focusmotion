" focusmotion.vim -
" Author:       fcpg
" Version:      1.0

" Guard {{{1
if exists("g:loaded_focusmotion") || &cp || v:version < 700
  finish
endif
let g:loaded_focusmotion = 1
" }}}1


"----------------
" Docs/Info {{{1
"----------------


"------------------------
" Variables/Options {{{1
"------------------------

let s:default_focusmotion_no_bol_eol_maps = 0


"----------------
" Functions {{{1
"----------------
" Motions

" FocusMotionWordLeft {{{2
function! FocusMotionWordLeft()
  call search('\m\%'.line('.').'l\%(\s\+\S\|^\)', 'eb')
endfun

" FocusMotionWordRight {{{2
function! FocusMotionWordRight()
  call search('\m\%'.line('.').'l\%(\s\+\S\|$\)', 'e')
endfun

" FocusMotionBegOfParagraph {{{2
function! FocusMotionBegOfParagraph()
  if line('.') == 1
    return
  endif
  let savecol = <SID>saveCursorCol()
  norm! {
  if line('.') == 1
    norm! _
  else
    norm! +
  endif
  call <SID>restoreCursorCol(savecol)
endfun

" FocusMotionEndOfParagraph {{{2
function! FocusMotionEndOfParagraph()
  if line('.') == line('$')
    return
  endif
  let savecol = <SID>saveCursorCol()
  norm! }
  if line('.') == line('$')
    norm! _
  else
    norm! -
  endif
  call <SID>restoreCursorCol(savecol)
endfun

" FocusMotionNextParagraph {{{2
function! FocusMotionNextParagraph()
  if line('.') == line('$')
    return
  endif
  let savecol = <SID>saveCursorCol()
  if getline('.') !~ '^\s*$'
    norm! j
  endif
  call search('^\%(\s*\)\@>\zs.')
  call <SID>restoreCursorCol(savecol)
endfun

" FocusMotionPrevParagraph {{{2
function! FocusMotionPrevParagraph()
  if line('.') == 1
    return
  endif
  let savecol = <SID>saveCursorCol()
  if getline('.') !~ '^\s*$'
    norm! k
  endif
  call search('^\%(\s*\)\@>\zs.', 'b')
  call <SID>restoreCursorCol(savecol)
endfun

" FocusMotionBegOfIndentBlock {{{2
function! FocusMotionBegOfIndentBlock()
  let line = <SID>indentFind({'fwd': 0, 'endcontig': 1})
  if line > 0
    let savecol = <SID>saveCursorCol()
    exe "norm!" line."G"
    call <SID>restoreCursorCol(savecol)
  endif
endfun

" FocusMotionEndOfIndentBlock {{{2
function! FocusMotionEndOfIndentBlock()
  let line = <SID>indentFind({'endcontig': 1})
  if line > 0
    let savecol = <SID>saveCursorCol()
    exe "norm!" line."G"
    call <SID>restoreCursorCol(savecol)
  endif
endfun

" FocusMotionNextIndentBlock {{{2
function! FocusMotionNextIndentBlock()
  let line = <SID>indentFind()
  if line > 0
    let savecol = <SID>saveCursorCol()
    exe "norm!" line."G"
    call <SID>restoreCursorCol(savecol)
  endif
endfun

" FocusMotionPrevIndentBlock {{{2
function! FocusMotionPrevIndentBlock()
  let line = <SID>indentFind({'fwd': 0})
  if line > 0
    let savecol = <SID>saveCursorCol()
    exe "norm!" line."G"
    call <SID>restoreCursorCol(savecol)
  endif
endfun

" s:indentJump {{{2
" Code adapted from indentwise
" Args: direction (0=back,fwd otherwise)
" Args: optional indent comparison (<|>|==) default: ==
function! s:indentFind(...)

  let def_opts = {
        \ 'fwd':        1,
        \ 'indcmp':     '<=',
        \ 'skipcontig': 1,
        \ 'endcontig':  0,
        \ }
  let opts       = extend(copy(def_opts), (a:0 ? a:1 : {}))
  let step       = opts['fwd'] ? 1 : -1
  let curline    = line('.')
  let startline  = curline
  let eof        = line('$')
  let targetind  = indent(curline)
  let indchanged = 0
  let contigseen = 0
  let found      = 0

  while (curline > 0 && curline <= eof && !found)
    let curline = curline + step
    let curind  = indent(curline)
    let accept  = 0
    let contig  = 0
    let blank   = empty(matchstr(getline(curline), '[^\s]'))

    if blank
      let indchanged = 1
    elseif ((opts['indcmp'][0] == "<") && curind < targetind)
      let accept = 1
    elseif ((opts['indcmp'][0] == ">") && curind > targetind)
      let accept = 1
    elseif (opts['indcmp'][1] == '=')
      if curind == targetind
        if opts['endcontig']
          let contig     = 1
          let contigseen = 1
        elseif (indchanged || !opts['skipcontig'])
          let accept     = 1
          let indchanged = 0
        endif
      else
        let indchanged = 1
      endif
    endif

    if opts['endcontig']
      if contigseen && !contig
        " return previous line
        let curline -= step
        let found = 1
      endif
    else
      let found = (accept && !blank)
    endif
  endwhile

  return (curline != startline ? curline : -1)
endfun

" s:saveCursorCol {{{2
function! s:saveCursorCol()
  " save curswant for some special locations
  let savecol = <SID>beforeBegOfLine()
        \   || <SID>secondCharOfLine()
        \   || getline('.') =~ '^\s*$'
        \ ? getcurpos()[4]
        \ : 0
  return savecol
endfun

" s:restoreCursorCol {{{2
function! s:restoreCursorCol(col)
  if a:col
    call cursor([0, a:col, 0, a:col])
  endif
endfun

"}}}2
" Bindings

" FocusMotionEnterExit {{{2
function! FocusMotionEnterExit()
  if FocusMotionDisabled()
    call FocusMotionToggle(1)
  elseif getline('.') =~ '^\s*$'
    " Toggle on blank lines
    call FocusMotionToggle(0)
  elseif <SID>begOfWord()
    " Enter into words
    if col('.')+1 < col('$')
      norm! l
    endif
  elseif <SID>begOfLineOrBefore()
    " Move from some front whitespace to first non-blank
    norm! _
  elseif <SID>endOfLineOrBeyond()
    " Enter into words backwards from eol
    norm! h
  else
    " Exit back to start of word
    call FocusMotionWordLeft()
  endif
endfun

" FocusMotionLeft {{{2
function! FocusMotionLeft()
  if FocusMotionDisabled() || foldclosed('.') != -1
    norm! h
  elseif getline('.') =~ '^\s*$'
    norm! {
  elseif <SID>begOfLineOrBefore()
    " Block motions
    if <SID>endOfIndentBlock()
      if <SID>begOfIndentBlock()
        " One-line indent block
        call FocusMotionPrevIndentBlock()
      else
        call FocusMotionBegOfIndentBlock()
      endif
    elseif <SID>begOfIndentBlock()
      call FocusMotionPrevIndentBlock()
    else
      call FocusMotionBegOfIndentBlock()
    endif
  elseif <SID>begOfWord() || <SID>endOfLineOrBeyond()
    call FocusMotionWordLeft()
    if <SID>firstCharOfLine()
      " Do not exit 'line-mode' with left/right motions
      norm! l
    endif
  elseif <SID>secondCharOfLine()
    " Enter into 1st word
    norm! l
  else
    if col('.') != 1
      norm! h
    endif
  endif
endfun

" FocusMotionRight {{{2
function! FocusMotionRight()
  if FocusMotionDisabled() || foldclosed('.') != -1
    norm! l
  elseif getline('.') =~ '^\s*$'
    norm! }
  elseif <SID>begOfLineOrBefore()
    " Block motions
    if <SID>begOfIndentBlock()
      if <SID>endOfIndentBlock()
        " One-line indent block
        call FocusMotionNextIndentBlock()
      else
        call FocusMotionEndOfIndentBlock()
      endif
    elseif <SID>endOfIndentBlock()
      call FocusMotionNextIndentBlock()
    else
      call FocusMotionEndOfIndentBlock()
    endif
  elseif <SID>begOfWord() || <SID>secondCharOfLine()
    call FocusMotionWordRight()
  elseif <SID>endOfLineOrBeyond()
    if getline('.')[col('.')-1] =~ '\s'
      norm! ge
    else
      norm! h
    endif
  else
    if col('.')+1 < col('$')
      norm! l
    endif
  endif
endfun

" FocusMotionDown {{{2
function! FocusMotionDown()
  if FocusMotionDisabled() || foldclosed('.') != -1
    norm! j
  elseif getline('.') =~ '^\s*$'
    call FocusMotionNextParagraph()
  elseif <SID>begOfLineOrBefore()
    norm! 2_
  else
    " Down from the middle of a word
    norm! j
  endif
endfun

" FocusMotionUp {{{2
function! FocusMotionUp()
  if FocusMotionDisabled() || foldclosed('.') != -1
    norm! k
  elseif getline('.') =~ '^\s*$'
    call FocusMotionPrevParagraph()
  elseif <SID>begOfLineOrBefore()
    norm! -
  elseif <SID>endOfLineOrBeyond()
    " To EOL on previous line
    norm! k
    " Move only if necessary, to preserve 'curswant'
    if col('.')+1 < col('$')
      norm! g_
    endif
  else
    " Up from the middle of a word
    norm! k
  endif
endfun

"}}}2
" Assertions

" s:begOfWord {{{2
function! s:begOfWord()
  let colidx  = col('.') - 1
  let curchar = getline('.')[colidx]
  let ret     = curchar =~ '\S'
  if ret && colidx != 0
    let prevchar = getline('.')[colidx - 1]
    let ret = prevchar =~ '\s'
  endif
  return ret
endfun

" s:begOfLineOrBefore {{{2
function! s:begOfLineOrBefore()
  let savepos = getcurpos()
  norm! _
  let ret = (savepos[2] <= col('.'))
  call setpos('.', savepos)
  return ret
endfun

" s:beforeBegOfLine {{{2
function! s:beforeBegOfLine()
  let savepos = getcurpos()
  norm! _
  let ret = (savepos[2] < col('.'))
  call setpos('.', savepos)
  return ret
endfun

" s:begOfParagraph {{{2
" Arg: (0|1, def. 1) is beginning of file ok?
function! s:begOfParagraph(...)
  let bof_ok = a:0 >=1 ? a:1 : 1
  let curlnr = line('.')
  return (bof_ok && curlnr == 1) || getline(curlnr - 1) =~ '^\s*$'
endfun

" s:begOfIndentBlock {{{2
" Arg: (0|1, def. 1) is beginning of file ok?
function! s:begOfIndentBlock(...)
  let bof_ok = a:0 >=1 ? a:1 : 1
  let curlnr = line('.')
  return (bof_ok && curlnr == 1) || getline(curlnr - 1) =~ '^\s*$'
        \ || indent(curlnr - 1) != indent(curlnr)
endfun

" s:lastBlankBeforeFirstCharOfLine {{{2
function! s:lastBlankBeforeFirstCharOfLine()
  let savepos = getcurpos()
  norm! _
  if col('.') == 1
    let ret = 0
  else
    norm! h
    let ret = (savepos[2] == col('.'))
  endif
  call setpos('.', savepos)
  return ret
endfun

" s:firstCharOfLine {{{2
function! s:firstCharOfLine()
  let savepos = getcurpos()
  norm! _
  let ret = (savepos[2] == col('.'))
  call setpos('.', savepos)
  return ret
endfun

" s:secondCharOfLine {{{2
function! s:secondCharOfLine()
  let savepos = getcurpos()
  norm! _
  if col('.')+1 >= col('$')
    let ret = 0
  else
    norm! l
    let ret = (savepos[2] == col('.'))
  endif
  call setpos('.', savepos)
  return ret
endfun

" s:endOfLineOrBeyond {{{2
function! s:endOfLineOrBeyond()
  let colidx = col('.')
  if colidx+1 >= col('$')
    return 1
  endif
  let line    = getline('.')
  let linelen = strlen(line)
  return strpart(line, colidx, linelen - colidx) =~ '^\s*$'
endfun

" s:endOfParagraph {{{2
" Arg: (0|1, def. 1) is end of file ok?
function! s:endOfParagraph(...)
  let eof_ok = a:0 >=1 ? a:1 : 1
  let curlnr = line('.')
  return (eof_ok && curlnr == line('$')) || getline(curlnr + 1) =~ '^\s*$'
endfun

" s:endOfIndentBlock {{{2
" Arg: (0|1, def. 1) is end of file ok?
function! s:endOfIndentBlock(...)
  let eof_ok = a:0 >=1 ? a:1 : 1
  let curlnr = line('.')
  return (eof_ok && curlnr == line('$')) || getline(curlnr + 1) =~ '^\s*$'
        \ || indent(curlnr + 1) != indent(curlnr)
endfun

"}}}2
" Misc

" FocusMotionToggle {{{2
" Arg: (0|1|2) unset/set/toggle? (default: toggle)
" Arg: (0|1)   silent?           (default: no)
function! FocusMotionToggle(...)
  let w:focusmotion_disabled = (a:0 && a:1 != 2)
        \ ? !a:1
        \ : !get(w:, 'focusmotion_disabled', 0)
  if a:0 < 2 || !a:2
    echom "FocusMotion turned " . (w:focusmotion_disabled ? "OFF" : "ON")
  endif
endfun

" FocusMotionGlobalToggle {{{2
" Arg: (0|1|2) unset/set/toggle? (default: toggle)
" Arg: (0|1)   silent?           (default: no)
function! FocusMotionGlobalToggle(...)
  let g:focusmotion_disabled = (a:0 && a:1 != 2)
        \ ? !a:1
        \ : !get(g:, 'focusmotion_disabled', 0)
  if a:0 < 2 || !a:2
    echom "FocusMotion globally turned " .
          \ (g:focusmotion_disabled ? "OFF" : "ON")
  endif
endfun

" FocusMotionDisabled {{{2
function! FocusMotionDisabled()
  return get(g:, 'focusmotion_disabled', 0)
        \ || get(w:, 'focusmotion_disabled', 0)
endfun


"---------------
" Mappings {{{1
"---------------

map <silent> <plug>FocusMotion_left       :<C-u>call FocusMotionLeft()<cr>
map <silent> <plug>FocusMotion_right      :<C-u>call FocusMotionRight()<cr>
map <silent> <plug>FocusMotion_down       :<C-u>call FocusMotionDown()<cr>
map <silent> <plug>FocusMotion_up         :<C-u>call FocusMotionUp()<cr>
map <silent> <plug>FocusMotion_enterexit  :<C-u>call FocusMotionEnterExit()<cr>

if !get(g:, 'focusmotion_nomaps', 0)
  nmap <silent>  h   <plug>FocusMotion_left
  nmap <silent>  l   <plug>FocusMotion_right
  nmap <silent>  j   <plug>FocusMotion_down
  nmap <silent>  k   <plug>FocusMotion_up
  nmap <silent>  s   <plug>FocusMotion_enterexit
endif


"---------------
" Commands {{{1
"---------------

command! -nargs=* -bar FocusMotionToggle
      \ call FocusMotionToggle(<f-args>)

command! -nargs=* -bar FocusMotionGlobalToggle
      \ call FocusMotionGlobalToggle(<f-args>)

" }}}1

" vim:sw=2 ts=2
