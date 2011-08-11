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

if exists('g:unite_locate_command')
  let s:locate_command = g:unite_locate_command
elseif executable('locate')
  let s:locate_command = 'locate -l %d'.(s:is_linux() ? ' -e' : '').' %s'
elseif (has('win32') || has('win64')) && executable('es')
  let s:locate_command = 'es -i -r -n %d %s'
endif

function! s:unite_source.gather_candidates(args, context)
  return map(
        \ split(
        \   unite#util#system(printf(
        \     s:locate_command,
        \     s:unite_source.max_candidates,
        \     a:context.input)),
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
