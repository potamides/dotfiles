" use the system clipboard registers
set clipboard=unnamedplus

" Maintain undo history between sessions
set undofile 

" Enable Mouse
set mouse=a

" enable smart search
set ignorecase
set smartcase

" interactive search and replace
set inccommand=nosplit

" Set the hidden option so any buffer can be hidden (keeping its changes) without first writing the buffer to a file
set hidden

" make 'J' and 'gq' commands use one space after a period
set nojoinspaces

" Enable folding
set foldmethod=syntax
set foldlevel=99

" Tab (\t) stuff
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set expandtab
set smarttab

" Highlight 80th and 120th column
set colorcolumn=80,120

" turn off automatic line wrapping
"set nowrap

" highlight current line
" set cursorline 

" minimum of 5 lines between cursor and screen end
" set so=5

" use system python 3 for virtualenvs
let g:python3_host_prog = '/usr/bin/python3'

" jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Insert line break at column 80 and set spelllang in certain files
autocmd BufReadPost,BufNewFile *.md,*.txt,*.tex setlocal textwidth=79 | setlocal spell spelllang=en_us,de_de,cjk

" Open new terminals directly in insert mode
autocmd TermOpen * startinsert

" Open init.vim command
command! VimConfig :e $MYVIMRC

" To use Control+{h,j,k,l}` to navigate windows:
tnoremap <silent> <C-h> <C-\><C-N><C-w>h
tnoremap <silent> <C-j> <C-\><C-N><C-w>j
tnoremap <silent> <C-k> <C-\><C-N><C-w>k
tnoremap <silent> <C-l> <C-\><C-N><C-w>l
noremap <silent> <C-h> <C-w>h
noremap <silent> <C-j> <C-w>j
noremap <silent> <C-k> <C-w>k
noremap <silent> <C-l> <C-w>l

" To map <silent> <Esc> to exit terminal-mode:
tnoremap <silent> <Esc> <C-\><C-n>

" Toggle folding with the spacebar
noremap <silent> <space> za

" Run the current line as if it were a command
nnoremap <leader>e :exe getline(line('.'))<cr>

" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
Plug 'ryanoasis/vim-devicons'
Plug 'unblevable/quick-scope'
Plug 'honza/vim-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'hanw/vim-bluespec'
Plug 'potamides/painless-digraph'
Plug 'norcalli/nvim-colorizer.lua'
call plug#end()

" ------------------------------------------------
"               NUMBERS
" ------------------------------------------------

set number relativenumber

augroup numbertoggle
    autocmd!

    " Display absolute numbers when we lose focus
    " Display absolute numbers in insert mode
    autocmd FocusLost,WinLeave,InsertEnter * setlocal norelativenumber

    "Display relative numbers when we gain focus
    " Display relative numbers when we leave insert mode
    autocmd FocusGained,WinEnter,InsertLeave * if &number==1 | setlocal relativenumber | endif
    
    " Disable numbers for buffers with matching filetypes
    autocmd TermOpen,FileType term://*,defx setlocal nonumber
    
    " Disable relative numbers for buffers with matching filetypes
    autocmd TermOpen,FileType term://*,defx,qf setlocal norelativenumber
augroup END

" ------------------------------------------------
"               QUICK-SCOPE
" ------------------------------------------------

" use gruvbox bg colors to distinguish marked characters
augroup qs_colors
  autocmd!
  autocmd ColorScheme * highlight QuickScopePrimary guibg='#7c6f64'
  autocmd ColorScheme * highlight QuickScopeSecondary guibg='#504945' 
augroup END

" Trigger a highlight in the appropriate direction when pressing these keys
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" ------------------------------------------------
"               GRUVBOX
" ------------------------------------------------

" True Colors
set termguicolors

" Choose and configure a theme for vim
let g:gruvbox_contrast_dark='medium'
set background=dark
let g:gruvbox_italic=1
colorscheme gruvbox

