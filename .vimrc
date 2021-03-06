"" .vimrc configuration

" normal mode keymaps
inoremap jj <ESC>
inoremap jk <ESC>

syntax enable
set autoindent
set clipboard=unnamed
set cmdheight=2
set conceallevel=0
set cursorline
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set filetype=on
set mouse=a
set nocompatible
set noshowmode
set nowrap
set number
set ruler
set shiftwidth=2
set showtabline=2
set smartindent
set smarttab
set splitbelow
set splitright
set t_Co=256
set tabstop=2
set timeoutlen=1000
set ttimeoutlen=0
set visualbell

" set cursor styles during normal and insert modes
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" set cursor styles during normal and insert modes NOT MacOS + iTerm2
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul

" switching between tabs
nnoremap H gT
nnoremap L gt

noremap <C-t> :tabnew<CR>
" fzf file search
nnoremap <silent> <C-p> :FZF<CR>

call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'
Plug 'dense-analysis/ale'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'rust-lang/rust.vim'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'
call plug#end()

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" Mirror the NERDTree before showing it. This makes it the same on all tabs.
nnoremap <C-b> :NERDTreeMirror<CR>:NERDTreeToggle<CR>

" color scheme
set bg=dark
let g:gruvbox_contrast_dark='hard' " soft, medium, hard
colorscheme gruvbox
let g:airline_theme = 'gruvbox'

" cycle through autocomplete menu with tab
inoremap <silent><expr><TAB>
	\ pumvisible() ? "\<C-n>" : "\<TAB>"

let g:ale_linters_explicit = 1
let g:ale_completion_autoimport = 1
let g:ale_completion_enabled = 1
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_set_balloons = 1
let g:ale_rust_rustfmt_options = '--edition 2018'

let g:ale_linters = {
	\ 'rust': ['analyzer'],
	\ 'go': ['gopls'],
	\ 'typescript': ['eslint', 'tsserver'],
	\ 'javascript': ['eslint', 'tsserver'],
	\ 'typescriptreact': ['eslint', 'tsserver'],
	\ 'javascriptreact': ['eslint', 'tsserver'],
	\ 'python': ['pyright']
	\}

let g:ale_fixers = {
	\ '*': ['remove_trailing_lines', 'trim_whitespace'],
	\ 'rust': ['rustfmt'],
	\ 'go': ['gofmt'],
	\ 'json': ['prettier'],
	\ 'typescript': ['prettier', 'eslint'],
	\ 'javascript': ['prettier', 'eslint'],
	\ 'typescriptreact': ['prettier', 'eslint'],
	\ 'javascriptreact': ['prettier', 'eslint']
	\ }
