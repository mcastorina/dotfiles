set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
"Plugin 'Valloric/YouCompleteMe'
Bundle 'myusuf3/numbers.vim'
Plugin 'taglist.vim'
Plugin 'scrooloose/syntastic'
Plugin 'sjl/gundo.vim'

call vundle#end()
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

" Escape key also mapped as pushing j and k
inoremap jk <Esc>
inoremap kj <Esc>
set timeoutlen=75

" This unsets the "last search pattern" register
nnoremap ,. :noh<CR>:<Backspace>

" F5 for taglist
nnoremap <F4> :GundoToggle<CR>
nnoremap <F5> :TlistToggle<CR><C-W><C-H>
nnoremap <F6> :NumbersToggle<CR>

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

command Latex execute "silent !pdflatex % > /dev/null && evince %:r.pdf > /dev/null 2>&1 &" | redraw!

" Printing
set printexpr=PrintFile(v:fname_in)
function PrintFile(fname)
    call system("lp -d PDF " . a:fname)
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
