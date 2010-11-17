let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'locate',
      \ 'max_candidates': 30,
      \ 'is_volatile' : 1,
      \ }

function! s:unite_source.gather_candidates(args, context)
  if len(a:context.input) < 3
    return []
  endif

  return map(
        \ split(system(printf('locate -l %d %s', s:unite_source.max_candidates, a:context.input), "\n")), '{
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
