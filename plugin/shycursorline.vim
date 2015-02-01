scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if get(g:, 'loaded_shycursorline') || v:progname[0] !=? 'g'
  let &cpoptions = s:save_cpo
  unlet! s:save_cpo
  finish
endif

let s:default_rto = 10
let s:default_his = [
\   'hi LineNr       guibg={bg1}'
\ , 'hi CursorColumn guibg={bg2}'
\ , 'hi CursorLineNr guibg={bg2}'
\ , 'hi CursorLine   guibg={bg2}'
\]
let s:default_opt = ['hi MatchParen guibg={bg2} gui=underline,bold']
let g:shycursorline_rto = get(g:, 'shycursorline_rto', s:default_rto)
let g:shycursorline_opt = get(g:, 'shycursorline_opt', s:default_opt)
let g:loaded_shycursorline = 1

function! s:str2rgb(str) abort "{{{
  let str = a:str[0] ==# '#' ? a:str[1:] : a:str
  return map(split(str, '\x\x\zs'), 'str2nr(v:val, ''16'')')
endfunction "}}}
function! s:rgb2str(rgb) abort "{{{
  if type(a:rgb) == type('') | return a:rgb | endif
  let rgb = len(a:rgb) < 3 ? repeat(a:rgb, 3)[:2] : a:rgb
  return call('printf', ['#%02x%02x%02x'] + rgb)
endfunction "}}}
function! s:getSynID(name) abort "{{{
  if !exists('s:synTable')       | let s:synTable = {}       | en
  if has_key(s:synTable, a:name) | return s:synTable[a:name] | en
  let i = 0
  while 1
    let i += 1 | let n = synIDattr(i, 'name')
    if n ==# ''     | return 0 | en
    let s:synTable[n] = i
    if n ==# a:name | return i | en
  endwhile
endfunction "}}}
function! s:getColor(name, fb) abort "{{{
  return synIDattr(s:getSynID(a:name), a:fb, 'gui')
endfunction "}}}
function! s:transColor(rgb, rto) abort "{{{
  let rgb = map(copy(a:rgb), 'v:val + a:rto')
  if min(rgb) < 0   | return s:transColor(rgb, a:rto - min(rgb))         | en
  if max(rgb) > 255 | return s:transColor(rgb, a:rto - (max(rgb) - 255)) | en
  return rgb
endfunction "}}}
function! s:getBgs(rto) abort "{{{
  let rto = &bg ==# 'dark' ? a:rto : -(a:rto)
  let bg = s:str2rgb(s:getColor('Normal', 'bg#'))
  if empty(bg)
    let bg = repeat([&bg == 'dark' ? 0 : 255], 3)
  endif
  return [s:rgb2str(bg), s:rgb2str(s:transColor(bg, rto))]
endfunction "}}}

function! s:ShyCursorLine(rto) abort "{{{
  let rto = get(g:, 'shycursorline_rto', s:default_rto)
  if a:rto =~# '\v^\d+$'
    let rto += str2nr(a:rto)
  endif
  call s:DoHi(s:getBgs(rto))
endfunction "}}}
function! s:DoHi(bgs) abort "{{{
  let [bg1, bg2] = a:bgs
  let opt = get(g:, 'shycursorline_opt', s:default_opt)
  for line in s:default_his + opt
    let line = substitute(line, '{bg1}', bg1, 'g')
    let line = substitute(line, '{bg2}', bg2, 'g')
    silent! exe line
  endfor
endfunction "}}}
function! s:CursorMoved() abort "{{{
  ShyCursorLine
  au! ShyCursorLine CursorMoved
endfunction "}}}
function! s:EnableAutoCmd() abort "{{{
  augroup ShyCursorLine
    au!
    au ColorScheme * ShyCursorLine
    au CursorMoved * call s:CursorMoved()
  augroup END
endfunction "}}}
function! s:DisableAutoCmd() abort "{{{
  augroup ShyCursorLine
    au!
  augroup END
endfunction "}}}

command! -bar -nargs=? ShyCursorLine call s:ShyCursorLine(<q-args>)
command! -bar -nargs=0 ShyCursorLineEnable  call s:EnableAutoCmd()
command! -bar -nargs=0 ShyCursorLineDisable call s:DisableAutoCmd()

if get(g:, 'shycursorline_autocmd', 1)
  ShyCursorLineEnable
endif

let &cpoptions = s:save_cpo
unlet! s:save_cpo
