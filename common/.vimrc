set nocompatible
call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'myusuf3/numbers.vim'
Plug 'taglist.vim'
Plug 'scrooloose/syntastic'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'

call plug#end()
filetype plugin indent on

syntax on
set number
autocmd vimEnter * NumbersOnOff
autocmd VimEnter * set number
set t_Co=256
colorscheme lapis256

set backspace=indent,eol,start

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent
set cindent

set incsearch
"set ignorecase
"set smartcase
set hlsearch

set ff=unix
set foldmethod=syntax
set nowrap

" Escape key also mapped as pushing j and k
inoremap jk <Esc>
inoremap kj <Esc>
autocmd InsertEnter * set timeoutlen=75
autocmd InsertLeave * set timeoutlen=1000

" This unsets the "last search pattern" register
nnoremap ,. :noh<CR>:<Backspace>

" Function binds
nnoremap <F4> :GundoToggle<CR>
nnoremap <F5> :TlistToggle<CR><C-W><C-H>
nnoremap <F6> :NumbersToggle<CR>
nnoremap <F7> :SyntasticToggleMode<CR>

" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_c_check_header = 1
let g:syntastic_c_no_default_include_dirs = 1
let g:syntastic_c_auto_refresh_includes = 1

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
nnoremap <PageDown> :tabm +<CR>
nnoremap <PageUp>   :tabm -<CR>

" Toggle folds
map <Space> za

" Format
nnoremap <C-O> !!fmt<CR>
nnoremap <C-P> :call StripTrailingWhitespaces()<CR>

" Underline
nnoremap + Yp<C-V>$r=

set showcmd

" End of line character
set listchars=tab:│\ ,eol:¬
set list

function! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

" Printing
set printexpr=PrintFile(v:fname_in,expand('%:t'))
function PrintFile(fname, oname)
    call system("lp -d PDF " . a:fname . " -t " . a:oname)
    call delete(a:fname)
    return v:shell_error
endfunc

" modify selected text using combining diacritics
command! -range -nargs=0 Overline        call s:CombineSelection(<line1>, <line2>, '0305')
command! -range -nargs=0 Underline       call s:CombineSelection(<line1>, <line2>, '0332')
command! -range -nargs=0 DoubleUnderline call s:CombineSelection(<line1>, <line2>, '0333')
command! -range -nargs=0 Strikethrough   call s:CombineSelection(<line1>, <line2>, '0336')

function! s:CombineSelection(line1, line2, cp)
  execute 'let char = "\u'.a:cp.'"'
  execute a:line1.','.a:line2.'s/\%V[^[:cntrl:]]/&'.char.'/ge'
endfunction

" Compile LaTex files and remove extra files
if !exists("g:latex_build") || !exists("g:latex_clean")
    let g:latex_build = "/usr/bin/latexmk -pdf -cd"
    let g:latex_clean = "/usr/bin/latexmk -cd -c"
endif
function! LatexBuild()
    let name = " " . shellescape(bufname("%")) . " "
    execute "!" . g:latex_build . name . "&&" . g:latex_clean . name
endfunction
command! -nargs=0 Latex call LatexBuild()