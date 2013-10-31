###############
## Oh-my-zsh ##
###############
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
DEFAULT_USER=$USER

# oh-my-zsh plugins (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(vim git jump hub ssh brew git-extras github last-working-dir node npm osx pip python screen sublime zsh-syntax-highlighting)

################
## Completion ##
################
# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
 COMPLETION_WAITING_DOTS="true"

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

# Homebrew tab-completion
# https://github.com/mxcl/homebrew/wiki/Tips-N'-Tricks#command-tab-completion
if [[ ! -d $HOME/.zsh/func ]]; then
    mkdir -p $HOME/.zsh/func
    if [[ ! -f $HOME/.zsh/func/_brew ]]; then
        ln -s "$(brew --prefix)/Library/Contributions/brew_zsh_completion.zsh" ~/.zsh/func/_brew
    fi
fi

fpath=($HOME/.zsh/func $fpath)
typeset -U fpath

# initialize completions
autoload -Uz compinit
compinit

# show completion menu when number of options is at least 2
zstyle ':completion:*' menu select=2

#############
## Aliases ##
#############
alias c='clear'
alias ls='ls -aFhG'
alias homesick="$HOME/.homesick/repos/homeshick/home/.homeshick"
alias zshconfig="subl ~/.zshrc"
alias ohmyzsh="subl ~/.oh-my-zsh"

###########################
## Environment Variables ##
###########################
# Sublime Text
export EDITOR="subl -w"
#Add Node path
export NODE_PATH="/usr/local/lib/node"

##########
## Path ##
##########
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/X11/bin/usr/local/heroku/bin
export PATH=/usr/local/share/python:$PATH
### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

############
## Python ##
############
# Sets up virtualenvwrapper and virtualenv.
# For more info check: http://virtualenvwrapper.readthedocs.org/en/latest/
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2.7
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
if [[ -r /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
else
    echo "WARNING: Can't find virtualenvwrapper.sh"
fi

if [[ ! -d $WORKON_HOME ]]; then
    mkdir -p $WORKON_HOME
fi

alias workoff='deactivate'

#########
## Hub ##
#########
#Hub is a github wrapper https://github.com/defunkt/hub
eval "$(hub alias -s)"


##################
## Control Flow ##
##################
# make ctrl-s and ctrl-q send those commands instead of sending "control flow" information
# this is useful for getting screen and other command line utilities to work properly.
stty -ixoff
stty stop undef
stty start undef

##############################
## SSH Key to remote server ##
##############################
ssh-copy () {
  ID_FILE="${HOME}/.ssh/id_rsa.pub"

  if [ -z "$1" ] # if there are no arguments passed, throw this error. THIS DOESN'T WORK RIGHT NOW!
    then
      echo "Which server? Try ' ssh-copy user@server.domain'"
  fi

  if [ "-i" = "$1" ]; then
    shift
    # check if we have 2 parameters left, if so the first is the new ID file
    if [ -n "$2" ]; then
      if expr "$1" : ".*\.pub" > /dev/null ; then
        ID_FILE="$1"
      else
        ID_FILE="$1.pub"
      fi
      shift         # and this should leave $1 as the target name
    fi
  else
    if [ x$SSH_AUTH_SOCK != x ] && ssh-add -L >/dev/null 2>&1; then
      GET_ID="$GET_ID ssh-add -L"
    fi
  fi

  if [ -z "`eval $GET_ID`" ] && [ -r "${ID_FILE}" ] ; then
    GET_ID="cat ${ID_FILE}"
  fi

  if [ -z "`eval $GET_ID`" ]; then
    echo "$0: ERROR: No identities found" >&2
    exit 1
  fi

  if [ "$#" -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [-i [identity_file]] [user@]machine" >&2
    exit 1
  fi

  { eval "$GET_ID" ; } | ssh ${1%:} "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys" || exit 1

  echo "Now try logging into the machine, with 'ssh ${1%:}', and check in:

    .ssh/authorized_keys

  to make sure we haven't added extra keys that you weren't expecting."
}

###########
## Marks ##
###########
#Easy marking of directories for quick navigation from the command line
#from http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
# use "mark foo" to mark and name a directory
# use "jump foo" to jump to that named directory from anywhere
# use "marks" to see all marks
# use "unmark foo" to remove a mark.

export MARKPATH=$HOME/.marks
function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark {
    rm -i "$MARKPATH/$1"
}
function marks {
    \ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}
## mark tab completion:
function _completemarks {
  reply=($(ls $MARKPATH))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark


###################
## Miscellaneous ##
###################

# Globbing
setopt extended_glob

##################
## Private Info ##
##################

# Bring in private info
PRIVATEFILE=~/.private_zsh
if [ -f $PRIVATEFILE ]; then
    source $PRIVATEFILE
else
  echo "No private file found"
fi


############
## Prompt ##
############
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR='⮀'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  #local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

#######################
## Prompt Components ##
#######################
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$user@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi
    echo -n "${ref/refs\/heads\//⭠ }$dirty"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue black '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
RPROMPT='%t !%!'