" ------------------------------------------------
"               HEX-COLORIZER
" ------------------------------------------------

lua require'colorizer'.setup()

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

function! Fileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
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
    \   'fileencoding': 'Fileencoding',
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

" ------------------------------------------------
"               COC
" ------------------------------------------------

" Use <Tab> and <S-Tab> to navigate the completion list:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"let g:coc_snippet_next = '<tab>'
"let g:coc_snippet_prev = '<s-tab>'

" Fancier status signs
let g:coc_status_warning_sign = "\uf071 "
let g:coc_status_error_sign = "\uf05e "

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
  \ 'coc-lists',
  \)

" Show diagnostics in status line
let g:lightline.active.left = [ [ 'mode', 'paste' ], [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
let g:lightline.component_function = {'cocstatus': 'coc#status',
                                  \   'readonly': 'LightlineReadonly',
                                  \   'filetype': 'DevFiletype',
                                  \   'fileencoding': 'Fileencoding',
                                  \   'fileformat': 'DevFileformat',
	                              \ }

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

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
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" Correct comment highlighting of config
autocmd FileType json syntax match Comment +\/\/.\+$+

" Do CocList stuff
noremap <silent> <leader>cl :<C-u>CocList --number-select<cr>
noremap <silent> <leader>cg :<C-u>CocList --number-select --no-sort --interactive grep -smartcase<cr>
noremap <silent> <leader>cf :<C-u>CocList --number-select --no-sort files<cr>
noremap <silent> <leader>cb :<C-u>CocList --number-select bcommits<cr>
noremap <silent> <leader>cc :<C-u>CocList --number-select commands<cr>
noremap <silent> <leader>co :<C-u>CocList --number-select outline<cr>
noremap <silent> <leader>cs :<C-u>CocList --number-select --interactive symbols<cr>
noremap <silent> <leader>cd :<C-u>CocList --number-select diagnostics<cr>

tnoremap <silent> <C-p> <C-\><C-N>:<C-u>CocList --number-select --no-sort files<cr>
inoremap <silent> <C-p> <C-\><C-N>:<C-u>CocList --number-select --no-sort files<cr>
noremap <silent> <C-p> :<C-u>CocList --number-select --no-sort files<cr>
tnoremap <silent> <C-e> <C-\><C-N>:<C-u>CocList --number-select --no-sort --interactive grep -smartcase -workspace<cr>
inoremap <silent> <C-e> <C-\><C-N>:<C-u>CocList --number-select --no-sort --interactive grep -smartcase -workspace<cr>
noremap <silent> <C-e> :<C-u>CocList --number-select --no-sort --interactive grep -smartcase<cr>

" TEX
au BufReadPost,BufNewFile *.tex nnoremap <silent> <leader>bn :<C-u>CocCommand latex.Build<cr>
au BufReadPost,BufNewFile *.tex nnoremap <silent> <leader>cn :<C-u>CocCommand latex.BuildCancel<cr>
au BufReadPost,BufNewFile *.tex nnoremap <silent> <leader>fs :<C-u>CocCommand latex.ForwardSearch<cr>

"SCALA
" troubleshoot problems with the build workspace
au BufReadPost,BufNewFile *.scala,*.sbt nnoremap <silent> <leader>tb
            \ :<C-u>call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'doctor-run' })<cr>

" Manually start build import
au BufReadPost,BufNewFile *.scala,*.sbt nnoremap <silent> <leader>bi
            \ :<C-u>call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-import' })<cr>

" Manually connect with build server
au BufReadPost,BufNewFile *.scala,*.sbt nnoremap <silent> <leader>bc
            \ :<C-u>call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-connect' })<cr>

" watch the build import progress.
au BufReadPost,BufNewFile *.scala,*.sbt nnoremap <silent> <leader>bw
            \ :<C-u>execute "!tail -f " . g:WorkspaceFolders[0] . "/.metals/metals.log"<cr>
