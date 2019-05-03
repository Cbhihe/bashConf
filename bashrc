#!/usr/bin/bash

# ~/.bashrc
# Executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# -----------------------------------------------------------------------

# If not running interactively, don't do anything
case $- in
    *i*) GPG_TTY="$( tty )"
        export GPG_TTY ;;
      *) return;;
esac
# $- expands to the current option flags as specified upon shell invocation,  
#    by the set builtin command, or those set by the shell itself (such as 
#	 the -i option).

# sane backend config requirements
SANE_USB_WORKAROUND=1 ; export SANE_USB_WORKAROUND


# ==================================================
## from https://gist.github.com/jan-warchol/sync-history.sh
# ==================================================
MAILPATH="/var/spool/mail/ckb?$_ has email!"
MAILCHECK=60



# Suppress duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# HISTTIMEFORMAT='%F %T'; export HISTTIMEFORMAT

# if "ignoreboth" is commented out, history will record all command lines 
#+ entered after a prompt, including those beginning with a space and 
#+ duplicated CMDs. In that case, it is better to use \# in prompt PS1 
#+ (counts number of shell prompts in sessions), instead of \! (displays 
#+ last entry rank in hist stack +1)

# Append to the history file, don't overwrite it
shopt -s histappend 

# backup of history file at most every 30 minutes
#  test result of `find` = any file modified 30 min before or less at test time
[ -z "$(find "$HISTFILE".backup~ -mmin -30 2>/dev/null)" ] \
	&& /usr/bin/cp -f --backup "$HISTFILE" "$HISTFILE".backup~

# Set history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=300
HISTFILESIZE=300	# 0


# ==================================================
## from https://gist.github.com/jan-warchol/sync-history.sh
# ==================================================
# on every prompt, save new history to dedicated file and recreate full history
# by reading all files, always keeping history from current session on top.
update_history () {
  # append hist lines from this bash session to hist file
  history -a "${HISTFILE}"."$$"
  # clear hist list by deleting all its entries
  history -c
  # read hist file and append its content to hist list
  history -r
  for ff in "${HISTFILE}".[0-9]* ; do
      [ "$ff" == "${HISTFILE}"."$$"\$ ] &&  history -r "$ff"
  done
  history -r "${HISTFILE}"."$$"
}
#if [[  "$PROMPT_COMMAND" != *update_history* ]]; then
#  export PROMPT_COMMAND="update_history; $PROMPT_COMMAND"
#fi

# merge session history into main history file on bash exit
merge_session_history () {
  cat "${HISTFILE}"."$$" >> "$HISTFILE"
  \rm "${HISTFILE}"."$$"
}
trap merge_session_history EXIT

# define history interactive editor (used with 'fc -e')
export FCEDIT='/usr/bin/vim'


# detect leftover files from crashed sessions and merge them back
#active_shells=`pgrep -f "$0"`
active_shells=$(pgrep -w "${0#-}")
grep_pattern=$(for pid in $active_shells; do echo -n "-e \\.${pid}\$ "; done)
orphaned_files=$(ls "$HISTFILE".[0-9]* 2>/dev/null | grep -v "$grep_pattern")

if [ -n "$orphaned_files" ]; then
  echo Merging orphaned history files:
  for f in $orphaned_files; do
      echo "  $(basename "$f")"
    cat "$f" >> "$HISTFILE"
    \rm "$f"
  done
  echo "done."
fi

# split history file if updating history takes more than 0.1 s
split_history_file () {
  echo "Archiving old bash history for better performance..."
  archive_file="$HISTFILE.archive.$(date +%F.%H:%M:%S)"
  split -n "l/2" "$HISTFILE" "$HISTFILE.split_"
  \mv --backup "$HISTFILE.split_aa" "$archive_file"
  \mv --backup "$HISTFILE.split_ab" "$HISTFILE"
  # exclude timestamp comments when summarizing split
  echo -n "$(sed '/^#[0-9]\+$/d' "$archive_file" | wc | awk '{print $1}')"
  echo " entries archived to $(basename "$archive_file")"
  echo "$(sed '/^#[0-9]\+$/d' "$HISTFILE" | wc | awk '{print $1}') entries remaining."
}

