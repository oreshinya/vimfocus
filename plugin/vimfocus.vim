if exists("g:vimfocus_is_loaded")
  finish
endif
let g:vimfocus_is_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>AddTaskToOF :AddTaskToOF<CR>
vnoremap <silent> <Plug>AddTasksToOF :AddTasksToOF<CR>

if !hasmapto('<Plug>AddTaskToOF')
  nmap <silent> <Leader>of <Plug>AddTaskToOF
endif
if !hasmapto('<Plug>AddTasksToOF')
  vmap <silent> <Leader>of <Plug>AddTasksToOF
endif

command! -nargs=0 AddTaskToOF call s:AddTaskToOF()
command! -range   AddTasksToOF <line1>,<line2>call s:AddTasksToOF()

function! s:AddTaskToOFInbox(task)
  let task = '"' . substitute(a:task, "\"", "\\\\\"", "g") . '"'
  let script = "!osascript "
  let script = script." -e 'tell application \"OmniFocus\"'"
  let script = script." -e '  set theDoc to first document'"
  let script = script." -e '  set theTask to " . task . "'"
  let script = script." -e '  tell theDoc'"
  let script = script." -e '    make new inbox task with properties {name:theTask}'"
  let script = script." -e '  end tell'"
  let script = script." -e 'end tell'"
  silent execute script
endfunction

function! s:AddTaskToOF()
  call s:AddTaskToOFInbox(getline(getpos(".")[1]))
  echo "task is added"
endfunction

function! s:AddTasksToOF() range
  let current = a:firstline
  let last = a:lastline

  while current <= last
    call s:AddTaskToOFInbox(getline(current))
    let current = current + 1
  endwhile

  echo "tasks are added"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
