# BASHrc
# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker foldmarker=-{,}- fml=1:

if [[ $- != *i* ]] ; then
  # Shell is non-interactive.  Be done now!
  return
fi

# load system specific
if [ -f ~/.bash_local ]; then
  . ~/.bash_local
fi

export LANG="en_US.utf-8"
#export LC_ALL="en_US.utf-8"

export EDITOR="vim"
export PATH=$PATH:$HOME/bin
export HISTSIZE=100000000000000000
shopt -s histappend

# prompt -{
# colors -{
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
PURPLE='\[\033[01;35m\]'
CYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'
NIL='\[\033[00m\]'
# }-
# hostname style
FULL='\H'
SHORT='\h'
#   UC: username color
#   LC: location/cwd color
#   HC: hostname color
#   HD: hostname display (\h vs \H)
# Defaults:
UC=$GREEN
LC=$BLUE
HC=$GREEN
HD=$SHORT

HOST=`hostname | cut -d '.' -f 1`
DOMAIN=`hostname | cut -d '.' -f 2-`

if [ $HOST != "grampi" ]; then
  HC=$RED
fi

function set_prompt {
  RET=$?

  # Shorten path, if shortened prepend ... -{
  # how many characters of the $PWD should be kept
  local pwd_length=23
  nPWD="$PWD"
  if [[ "$PWD" =~ "$HOME" ]]; then
    if [[ "$PWD" = "$HOME" ]]; then
        nPWD="~"
      else
        nPWD="~`echo -n ${PWD#*$HOME}`"
      fi
  fi
  if [ $(echo -n $nPWD | wc -c | tr -d " ") -gt $pwd_length ]; then
    newPWD="...$(echo -n $nPWD | sed -e "s/.*\(.\{$pwd_length\}\)/\1/")"
  else
    newPWD="$(echo -n $nPWD)"
  fi
  # }-

 # Virtualenv -{
_venv=`basename "$VIRTUAL_ENV"`
venv="" # need this to clear it when we leave a venv
if [[ -n $_venv ]]; then
    venv="${NIL}(${_venv}${NIL})"
fi
# }-

  # Git branch / dirtiness -{
  if git update-index -q --refresh 2>/dev/null; git diff-index --quiet --cached HEAD --ignore-submodules -- 2>/dev/null && git diff-files --quiet --ignore-submodules 2>/dev/null
    then dirty=""
  else
    dirty="${RED}*${NIL}"
  fi
  _branch=$(git symbolic-ref HEAD 2>/dev/null)
  _branch=${_branch#refs/heads/}
  branch=""
  if [[ -n $_branch ]]; then
    branch="${NIL}[${WHITE}${_branch}${dirty}${NIL}]"
  fi
#  if [[ $PWD == $HOME* ]]; then
#    branch=""
#    if [ $PWD = $HOME ]; then
#      branch=$dirty
#    fi
#  fi
  # }-

  host="${HC}@${HD}${NIL}"

  if [ "$USER" = "root" ]; then
    user="${RED}\u${NIL}"
    end_char="#"
  else
    user="${UC}\u${NIL}"
    end_char="$"
  fi

  if [ "x$IN_NIX_SHELL" != "x" ]; then
    nixshell="[${GREEN}${IN_NIX_SHELL}${NIL}]"
  else
    nixshell=""
  fi

  path="${LC}${newPWD}${NIL}"

  if [ $RET = 0 ]; then
    end="${LC}${end_char} ${NIL}"
  else
    end="${RED}${end_char} ${NIL}"
  fi

  # prompt styles
  case $PROMPT_STYLE in
    default )
      export PS1="${nixshell}${venv}${branch}${user}${at}${host} ${path} ${end}" ;;
    long )
      export PS1="\n${nixshell}${venv}${branch}${user}${at}${host} ${PWD} \n${end}" ;;
  esac

  PS1="\[\033[G\]$PS1"
}

export PROMPT_COMMAND=set_prompt


function prompt_long() {
  export PROMPT_STYLE=long
}
function prompt_default() {
  export PROMPT_STYLE=default
}

prompt_long

# }-

# ALIASES -{
# common -{

# ls
alias ls='ls --color=always'
alias la='ls -lash --color=always'
alias ll='ls -lh'
alias l.='ls -d .*'
alias sl='ls'
alias s='ls'
alias l='ls'
alias lhn='ls | less'
alias lhn='ls | nless'

# find
alias ff='find . -name $*'

# movement
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'
/() { cd /; }

# crud
alias rm='rm -v -I'
alias cp='cp -v -i'
alias mv='mv -v -i'

# latex
alias latexmake="grep -l '\\documentclass' *tex | xargs latexmk -pdf -pvc -silent"

alias less="less -R"
alias nless="less -N"
alias psg="ps ax | grep $*"
alias dirshare='python -m SimpleHTTPServer 8000'
alias gg='git grep'
alias ga='git add'

# clean bash
alias cbash="exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash --norc --noprofile"

alias vim='vim -o'
alias vmi='vim'
alias vin='vim'
alias svmi='vim'
alias svim='vim'
alias vun='vim'
alias duf='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'

alias rpiserial='screen /dev/ttyUSB0 115200'
alias ipy='ipython qtconsole --matplotlib inline --colors=linux'
# }-

# conditional -{
[[ -f /etc/profile.d/bash-completion ]] && source /etc/profile.d/bash-completion
[[ -e `which less 2> /dev/null` ]] && alias more='less'
[[ -e `which vim 2> /dev/null` ]] && alias vi='vim'

[[ -e `which colordiff 2> /dev/null` ]] && alias sdiff='colordiff --side-by-side'

if [ -f /usr/share/mc/mc.gentoo ]; then
  /usr/share/mc/mc.gentoo
fi
# }-

# django -{
alias rs='./manage.py runserver_plus'
alias rspub='./manage.py runserver_plus 0.0.0.0:8000'
alias sp='./manage.py shell_plus'
# }-



# console dvd's -{
function mpd() 
{
  mplayer -dvd-device $1 dvd://1 $2 
}
function xinedvd() 
{
  xine dvd://"`pwd`"
}
alias playdvd='xinedvd'
#alias playdvd='mpd'

# }-
# }-

# Repeat n times command -{
function repeat()
{
  local i max
  max=$1; shift;
  for ((i=1; i <= max ; i++)); do  # --> C-like syntax
    eval "$@";
  done
}
# }-

# Use bash-completion, if available
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi
