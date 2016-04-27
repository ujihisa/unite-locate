let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'locate',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 3,
      \ }

" If the locate command is linux version, use -e option which means fetching
" only existing files.
function! s:is_linux()
  " Linux version only has -V option
  call unite#util#system('locate -V')
  return !unite#util#get_last_status()
endfunction

function! s:locate_is_disabled()
  return !filereadable('/var/db/locate.database')
        \ && !filereadable($LOCATE_PATH)
endfunction

if has('mac') && s:locate_is_disabled()
  let s:locate_command = 'mdfind -name {query} | head -n {count}'
elseif executable('locate')
  let s:locate_command = 'locate -l {count}'.(s:is_linux() ? ' -e' : '').' {query}'
elseif unite#util#is_windows() && executable('es')
  let s:locate_command = 'es -i -r -n {count} {query}'
endif

function! s:unite_source.gather_candidates(args, context)
  if exists('g:unite_locate_command')
    let locate_command = g:unite_locate_command
  else
    let locate_command = s:locate_command
  endif
  return map(
        \ split(
        \   unite#util#system(
        \     substitute(
        \       substitute(
        \         locate_command, '{count}', s:unite_source.max_candidates, ''),
        \       '{query}',
        \       a:context.input,
        \       '')),
        \   "\n"),
        \ '{
        \ "word": v:val,
        \ "source": "locate",
        \ "kind": "file",
        \ "action__path": v:val,
        \ "action__directory": fnamemodify(v:val, ":p:h"),
        \ }')
endfunction

function! unite#sources#locate#define()
  return exists('s:locate_command') ? s:unite_source : []
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
