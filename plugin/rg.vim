let s:is_win = has('win32') || has('win64')
if s:is_win && &shellslash
  set noshellslash
  let s:base_dir = expand('<sfile>:h:h')
  set shellslash
else
  let s:base_dir = expand('<sfile>:h:h')
endif

echo s:base_dir
if s:is_win
	let $PATH=$PATH.";".s:base_dir."\\bin"
else
	let $PATH=$PATH.":".s:base_dir."/bin"
endif

function! s:run_term(cmd, cwd, success_info) abort
  belowright 10new
  setlocal buftype=nofile winfixheight norelativenumber nonumber bufhidden=wipe

  let bufnr = bufnr('')

  function! s:OnExit(status) closure abort
    if a:status == 0
      execute 'silent! bd! '.bufnr
      call clap#helper#echo_info(a:success_info)
    endif
  endfunction

  if has('nvim')
    call termopen(a:cmd, {
          \ 'cwd': a:cwd,
          \ 'on_exit': {job, status -> s:OnExit(status)},
          \})
  else
    call term_start(a:cmd, {
          \ 'curwin': 1,
          \ 'cwd': a:cwd,
          \ 'exit_cb': {job, status -> s:OnExit(status)},
          \})
  endif

  normal! G

  noautocmd wincmd p
endfunction

function rg#install() abort
	if s:is_win
		let cmd = 'Powershell.exe -ExecutionPolicy ByPass -File "'.s:base_dir.'\install.ps1"'
	else
		let cmd = './install.sh'
	endif
	call s:run_term(cmd, s:base_dir, 'download the rg binary successfully')
endfunction