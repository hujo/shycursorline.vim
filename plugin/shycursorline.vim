scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if get(g:, 'loaded_shycursorline') || v:progname[0] !=? 'g'
  let &cpoptions = s:save_cpo
  unlet! s:save_cpo
  finish
endif


let g:loaded_shycursorline = 1
let s:default_rto = 10
let g:shycursorline_rto = s:default_rto


function! s:str2rgb(str) "{{{
  let str = a:str[0] ==# '#' ? a:str[1:] : a:str
  return map(split(str, '\x\x\zs'), 'str2nr(v:val, ''16'')')
endfunction "}}}
function! s:rgb2str(rgb) "{{{
  if type(a:rgb) == type('') | return a:rgb | endif
  return call('printf', ['#%02x%02x%02x'] + a:rgb)
endfunction "}}}
function! s:getSynID(name) "{{{
  if !exists('s:synTable')       | let s:synTable = {}       | endif
  if has_key(s:synTable, a:name) | return s:synTable[a:name] | endif
  let i = 0
  while 1
    let i += 1 | let n = synIDattr(i, 'name')
    if n ==# ''     | return 0 | endif
    let s:synTable[n] = i
    if n ==# a:name | return i | endif
  endwhile
endfunction "}}}
function! s:getColor(name, fb) "{{{
  return synIDattr(s:getSynID(a:name), a:fb, 'gui')
endfunction "}}}
function! s:transColor(rgb, rto) "{{{
  let rgb = map(copy(a:rgb), 'v:val + a:rto')
  if min(rgb) < 0
    return s:transColor(rgb, a:rto - min(rgb))
  elseif max(rgb) > 255
    return s:transColor(rgb, a:rto - (max(rgb) - 255))
  endif
  return rgb
endfunction "}}}
function! s:ShyCursorLine(...) "{{{
  let rto = get(g:, 'shycursorline_rto', s:default_rto)
  if a:0
    let rto += str2nr(a:1)
  endif
  let rto = &bg ==# 'dark' ? rto : -(rto)
  let bg = s:str2rgb(s:getColor('Normal', 'bg#'))
  if empty(bg)
    let bg = repeat([&bg == 'dark' ? 0 : 255], 3)
  endif
  let bg1 = s:rgb2str(bg)
  let bg2 = s:rgb2str(s:transColor(bg, rto))
  exe 'hi LineNr       guibg=' . bg1
  exe 'hi CursorColumn guibg=' . bg2
  exe 'hi CursorLineNr guibg=' . bg2
  exe 'hi CursorLine   guibg=' . bg2
  exe 'hi MatchParen   guibg=' . bg2
endfunction "}}}

function! s:EnableAutoCmd() "{{{
  augroup ShyCursorLine
    au!
    au ColorScheme * ShyCursorLine
    au CursorMoved * ShyCursorLine | au! ShyCursorLine CursorMoved
  augroup END
endfunction "}}}

function! s:DisableAutoCmd() "{{{
  augroup ShyCursorLine
    au!
  augroup END
endfunction "}}}

command! -nargs=? ShyCursorLine call s:ShyCursorLine(<q-args>)
command! ShyCursorLineEnable  call s:EnableAutoCmd()
command! ShyCursorLineDisable call s:DisableAutoCmd()

if get(g:, 'shycursorline_autocmd', 1)
  ShyCursorLineEnable
endif

let &cpoptions = s:save_cpo
unlet! s:save_cpo