#begin=$(date +%s.%N); update_history; end=$(date +%s.%N)
begin=$(date +%s); update_history; end=$(date +%s)
(( $(bc < <(echo "$end" - "$begin")) )) && split_history_file
# Note, above (( expr )) is evaluated according to arithmetic evaluation,
# i.e. assuming fixed width integers are bing evaluated.
# If expr != 0, the exit status is 0. Otherwise it is 1. 
# This is exactly the same as 'let "expr"'

# ============================================

# Check history expansions before running the command
# If disabled, this option can be temporarily replaced by appending :p to 
#+ history expansion, as in:   >!n:p  where n is   history command number
shopt -s histverify   # made redundant by the use of 'magic-space' in ~/.inputrc

# Change to directory immediately if name typed at prompt exist.
shopt -s autocd

# Set local environment variable for locale
# In other locales the ERE [a-d] is typically not equivalent to [abcd]; 
# it might be equivalent to [aBbCcDd], for example. To obtain the i
# traditional interpretation of bracket expressions, use the C locale 
# LC_ALL="C" ; export LC_ALL

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
if [ -f /usr/share/bash-completion/bash_completion ]; then
# shellcheck disable=SC1091
. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
# shellcheck disable=SC1091
. /etc/bash_completion
fi
fi

# set env-variable to ease he use of bash cmd-line calculator 'bc'
# BC_ENV_ARGS=~/.bc; export BC_ENV_ARGS

# Set standard default text editor 
VISUAL=/usr/bin/vim; export VISUAL # ensures 'nano' not used with 'visudo'
# -> ensures 'vim' is used for 'sudoedit FILENAME' or 'sudo -e FILENAME'
# so no arbitrary shell command may run from the editor with sudo privs.
SUDO_EDITOR=/usr/bin/vim; export SUDO_EDITOR 
SYSTEMD_EDITOR=/usr/bin/vim; export SYSTEMD_EDITOR 


# Check window size after each command and, if necessary, update the values 
# of LINES and COLUMNS. (redundant if /etc/bash.bashrc is correctly called 
# for interactive terminals)
#shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# Make 'less' more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color) color_prompt=yes;;
esac

# Comment for a non colored prompt, when the terminal has the capability
# That option is turned off by default to not distract the user.
# The focus in a terminal window should be on the output of commands, not
# on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# We have color support; assume it's compliant with Ecma-48
# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# a case would tend to support setf rather than setaf.)
color_prompt=yes
else
color_prompt=
fi
fi

parse_git_branch() {
git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# git config --global --add color.ui true
GIT_PS1_SHOWDIRTYSTATE="enable"
GIT_PS1_SHOWSTASHSTATE="enable"

# Set variable identifying the chroot you work in (used in prompt below for Debian envt)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# #### [ckb 20171203, 20180922] replaced PS1
if [ "$color_prompt" = yes ]; then

# For Debian based systems only
#export PS1='${debian_chroot:+($debian_chroot)}[\#]\[\e[01;34m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]$'
# Improved with:
#PS1="${debian_chroot:+($debian_chroot)}\[\e[0;38;5;166m\][\#/\!]\[\e[1;34m\] \w\[\e[38;5;46m\] \$(parse_git_branch)\[\e[1;38;5;166m\]>\[\e[0m\]"

# For Archlinux
PS1="\\[\\e[0;38;5;166m\\][\\#/\\!]\\[\\e[1;34m\\] \\w\\[\\e[38;5;46m\\] \$(parse_git_branch)\\[\\e[1;38;5;166m\\]\\> \\[\\e[0m\\]"

else
# For Debian based systems only
#export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#export PS1="${debian_chroot:+}[\#/\!] \[\w \$(parse_git_branch)\]>"
# For Archlinux
PS1="[\\#/\\!] \\[\\w \$(parse_git_branch)\\]>"
fi
export PS1

unset color_prompt force_color_prompt

# If this is an xterm set the tile to 'tty tty_number::username@hostname::dir'
case "$TERM" in
xterm*|rxvt*)
    # For Debian based systems only
    #PS1="\[\e]0;tty $(tty|awk '{print substr($1,10)}') :: [${debian_chroot:+($debian_chroot)}] \u@\h \w\a\]$PS1"
    #export PS1 ;;
    # For Archlinux
    PS1="\\[\\e]0;tty $(tty|awk '{print substr($1,10)}') :: \\u@\\h \\w\\a\\]$PS1"
    export PS1
    ;;
