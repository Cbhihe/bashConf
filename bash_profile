# ~/.bash_profile

# This file is only sourced by the shell when started in interactive LOGIN 
#+ mode or in non-interactive LOGIN mode with the '--login' option 
#+ activated. This occurs via login at the console (Ctrl+Alt+F1|F2|...|F6) or 
#+ connect via ssh.

# If ~/.bash_profile  does not exist, the shell looks for ~/.bash_login. 
# If ~/.bash_login does not exist, the shell looks for ~/.profile
# If ~/.profile is not there, the shell gives a prompt. In that case, by default,
#+ .bashrc is not read, unless otherwise disposed by the syst admin.

# Prior to 'bash' execution, other files are read by the linux PAM layer:
#+ /etc/pam.d/login
#+ /etc/pam.d/login.defs 
#+ [more files depending on the Lx distro...]
#+ /etc/profile

# "ssh" login is very similar to the above except that initial greeting 
#+ and password authentication will be conducted, not by getty and login via
#+ PAM, but by sshd. In that case the ssh deamon, sshd, reads successively:
#+ /etc/pam.d/ssh
#+ /etc/pam.d/ssh.defs 
#+ [more files depending on linux distro...]
#+ /etc/profile
# The main difference with local console login is some environment variables
#+ may be passed on from the machine-session on which ssh is being run (e.g.
#+ the LANG and LC_* variables). More on https://wiki.debian.org/Locale

# When login occurs via gui:
#+ Normally the shell is NOT A LOGIN SHELL (unless invoked with cmd 'bash -l'. 
#+ As a result ~/.profile will be sourced by the script that launches the 
#+ gnome session (or any other desktop environment). ~/.bash_profile will not 
#+ be sourced at all when gui login occurs.  
# Note: if cmd 'shopt login_shell' returns "off", then shell is no login shell.

# Ensure that .bashrc, config file for interactive instances of bash shells,
#+ gets read even when the shell is a login shell
. "$HOME"/.bashrc	

# PATH environment variables
# 1) Right place to define PATH is usually ~/.profile (or .bash_profile, if you 
#+ don't care for shells other than bash).

# 2) Caution when adding paths in front of PATH. as the order of priority for sourcing 
#+ executables in PATH is from left to right. An attacker could potentially replace
#+ an inocuous looking cmd by something else by doing so.

#PATH=$PATH:$HOME/anaconda2/bin  # AWS CLI setup, also by Anaconda2 4.3.1 installer
PATH=$PATH:/opt/bin:/opt/scripts
PATH=$PATH:$HOME/Documents/Scripts # use $HOME/ instead of ~/ for portability
PATH="$(pathclean)"; export PATH
# `export PATH` is only necesasry in old Bourne shell, not in modern linux shells

# 3) Make sure that systemd is made aware of custom PATHs.
# This does NOT affect services started before .bash_profile is sourced.
systemctl --user import-environment PATH

# Probably already set globally for the system
LANG=en_US.UTF-8; export LANG

# Set local environment variable for locale
# In other locales the ERE [a-d] is typically not equivalent to [abcd]; 
# interpretation of bracket expressions, use the C locale 
#LC_ALL=C; export LC_ALL

# Enforce a POSIX compliant env.
# This may break things (e.g. on Unity desktop)
#POSIXLY_CORRECT=1; export POSIXLY_CORRECT

# Set default text editor to make sure that 'vim' is used with 'visudo'
VISUAL=vim ; export VISUAL
# When set, VISUAL prevails on EDITOR
#set EDITOR=vim; export EDITOR  

# Enable the keyring for applications run through the terminal, such as SSH 
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

#if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then 
#	exec startx 
#fi

# ===========================================================

# Sync Fx cache and profile (located in tmpfs on RAM) at login
#/home/ckb/Scripts/fxram-sync cache
#/home/ckb/Scripts/fxram-sync profile
