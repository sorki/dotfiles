"vim: set ft=vim :
syntax on
filetype off
colorscheme srk

"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()

"Bundle 'Valloric/YouCompleteMe'
"
call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on

"let g:pymode_lint_checker = "pylint"
let g:pymode_lint_checker = "pyflakes,pep8,mccabe"
"let g:pymode_lint_ignore = "E124"
let g:pymode_lint_write = 1
let g:pymode_folding = 0

set autoindent
set modeline
set nowrap
set number
set numberwidth=2
set backspace=indent,eol,start
set history=50
set hlsearch
set ruler
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.info,.aux,.log,.dvi,.bbl,.out,.o,.lo,.pyo,.pyc
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
autocmd FileType python set complete+=k~/.vim/syntax/python.vim isk+=.,(
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufReadPost *.py retab
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``

" omni
autocmd FileType python set omnifunc=pythoncomplete#Complete

" python syntax
let python_highlight_all=1

" fix python path (outdated??)
python << EOF
import os
import sys
sys.path.append("/usr/lib/python2.6/site-packages")
EOF


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

let @t = 'r �krr $a \j�kh'
