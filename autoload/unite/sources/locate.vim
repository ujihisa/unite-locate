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
  call system('locate -V')
  return !v:shell_error
endfunction
let s:additional_options = s:is_linux() ? '-e' : ''

function! s:unite_source.gather_candidates(args, context)
  return map(
        \ split(system(printf('locate -l %d %s %s', s:unite_source.max_candidates, s:additional_options, a:context.input), "\n")),
        \ '{
        \ "word": v:val,
        \ "source": "locate",
        \ "kind": "file",
        \ "action__path": v:val,
        \ "action__directory": fnamemodify(v:val, ":p:h"),
        \ }')
endfunction

function! unite#sources#locate#define()
  return executable('locate') ? s:unite_source : []
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
