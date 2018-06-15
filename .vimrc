"vim: set ft=vim :
syntax on
filetype off
colorscheme srk

let maplocalleader = "\<Space>"

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"Bundle 'Valloric/YouCompleteMe'
"Bundle 'chikamichi/mediawiki.vim'
Bundle 'LnL7/vim-nix'
Bundle 'gmarik/vundle'
Bundle 'munshkr/vim-tidal'
"
"call pathogen#infect()
"call pathogen#helptags()

filetype plugin indent on
syntax on

"let g:pymode_lint_checker = "pylint"
let g:pymode_lint_checker = "pyflakes,pep8,mccabe"
"let g:pymode_lint_ignore = "E124"
"let g:pymode_lint_write = 1
let g:pymode_folding = 0

set autoindent
set smarttab
set modeline
set nowrap
set number
set numberwidth=2
set backspace=indent,eol,start
set history=1000
set undolevels=1000
set hlsearch
set incsearch
set ruler
set suffixes=bak,~,.o,.h,.info,.swp,.obj,.info,.aux,.log,.dvi,.bbl,.out,.o,.lo,.pyo,.pyc
set previewheight=40
set foldminlines=8

" mouse everywhere
set mouse=a

" force utf-8
set encoding=utf8
set termencoding=utf8
set fileencodings=utf-8,default

" list evil characters
set nolist
set list lcs=nbsp:·,tab:··,trail:·
set grepprg=grep\ -nH\ $*

" nocompatible
if &cp | set nocp | endif

" exit insert mode with jj
ino jj <esc>
cno jj <c-c>

""""""""""""""""
" python       "
""""""""""""""""
" fixes, cfgs 
" autocmd FileType python set complete+=k~/.vim/syntax/python.vim isk+=.,(
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufReadPost *.py retab
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``

" omni
" autocmd FileType python set omnifunc=pythoncomplete#Complete

" python syntax
let python_highlight_all=1

" fix python path (outdated??)
" python << EOF
" import os
" import sys
" sys.path.append("/usr/lib/python2.6/site-packages")
" EOF


""""""""""""""""
" nerdtree     "
""""""""""""""""
let NERDTreeChDirMode=2
let NERDTreeShowBookmarks=1
let NERDTreeWinPos="right"
let NERDTreeIgnore=['\~$','\.pyc$']

map <Leader>x :NERDTree<CR>
map <Leader>c :NERDTreeClose<CR>
"autocmd VimEnter * NERDTree
"autocmd VimEnter * map o i

""""""""""""""""
" javascript   "
""""""""""""""""
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

""""""""""""""""
" html         "
""""""""""""""""
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

""""""""""""""""
" css          "
""""""""""""""""
autocmd FileType css set omnifunc=csscomplete#CompleteCSS


" Move Backup Files to ~/.vim/sessions
" ------------------------------------
set backupdir=~/.vim/sessions
set dir=~/.vim/sessions

" Highlight NBSP
" --------------
"  wanna see them
function! HighlightNonBreakingSpace()
  syn match suckingNonBreakingSpace " " containedin=ALL
  hi suckingNonBreakingSpace guibg=#157249
endfunction
autocmd BufEnter * :call HighlightNonBreakingSpace()

set completeopt-=preview
set completeopt+=longest
set gcr=a:blinkon0

" tabs
let g:SeeTabCtermFG="darkblue"
" whitespace
let b:ws_flags='eist'

" taglist
let Tlist_GainFocus_On_ToggleOpen = 0
let Tlist_Exit_OnlyWindow = 1


" latexsuite
let g:Tex_DefaultTargetFormat = 'ps'
let g:Tex_ViewRule_ps = 'evince'

ab sefl self

" !! Mess !!
" ??
"let s:cpo_save=&cpo
"set cpo&vim
"let &cpo=s:cpo_save
"unlet s:cpo_save
"

"if has('gui_running')
"  colorscheme elflord
"else
"  colorscheme zellner
"endif

"highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey
"highlight Folded term=bold cterm=NONE ctermfg=Grey ctermbg=DarkGrey


" macros

let @t = 'r ?krr $a \j?kh'


let mapleader = "\<Space>"
nnoremap <Leader><Leader> :w<CR>
nnoremap <Leader>q :wq<CR>

vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" vp doesn't replace paste buffer
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()

nnoremap <CR> G
nnoremap <BS> gg

map q: :q
set pastetoggle=<F1>

nnoremap j gj
nnoremap k gk

map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

nmap <silent> <Leader>/ :nohlsearch<CR>

"map <Leader>s :let g:pymode_lint=0<CR>

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

set virtualedit=all