*)
    ;;
esac

## Alias definitions:
# Put all alias definitions in ~/.bash_aliases
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#shellcheck disable=SC1090
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# load key bindings
xbindkeys

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? -eq 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\''\)"'

# PATH manipulations are in ~/.profile (unused) and in ~/.bash_profile 
#+ (for interactive login shells). See https://unix.stackexchange.com/a/26059/674

# Notes on PATH environment variables
# 1) Right place to define PATH is usually ~/.profile (or .bash_profile, if you 
#+   don't care for shells other than bash).

# 2) Caution when adding paths in front of PATH. as the order of priority for sourcing 
#+ executables in PATH is from left to right. An attacker could potentially replace
#+ an inocuous looking cmd by something else by doing so.

#PATH=$PATH:$HOME/anaconda2/bin  # AWS CLI setup, also by Anaconda2 4.3.1 installer
PATH=$PATH:/opt/bin:/opt/scripts
PATH=$PATH:$HOME/Documents/Scripts # use $HOME/ instead of ~/ for portability

# 3) Make sure that systemd is made aware of custom PATHs.
# This does NOT affect services started before .bash_profile is sourced.
systemctl --user import-environment PATH

# 4) Configure ~/.bashrc for Hadoop
# Set Hadoop-related environment variables
export HADOOP_HOME=/opt/hadoop

# Set JAVA_HOME (we will also configure it later on Hadoop)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk

# Add Hadoop bin/ directory to PATH
export PATH=$PATH:$HADOOP_HOME/bin

# 5) Configure ~/.bashrc for spark
export SPARK_HOME=/home/ckb/spark/spark
export PATH=$PATH:$SPARK_HOME/bin

# 6) Configure PYTHON environment
if [ -n "$PYTHONPATH" ]; then
    PYTHONPATH="${HOME}/Documents/Work/Academic-research/Eric21:${HOME}/Documents/Work/Academic-research/visualCity:${PYTHONPATH}"
else
    PYTHONPATH="${HOME}/Documents/Work/Academic-research/Eric21:${HOME}/Documents/Work/Academic-research/visualCity"
fi

# 7) Configure PYTHON virtual environment
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export WORKON_HOME=~/.virtualenvs
mkdir -p "$WORKON_HOME"
#export PROJECT_HOME="${HOME}/Documents/Work/Academic-research"
export PROJECT_HOME="/home/ckb/Documents/Work/Academic-research"
# Make sure `eval "$(pyenv init -)"` is placed at end of ~/.bashrc 
#+ since it manipulates PATH
if [ -n "$(command -v pyenv)" ]; then eval "$(pyenv init -)"; fi
pyenv global "$(python --version | cut -d" " -f2)"
# ensure access to 'virtualenvwrapper' runtime namespace
pyenv virtualenvwrapper
# load 'virtualenvwrapper' plugin shell functions only
#+ when using them for the first time
source /usr/bin/virtualenvwrapper_lazy.sh

# 8)  Clean up "paths" env_var
PATH=$(pathclean PATH "$PATH"); export PATH
# `export PATH` is only necessary in old Bourne shell, not in modern linux shells
PYTHONPATH=$(pathclean PYTHONPATH "${PYTHONPATH}"); export PYTHONPATH



# Set shells to use `torsocks` prefix as default for any cmd. 
#source torsocks on
# To disable `torsocks` for current shell
#source torsocks off

# Node Version Manager - Simple bash script to manage multiple active node.js
# versions
source /usr/share/nvm/init-nvm.sh