" use the system clipboard registers
set clipboard=unnamedplus

" Maintain undo history between sessions
set undofile 

" Enable Mouse
set mouse=a

" enable smart search
set ignorecase
set smartcase

" Set the hidden option so any buffer can be hidden (keeping its changes) without first writing the buffer to a file
set hidden

" turn off automatic line wrapping
"set nowrap

" hide highlighting of last search
command Clearpattern :let @/ = ""
command Cp Clearpattern

" Uncomment the following to have Vim jump to the last position when
" reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" To use Control+{h,j,k,l}` to navigate windows:
tnoremap <silent> <C-h> <C-\><C-N><C-w>h
tnoremap <silent> <C-j> <C-\><C-N><C-w>j
tnoremap <silent> <C-k> <C-\><C-N><C-w>k
tnoremap <silent> <C-l> <C-\><C-N><C-w>l
noremap <silent> <C-h> <C-w>h
noremap <silent> <C-j> <C-w>j
noremap <silent> <C-k> <C-w>k
noremap <silent> <C-l> <C-w>l

" Quickfix cycling
command! Cnext try | cnext | catch | cfirst | catch | endtry
command! Cprev try | cprev | catch | clast | catch | endtry
noremap <silent> <A-n> :Cnext<CR>
noremap <silent> <A-m> :Cprev<CR>

" j and k shall navigate displayed lines, useful when wrapping is enabled.
noremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
noremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
noremap <expr> <Down> v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
noremap <expr> <Up> v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Enable folding
set foldmethod=syntax
set foldlevel=99

" Toggle folding with the spacebar
noremap <silent> <space> za

" Tab (\t) stuff
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set expandtab
set smarttab

" Highlight 80th line
set colorcolumn=80,120

" Insert line break at column 80
au BufReadPost,BufNewFile *.md,*.txt,*.tex setlocal textwidth=79

" highlight current line
" set cursorline 

" minimum of 5 lines between cursor and screen end
" set so=5

" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'zchee/deoplete-jedi'
" Plug 'w0rp/ale'
" Plug g:plug_home.'/vim-jml'
Plug 'morhetz/gruvbox'
" Plug 'mhinz/vim-signify'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'universal-ctags/ctags' " installed with pacman
" Plug 'majutsushi/tagbar'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'mgee/lightline-bufferline'
Plug '/usr/bin/fzf'
Plug 'junegunn/fzf.vim'
"Plug 'lervag/vimtex'
Plug 'ryanoasis/vim-devicons'
Plug 'unblevable/quick-scope'
Plug 'leafgarland/typescript-vim'
" Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" ------------------------------------------------
"               NUMBERS
" ------------------------------------------------

set number relativenumber
" Display absolute numbers when we lose focus
autocmd FocusLost * set norelativenumber
"Display relative numbers when we gain focus
autocmd FocusGained * set relativenumber
" Display absolute numbers in insert mode
autocmd InsertEnter * set norelativenumber
" Display relative numbers when we leave insert mode
autocmd InsertLeave * set relativenumber

" Disable numbers for buffers with matching filetypes
autocmd FileType defx set nonumber
autocmd TermOpen term://* set nonumber

" Disable relative numbers for buffers with matching filetypes
autocmd FileType defx,qf set norelativenumber
autocmd TermOpen term://* set norelativenumber

" ------------------------------------------------
"               QUICK-SCOPE
" ------------------------------------------------

" use gruvbox bg colors to distinguish marked characters
augroup qs_colors
  autocmd!
  autocmd ColorScheme * highlight QuickScopePrimary guibg='#504945'
  autocmd ColorScheme * highlight QuickScopeSecondary guibg='#3c3836'
augroup END

" ------------------------------------------------
"               FZF.VIM
" ------------------------------------------------

" allows the usage of the path parameter of ripgrep
function RgWithPath(bang, ...)
    let path = get(a:000, 0, ".")
    let terms = a:000[1:]
    call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case "
    \.shellescape(join(terms, " "))." ".path, 1, a:bang)
endfunction
command! -bang -nargs=* Rg  call RgWithPath(<bang>0, <f-args>)

" close fzf split with escape
autocmd FileType fzf tnoremap <silent> <Esc> <C-\><C-N>:close<CR>

" ------------------------------------------------
"               GRUVBOX
" ------------------------------------------------

" Choose and configure a theme for vim
let g:gruvbox_contrast_dark='medium'
set background=dark    " Setting dark mode
let g:gruvbox_italic=1
colorscheme gruvbox

" True Colors
set termguicolors

" ------------------------------------------------
"               LIGHTLINE
" ------------------------------------------------

" Disable mode indicator because it is displayed in lightline
set noshowmode

function! LightlineReadonly()
	return &readonly ? '' : ''
endfunction

function! DevFiletype()
  return winwidth(0) > 70 ? WebDevIconsGetFileTypeSymbol() . ' ' . (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! DevFileencoding()
  return winwidth(0) > 70 ? (' ' . (strlen(&fileencoding) ? &fileencoding : 'utf-8')) : ''
endfunction

function! DevFileformat()
  return winwidth(0) > 70 ? (WebDevIconsGetFileFormatSymbol() . ' ' . &fileformat) : ''
endfunction

let g:lightline = {
    \ 'colorscheme': 'gruvbox',
	\ 'component': {
	\   'lineinfo': ' %3l:%-2v',
	\ },
	\ 'component_function': {
	\   'readonly': 'LightlineReadonly',
    \   'filetype': 'DevFiletype',
    \   'fileencoding': 'DevFileencoding',
    \   'fileformat': 'DevFileformat',
	\ },
    \ 'active': {
    \   'right': [['lineinfo'],
    \             ['percent'],
    \             ['fileformat', 'fileencoding', 'filetype']]
    \ },
	\ 'separator': { 'left': '', 'right': '' },
	\ 'subseparator': { 'left': '', 'right': '' }
	\ }

"" Register the components
"let g:lightline.component_expand = {
"      \  'linter_checking': 'lightline#ale#checking',
"      \  'linter_warnings': 'lightline#ale#warnings',
"      \  'linter_errors': 'lightline#ale#errors',
"      \  'linter_ok': 'lightline#ale#ok',
"      \ }
"
"" Set color to the components
"let g:lightline.component_type = {
"      \     'linter_checking': 'left',
"      \     'linter_warnings': 'warning',
"      \     'linter_errors': 'error',
"      \     'linter_ok': 'left',
"      \ }
"
"" Add the components to the lightline,
"let g:lightline.active = { 'right': [['linter_errors', 'linter_warnings', 'lineinfo'],
"      \              ['percent'],
"      \              ['fileformat', 'fileencoding', 'filetype']] }
"
"let g:lightline#ale#indicator_checking = "\uf110 "
"let g:lightline#ale#indicator_warnings = "\uf071  "
"let g:lightline#ale#indicator_errors = "\uf05e  "
"let g:lightline#ale#indicator_ok = "\uf00c "

" ------------------------------------------------
"               BUFFERLINE
" ------------------------------------------------

let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}

let g:lightline.component_type = {'buffers': 'tabsel'}

let g:lightline.tabline = {'left': [['buffers']], 'right': [['tabs']]}

let g:lightline.tab = {
    \ 'active': [ 'tabnum', 'modified' ],
    \ 'inactive': [ 'tabnum', 'modified' ] }

"Autocommand to update the modified indicator
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()

"Use unicode symbols for modified and read-only buffers as well as the more buffers indicator
let g:lightline#bufferline#unicode_symbols=1

"Enables the usage of vim-devicons to display a filetype icon for the buffer.
let g:lightline#bufferline#enable_devicons=1

"The minimum number of buffers needed to automatically show the tabline
let g:lightline#bufferline#min_buffer_count=2

" use TAB to navigate buffers
noremap <silent> <Tab> :bnext<CR>  
noremap <silent> <S-Tab> :bprev<CR>

" close a buffer
tnoremap <silent> <C-q> <C-\><C-N>:bp\|bd #<CR>
inoremap <silent> <C-q> <C-\><C-N>:bp\|bd #<CR>
nnoremap <silent> <C-q> :bp\|bd #<CR>

" navigate tabs
noremap <silent> tk :tabnext<CR>  
noremap <silent> tj :tabprev<CR>

" ------------------------------------------------
"               RANGER
" ------------------------------------------------

" Open ranger fm with F2
"noremap <silent> <F2> :call RangerOpen()<cr>
"inoremap <silent> <F2> <C-\><C-N>:call RangerOpen()<cr>
"tnoremap <silent> <F2> <C-\><C-N>:call RangerOpen()<cr>



"function! RangerOpen()
"" Terminals in vim have a strange path which would cause problems with
"" ranger fm
"	:if strcharpart(expand('%:p:h'), 0, 10)=="term://.//"
"		:tabe
"		let cur=tabpagenr()
"		:RangerTab
"		:exec 'tabclose' cur
"	:else
"		:RangerTab
"	:endif
"endfunction

" ------------------------------------------------
"               TERMINAL
" ------------------------------------------------


" Toggle Terminal at the Bottom of the screen
let s:termBuf=-1
let s:winID=-1
function! ToggleTerm()
    if bufexists(s:termBuf) && bufwinnr(s:termBuf) != -1
        execute win_id2win(s:winID).'wincmd c'
    else
        botright 10split
        setlocal winfixheight
        if bufexists(s:termBuf)
            execute "edit#". s:termBuf
        else
	        terminal
            let s:termBuf=bufnr('%')
        endif
        setlocal bufhidden=hide noswapfile nobuflisted
        let s:winID=win_getid()
    endif
endfunction

function! TermClose()
    if bufexists(s:termBuf) && bufwinnr(s:termBuf) != -1
        execute win_id2win(s:winID).'wincmd c'
    endif
endfunction

" Toggle Terminal with F3
noremap <silent> <F3> :call ToggleTerm()<cr>
inoremap <silent> <F3> <C-\><C-N>:call ToggleTerm()<cr>
tnoremap <silent> <F3> <C-\><C-N>:call ToggleTerm()<cr>

" To map <silent> <Esc> to exit terminal-mode:
tnoremap <silent> <Esc> <C-\><C-n>

" To simulate |i_CTRL-R| in terminal-mode:
tnoremap <silent> <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

" Automatically insert Terminal window when entered
autocmd TermOpen,BufEnter,BufWinEnter term://* startinsert

" ------------------------------------------------
"               DEFX
" ------------------------------------------------

" Define mappings
autocmd FileType defx call s:defx_my_settings()
    function! s:defx_my_settings() abort
      nnoremap <silent><buffer><expr> <CR>
      \ defx#is_directory() ? defx#do_action('open_or_close_tree') : defx#do_action('drop')
      nnoremap <silent><buffer><expr> yy
      \ defx#do_action('copy')
      nnoremap <silent><buffer><expr> dd
      \ defx#do_action('move')
      nnoremap <silent><buffer><expr> pp
      \ defx#do_action('paste')
      nnoremap <silent><buffer><expr> l
      \ defx#do_action('open')
      nnoremap <silent><buffer><expr> E
      \ defx#do_action('open', 'vsplit')
      nnoremap <silent><buffer><expr> nd
      \ defx#do_action('new_directory')
      nnoremap <silent><buffer><expr> nf
      \ defx#do_action('new_file')
      nnoremap <silent><buffer><expr> S
      \ defx#do_action('toggle_sort', 'Time')
      nnoremap <silent><buffer><expr> dD
      \ defx#do_action('remove')
      nnoremap <silent><buffer><expr> a
      \ defx#do_action('rename')
      nnoremap <silent><buffer><expr> zh
      \ defx#do_action('toggle_ignored_files')
      nnoremap <silent><buffer><expr> h
      \ defx#do_action('cd', ['..'])
      nnoremap <silent><buffer><expr> gh
      \ defx#do_action('cd')
      nnoremap <silent><buffer><expr> q
      \ defx#do_action('quit')
      nnoremap <silent><buffer><expr> <Space>
      \ defx#do_action('toggle_select') . 'j'
      nnoremap <silent><buffer><expr> v
      \ defx#do_action('toggle_select_all')
      nnoremap <silent><buffer><expr> j
      \ line('.') == line('$') ? 'gg' : 'j'
      nnoremap <silent><buffer><expr> k
      \ line('.') == 1 ? 'G' : 'k'
      nnoremap <silent><buffer><expr> cd
          \ defx#do_action('change_vim_cwd')
    endfunction

call defx#custom#column('mark', {
      \ 'readonly_icon': '✗',
      \ 'selected_icon': '✓',
      \ })

call defx#custom#column('icon', {
      \ 'directory_icon': '',
      \ 'root_icon': '',
      \ 'opened_icon': '',
      \ })

" Toggle Defx with F2
noremap <silent> <F2> :Defx -split=vertical -toggle -resume -direction=topleft -winwidth=25<cr>
inoremap <silent> <F2> <C-\><C-N>:Defx -split=vertical -toggle -resume -direction=topleft -winwidth=25<cr>
tnoremap <silent> <F2> <C-\><C-N>:Defx -split=vertical -toggle -resume -direction=topleft -winwidth=25<cr>

" ------------------------------------------------
"               DEOPLETE
" ------------------------------------------------
"
"" Use deoplete.
"let g:deoplete#enable_at_startup = 1
"" Use smartcase.
"call deoplete#custom#option('smart_case', v:true)
"
"" disable preview window
"set completeopt-=preview
"" disable status messages
"set shortmess+=c
"
"" Disable the candidates in Comment/String syntaxes.
"call deoplete#custom#source('_',
"            \ 'disabled_syntaxes', ['Comment', 'String'])
"
"" automatically close scratchpad
"autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | sil! pclose | endif
"
"" close popup with escape if it is visible
""inoremap <expr> <esc> pumvisible()? deoplete#mappings#close_popup() : "\<esc>"
"
" ------------------------------------------------
"               ULTISNIPS
" ------------------------------------------------
"
"" Trigger configuration. Because default conflicts with other stuff, set
"" expandtrigger to smth i'd never use (<nop> doesnt work unfortunately)
"let g:UltiSnipsExpandTrigger="⚠"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
"
"" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"
"
"" expand and jump with tab and s-tab or navigate deoplete when completion
"" window is open
"function TabAction()
"   call UltiSnips#ExpandSnippet()
"   if g:ulti_expand_res == 1
"       return ""
"   endif
"   if pumvisible()
"       return "\<down>"
"   endif 
"   return "\<tab>"
"endfunction
"
"inoremap <silent><tab> <C-R>=TabAction()<CR>
"inoremap <silent><expr><s-tab> pumvisible() ? "\<up>" : "\<s-tab>"
"
" ------------------------------------------------
"               COC
" ------------------------------------------------

" Use <Tab> and <S-Tab> to navigate the completion list:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<s-tab>'

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Config extensions to install
call coc#add_extension(
  \ 'coc-snippets',
  \ 'coc-syntax',
  \ 'coc-json',
  \ 'coc-python',
  \ 'coc-texlab',
  \ 'coc-git',
  \)

" Show diagnostics in status line
let g:lightline.active.left = [ [ 'mode', 'paste' ], [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
let g:lightline.component_function = {'cocstatus': 'coc#status',
                                  \   'readonly': 'LightlineReadonly',
                                  \   'filetype': 'DevFiletype',
                                  \   'fileencoding': 'DevFileencoding',
                                  \   'fileformat': 'DevFileformat',
	                              \ }

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

"The highlight used for error text.
highlight link CocErrorSign  GruvboxRedSign
highlight link CocErrorFloat  GruvboxRed

"The highlight used for warning text.
highlight link CocWarningSign GruvboxYellowSign
highlight link CocWarningFloat GruvboxYellow

"The highlight used for information text.
highlight link CocInfoSign GruvboxGreenSign
highlight link CocInfoFloat GruvboxGreen

"The highlight used for hint text.
highlight link CocHintFloat  GruvboxBlue

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
"set shortmess+=c

" Use <C-n> and <C-m> to navigate diagnostics
nmap <silent> <C-n> <Plug>(coc-diagnostic-next)
nmap <silent> <C-m> <Plug>(coc-diagnostic-prev)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')

" Open CocList
nnoremap <silent> gc  :<C-u>CocList<cr>

" Correct comment highlighting of config
autocmd FileType json syntax match Comment +\/\/.\+$+

" TEX
au BufReadPost,BufNewFile *.tex nnoremap <leader>bn :<C-u>CocCommand latex.Build<cr>
au BufReadPost,BufNewFile *.tex nnoremap <leader>cn :<C-u>CocCommand latex.BuildCancel<cr>
au BufReadPost,BufNewFile *.tex nnoremap <leader>fs :<C-u>CocCommand latex.ForwardSearch<cr>

"SCALA
" troubleshoot problems with the build workspace
au BufReadPost,BufNewFile *.scala,*.sbt nnoremap <leader>tb 
            \ :<C-u>call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'doctor-run' })<cr>

" ------------------------------------------------
"               ALE
" ------------------------------------------------
"
"" Configure code style fixers
"let g:ale_fixers = {
"\   'python': ['autopep8'],
"\}
"
"" detect wether the file is inside a pipenv
"let g:ale_python_flake8_auto_pipenv= 1
"
"" don't display the line too long errors
"let g:ale_python_flake8_options = "--ignore=E501"
"
"" use c++17
"let g:ale_cpp_gcc_options = "-std=c++17 -Wall -Wextra -Wpedantic"
"
"" Populate the Quickfix list with error messages
""let g:ale_set_quickfix = 1
"
"" Fix Code style with F6
"inoremap <silent> <F6> <C-\><C-N>:ALEFix<CR> 
"noremap <silent> <F6> :ALEFix<CR>  
"
"" Enable completion where available.
""let g:ale_completion_enabled = 1
"
"" Ale error jumping
"nmap <silent> <C-m> <Plug>(ale_previous_wrap)
"nmap <silent> <C-n> <Plug>(ale_next_wrap)
"
"" fancier symbols
"let g:ale_sign_warning = '▌'
"let g:ale_sign_error = '▌'
"
" ------------------------------------------------
"               SIGNIFY
" ------------------------------------------------
"
"" enable more aggressive sign updates
"let g:signify_realtime = 1
"
"" Disables writing files to disk
"let g:signify_cursorhold_normal = 0
"let g:signify_cursorhold_insert = 0
"
"let g:signify_vcs_list              = [ 'git' ]
"
"let g:signify_sign_add               = '▌'
"let g:signify_sign_delete            = '▁'
"let g:signify_sign_delete_first_line = '▔'
"let g:signify_sign_change            = '▌'
"let g:signify_sign_changedelete      = g:signify_sign_change
"
" ------------------------------------------------
"               TAGBAR
" ------------------------------------------------
"
"" let g:tagbar_ctags_bin = '~/.local/share/nvim/plugged/ctags/ctags'
"let g:tagbar_width = 25
"let g:tagbar_autofocus = 1
"" omit the short help at the top of the window
"let g:tagbar_compact = 1
"
"" Toggle Tagbar with F4
"noremap <silent> <F4> :TagbarToggle<cr>
"inoremap <silent> <F4> <C-\><C-N>:TagbarToggle<cr>
"tnoremap <silent> <F4> <C-\><C-N>:TagbarToggle<cr><esc>
"
" ------------------------------------------------
"               VIMTEX
" ------------------------------------------------
"
"" use neovim-remote to search stuff in the pdf viewer
"let g:vimtex_compiler_progname = 'nvr'
"
"" leader required to use the texvim mappings
"let maplocalleader = '_'
"
"" don't open the quickfix window automatically
"let g:vimtex_quickfix_mode = 0
"
""let g:vimtex_view_general_viewer = 'llpp'
"let g:vimtex_view_method = 'mupdf'
"
"" Close viewers on quit
"function! CloseViewers()
"  if executable('xdotool') && exists('b:vimtex')
"      \ && exists('b:vimtex.viewer') && b:vimtex.viewer.xwin_id > 0
"    call system('xdotool windowclose '. b:vimtex.viewer.xwin_id)
"  endif
"endfunction
"
"augroup vimtex_event_2
"  au!
"  au User VimtexEventQuit call CloseViewers()
"augroup END
"
"" enable deoplete completion
"if !exists('g:deoplete#omni#input_patterns')
"    let g:deoplete#omni#input_patterns = {}
"endif
"let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete
"
"" enable the vimtex folds
"let g:vimtex_fold_enabled = 1
"
"" Compile Latex with F5
"inoremap <silent> <F5> <C-\><C-N>:VimtexCompile<CR> 
"noremap <silent> <F5> :VimtexCompile<CR>  
"
"" Delete auxiliary files when you quit vim
"augroup vimtex_config
"  au!
"  au User VimtexEventQuit call vimtex#compiler#clean(0)
"augroup END
"
" ------------------------------------------------
"               MISC
" ------------------------------------------------

" Close vim automatically if the remaining buffers belong to that stuff
function! CheckLeftBuffers()
  if tabpagenr('$') == 1
    let i = 1
    while i <= winnr('$')
      if getbufvar(winbufnr(i), '&buftype') == 'help' ||
          \ getbufvar(winbufnr(i), "&filetype")=="netrw" ||
          \ getbufvar(winbufnr(i), "&filetype")=="tagbar" ||
          \ getbufvar(winbufnr(i), "&buftype")=="terminal" ||
          \ getbufvar(winbufnr(i), '&buftype') == 'quickfix' ||
          \ getbufvar(winbufnr(i), "&filetype")=="defx"
        let i += 1
      else
        break
      endif
    endwhile
    if i == winnr('$') + 1
      qall
    endif
    unlet i
  endif
endfunction

autocmd BufEnter * call CheckLeftBuffers()


" Toggle Quickfix window
"function! QuickfixToggle()
"    call TermClose()
"    let nr = winnr("$")
"    botright cwindow
"    exe "wincmd p"
"    let nr2 = winnr("$")
"    if nr == nr2
"        cclose
"    endif
"endfunction
"
"inoremap <silent> <F4> <C-\><C-N>:call  QuickfixToggle()<CR> 
"tnoremap <silent> <F4> <C-\><C-N>:call  QuickfixToggle()<CR> 
"noremap <silent> <F4> :call QuickfixToggle()<CR>
"
"" Disable the relative numbers in the quickfix window
"autocmd BufEnter * if getbufvar(bufnr("%"), '&buftype') == 'quickfix' | set norelativenumber | endif
