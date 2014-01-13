if exists("g:vimfocus_is_loaded")
  finish
endif
let g:vimfocus_is_loaded = 1

if !exists("g:vf_per_indent_count")
  let g:vf_per_indent_count = 2
end

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

function! s:AddTaskToOF()
  let task_name = '"' . substitute(getline(getpos(".")[1]), "\"", "\\\\\"", "g") . '"'
  let script = "!osascript "
  let script = script." -e 'tell application \"OmniFocus\"'"
  let script = script." -e '  set doc to first document'"
  let script = script." -e '  set taskName to " . task_name . "'"
  let script = script." -e '  tell doc'"
  let script = script." -e '    make new inbox task with properties {name:taskName}'"
  let script = script." -e '  end tell'"
  let script = script." -e 'end tell'"
  silent execute script

  echo "task is added"
endfunction

function! s:AddTasksToOF() range
  let current = a:firstline
  let last = a:lastline

  let script = "!osascript "
  let script = script." -e 'tell application \"OmniFocus\"'"
  let script = script." -e '  set doc to first document'"
  let script = script." -e '  tell doc'"

  while current <= last
    let indent_count = s:getIndentCount(getline(current))
    let task_name = '"' . substitute(getline(current), "\"", "\\\\\"", "g") . '"'
    if !exists("first_indent_count")
      let first_indent_count = indent_count
    end

    let script = script." -e '    set taskName to " . task_name . "'"
    let script = script." -e '    set task" . indent_count . " to make new inbox task with properties {name:taskName}'"
    if indent_count > first_indent_count
      let before_indent_count = indent_count - g:vf_per_indent_count
      let script = script." -e '    move task" . indent_count . " to end of tasks of task" . before_indent_count . "'"
    endif
    let current = current + 1
  endwhile

  let script = script." -e '  end tell'"
  let script = script." -e 'end tell'"

  silent execute script

  echo "tasks are added"
endfunction

function! s:getIndentCount(task_name)
  let indent_str = matchstr(a:task_name, '^\s*')
  return strlen(indent_str)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
