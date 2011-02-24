# BASHrc
# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker foldmarker=-{,}- fml=1:

if [[ $- != *i* ]] ; then
  # Shell is non-interactive.  Be done now!
  return
fi

export LANG="en_US.utf-8"
export LC_ALL="en_US.utf-8"

export EDITOR="vim"
export PATH=$PATH:$HOME/bin
export HISTSIZE=100000

cd $HOME
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

if [ $HOST != "psyche" ]; then
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
  if [[ $PWD == $HOME* ]]; then
    branch=""
    if [ $PWD = $HOME ]; then
      branch=$dirty
    fi
  fi
  # }-

  xtitle `whoami`@`uname -n`:$PWD 

  host="${HC}@${HD}${NIL}"

  if [ "$USER" = "root" ]; then
    user="${RED}\u${NIL}"
    end_char="#"
  else 
    user="${UC}\u${NIL}"
    end_char="$"
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
      export PS1="${venv}${branch}${user}${at}${host} ${path} ${end}" ;;
    long )
      export PS1="\n${venv}${branch}${user}${at}${host} ${PWD} \n${end}" ;;
  esac
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

# python virtuals, PIP -{
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
  export WORKON_HOME=$HOME/envs/
  case $HOST in
    psyche ) export WORKON_HOME=/data/envs/ ;;
  esac
  
  source /usr/bin/virtualenvwrapper.sh

  export PIP_VIRTUALENV_BASE=$WORKON_HOME
  export PIP_RESPECT_VIRTUALENV=true
  export PIP_DOWNLOAD_CACHE='/tmp/pip_cache'
fi
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

# find
alias ff='find . -name $*'

# movement
alias .='pwd'
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


alias psg="ps ax | grep $*"
alias dirshare='python -m SimpleHTTPServer 8080'
# }-

# conditional -{
[[ -f /etc/profile.d/bash-completion ]] && source /etc/profile.d/bash-completion
[[ -e `which less` ]] && alias more='less'
[[ -e `which vim` ]] && alias vi='vim'

if [ -f /usr/share/mc/mc.gentoo ]; then
  /usr/share/mc/mc.gentoo
fi
# }-

# my bin aliases -{
alias sms='$HOME/sms/sms'
# }-

# django -{
alias rs='./manage.py runserver_plus'
alias rspub='./manage.py runserver_plus 0.0.0.0:8000'
alias sp='./manage.py shell_plus'
# }-

# xtitle aliases -{
alias top='xtitle TOP && top'
alias mplayer='xtitle Mplayer && mplayer'
alias radio='xtitle Radio && playradio'

function man()
{
  for i ; do
    xtitle "man: '$(basename $1|tr -d .[:digit:])'"
    command man "$i"
  done
}

function vim()
{
  for i ; do
    xtitle "Vim: $(basename \"$1\")"
    command vim "$i"
  done
}
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

# lstodo -{
alias lstodo=todolist

function todolist()
{
  C_Y=`echo -e '\033[33;01m'`
  C_Re=`echo -e '\033[31;01m'`
  C_G=`echo -e '\033[32;01m'`
  C_B=`echo -e '\033[34;01m'`
  C_R=`echo -e '\033[m'`

  grep -Ri todo . | sed "s/[ ]\{1,\}/ /g" |
  sed "s/{#\(.*\)#}/\1/g" |
  sed "s/ *[#\.]* *TODO *//g" |
  sed "s/\((minor)\):*/${C_Y}\1${C_R}:/g"    |
  sed "s/\((normal)\):*/${C_G}\1${C_R}:/g"   |
  sed "s/\((major)\):*/${C_Re}\1${C_R}:/g"   |
  sed "s/\((docs)\):*/${C_B}\1${C_R}:/g"     |
  sed "s/^\.\///g"   |
  sed "s/:[^0:]*:/:${C_B}${C_R}:/" |
  awk -F: '{ printf "%-45s %-20s", $1, $2; for (i=3; i<=NF; i++) printf "%s", $i; printf "\n"  }'
}
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

# xtitle -{
function xtitle() {
  case "$TERM" in
    xterm | rxvt | urxvt)
      echo -ne "\033]0; $* \007"
      ;;
    *)
      ;;
  esac

}

# }-

# NVIDIA -{
function _nv_set_perf() {
  overclocking=`nvidia-settings -t -q GPUOverclockingState`
  if [ ! $overclocking = 1 ]; then
    nvidia-settings --assign='GPUOverclockingState=1' > /dev/null
  fi
  freq=`nvidia-settings -t -q GPU3DClockFreqs`
  if [ ! $freq = "$1,$2" ]; then
    nvidia-settings --assign="GPU3DClockFreqs=$1,$2" > /dev/null
  fi
}

alias nv_set_low='_nv_set_perf 150 100'
alias nv_set_med='_nv_set_perf 300 200'
alias nv_set_high='_nv_set_perf 600 400'

# }-

export GAIA_DIR=/data/work/gaia
export SOFCOMMON=${GAIA_DIR}/sw/common
export CU7COMMON=${GAIA_DIR}/sw/cu7common
export ANT_HOME=${SOFCOMMON}/apache-ant-1.7.0

source ~/.gaia

# Use bash-completion, if available
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# load system specific
if [ -f ~/.bash_local ]; then
  . ~/.bash_local
fi

#clear
