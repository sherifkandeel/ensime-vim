if exists('g:loaded_ensime') || &cp
    finish
endif

function! s:Warn(msg)
    echohl WarningMsg | echomsg '[ensime] ' . a:msg | echohl None
endf

if !has('python')
    call s:Warn('Your Vim build is missing +python support, ensime-vim will not be loaded.')
    if has('nvim')
        call s:Warn('Did you remember to `pip2 install neovim`?')
    else
        call s:Warn('Please review the installation guide.')
    endif
    finish
endif

" Fail fast if dependencies are missing, we can't do much useful if so.
" We need to wrap this in a function, see :help script-here
function! s:DependenciesValid() abort
    python <<PY
import vim

# TODO: officially drop Vim < 7.4 support, inform users and don't load plugin
VIM74 = hasattr(vim, 'vars')

try:
    import sexpdata
    import websocket

    if VIM74:
        vim.vars['ensime_deps_valid'] = True
    else:
        vim.command('let g:ensime_deps_valid = 1')

    del sexpdata # Clean up the shared interpreter namespace
    del websocket
except ImportError:
    if VIM74:
        vim.vars['ensime_deps_valid'] = False
    else:
        vim.command('let g:ensime_deps_valid = 0')

del VIM74
PY

    return g:ensime_deps_valid
endfunction

if !s:DependenciesValid()
    call s:Warn('A dependency is missing, please `pip2 install sexpdata websocket-client` and restart Vim.')
    finish
endif

" For Neovim, defer to the rest to the rplugin
if has('nvim') | finish | endif

augroup ensime
    autocmd!
    autocmd VimLeave *.java,*.scala call ensime#au_vim_leave(expand("<afile>"))
    autocmd VimEnter *.java,*.scala call ensime#au_vim_enter(expand("<afile>"))
    autocmd BufLeave *.java,*.scala call ensime#au_buf_leave(expand("<afile>"))
    autocmd CursorHold *.java,*.scala call ensime#au_cursor_hold(expand("<afile>"))
    autocmd CursorMoved *.java,*.scala call ensime#au_cursor_moved(expand("<afile>"))
augroup END

command! -nargs=* -range EnInstall call ensime#com_en_install([<f-args>], '')
command! -nargs=* -range EnNoTeardown call ensime#com_en_no_teardown([<f-args>], '')
command! -nargs=* -range EnTypeCheck call ensime#com_en_type_check([<f-args>], '')
command! -nargs=* -range EnType call ensime#com_en_type([<f-args>], '')
command! -nargs=* -range EnTypeOnSelection call ensime#com_en_type_on_selection([<f-args>], '')
command! -nargs=* -range EnSearch call ensime#com_en_sym_search([<f-args>], '')
command! -nargs=* -range EnShowPackage call ensime#com_en_package_inspect([<f-args>], '')
command! -nargs=* -range EnDeclaration call ensime#com_en_declaration([<f-args>], '')
command! -nargs=* -range EnDeclarationSplit call ensime#com_en_declaration_split([<f-args>], '')
command! -nargs=* -range EnSymbolByName call ensime#com_en_symbol_by_name([<f-args>], '')
command! -nargs=* -range EnSymbol call ensime#com_en_symbol([<f-args>], '')
command! -nargs=* -range EnRename call ensime#com_en_rename([<f-args>], '')
command! -nargs=* -range EnInline call ensime#com_en_inline([<f-args>], '')
command! -nargs=* -range EnInspectType call ensime#com_en_inspect_type([<f-args>], '')
command! -nargs=* -range EnDocUri call ensime#com_en_doc_uri([<f-args>], '')
command! -nargs=* -range EnDocBrowse call ensime#com_en_doc_browse([<f-args>], '')
command! -nargs=* -range EnSuggestImport call ensime#com_en_suggest_import([<f-args>], '')
command! -nargs=* -range EnDebugBacktrace call ensime#com_en_debug_backtrace([<f-args>], '')
command! -nargs=* -range EnDebugClearBreaks call ensime#com_en_debug_clear_breaks([<f-args>], '')
command! -nargs=* -range EnDebugContinue call ensime#com_en_debug_continue([<f-args>], '')
command! -nargs=* -range EnDebugSetBreak call ensime#com_en_debug_set_break([<f-args>], '')
command! -nargs=* -range EnDebugStart call ensime#com_en_debug_start([<f-args>], '')
command! -nargs=* -range EnDebugStep call ensime#com_en_debug_step([<f-args>], '')
command! -nargs=* -range EnDebugStepOut call ensime#com_en_debug_step_out([<f-args>], '')
command! -nargs=* -range EnDebugNext call ensime#com_en_debug_next([<f-args>], '')
command! -nargs=0 -range EnClients call ensime#com_en_clients([<f-args>], '')
command! -nargs=* -range EnToggleFullType call ensime#com_en_toggle_fulltype([<f-args>], '')
command! -nargs=* -range EnOrganizeImports call ensime#com_en_organize_imports([<f-args>], '')
command! -nargs=* -range EnAddImport call ensime#com_en_add_import([<f-args>], '')

function! EnPackageDecl() abort
    return ensime#fun_en_package_decl()
endfunction

function! EnCompleteFunc(a, b) abort
    return ensime#fun_en_complete_func(a:a, a:b)
endfunction

let g:loaded_ensime = 1

" vim:set et sw=4 ts=4 tw=78:
