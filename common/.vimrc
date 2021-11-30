"install VimPlug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'myusuf3/numbers.vim'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
" Plug 'tpope/vim-rails'
Plug 'MarcWeber/vim-addon-mw-utils'
" Plug 'tomtom/tlib_vim'
" Plug 'garbas/vim-snipmate'
" Plug 'honza/vim-snippets'
Plug 'fatih/vim-go'
Plug 'vim-scripts/paredit.vim'
Plug 'sheerun/vim-polyglot'
Plug 'zakuro9715/vim-vtools', { 'branch': 'main' }
Plug 'dense-analysis/ale'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'sevko/vim-nand2tetris-syntax'

call plug#end()
filetype plugin indent on

" Function binds
nnoremap <F3> :Lexplore<CR>
nnoremap <F4> :GundoToggle<CR>
nnoremap <F5> :TlistToggle<CR><C-W><C-H>
nnoremap <F6> :NumbersToggle<CR>

" nerd tree style file browser
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15
let g:netrw_sort_sequence = '[\/]$,*'

" This is <C-Enter> (as mapped via URxvt.keysym in ~/.Xresources)
nmap <C-Down> :let netrw_browse_split = 3<CR><CR>gT:let netrw_browse_split = 4<CR>

syntax on
set number
autocmd VimEnter * set number
set t_Co=256
colorscheme lapis256

" associate .v with Vlang files
autocmd BufRead,BufNewFile *.v set filetype=vlang
" disable auto format
let g:vfmt = 0

" rust language server configuration
autocmd BufReadPost *.rs setlocal filetype=rust
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

" Maps gd to goto definition
nnoremap <silent> gd :ALEGoToDefinition<CR>

"set backspace=indent,eol,start
set clipboard=unnamedplus

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent
set cindent

" set line cursor
set cursorline

set ff=unix
set foldmethod=syntax

"let maplocalleader="\\"

" Escape key also mapped as pushing j and k
inoremap jk <Esc>
inoremap kj <Esc>
autocmd InsertEnter * set timeoutlen=75
autocmd InsertLeave * set timeoutlen=1000

" Semicolon in normal mode is the same as colon
nnoremap ; :

" Gundo
let g:gundo_width = 30
let g:gundo_preview_height = 10

" Split moving
set splitbelow
set splitright
nnoremap <C-L> <C-W>w
nnoremap <C-H> <C-W>W

" Tab moving
nnoremap <C-J> :tabnext<CR>
nnoremap <C-K> :tabprev<CR>
" Corresponds to ~/.Xresources mapping for Ctrl-Shift-J/K
nnoremap <C-Right> :tabmove +<CR>
nnoremap <C-Left> :tabmove -<CR>

" Highlight word (without going to the next one)
nnoremap <C-N> *N

" Toggle folds
map <Space> za

" GOTO file will open in new tab
map gf <C-W>gF

" Format
nnoremap <C-O> !!fmt<CR>
nnoremap <C-P> :call StripTrailingWhitespaces()<CR>

" Underline
nnoremap + Yp<C-V>$r=

" Columnize
"   a
"   b       a   b
"   c       c   d
"   d
vnoremap <C-O> !awk '{ORS = (NR\%2 ? FS : RS)} 1' \| column -t<CR>
vnoremap <Enter> :<C-u>call SendFunnel()<CR>:<BS>

" End of line character
set listchars=tab:│\ ,eol:¬
set list

function! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! SendTerm()
    let data = s:get_visual_selection() . "\<CR>"
    " get the buffer window number for bash
    let bnr = buffer_number('!bash')
    if bnr > 0
        call term_sendkeys(bnr, data)
    else
        " spawn the bash terminal if not found
        vertical terminal bash
        call term_sendkeys(buffer_number('!bash'), data)
    endif
endfunction

function! SendFunnel()
    let data = s:get_visual_selection() . "\n"
    call system("funnel", data)
endfunction
