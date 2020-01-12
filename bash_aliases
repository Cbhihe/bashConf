#!/usr/bin/bash

# ~/.bash_aliases: executed by .bashrc for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# select a default dictionnary for basic system based spell-checking
#alias default-wordlist='sudo select-default-wordlist'
		
# shortcut to reload .bashrc and .bash_aliases after editing aliases
alias aliases='vim "$HOME"/.bash_aliases; source "$HOME"/.bash_aliases'

alias crontab="crontab -i"
alias lsblk='lsblk -o +UUID'

#alias history='\history 50'
alias hist='\history 25'
alias his='\history 15'
alias hi='\history 10'
alias h='\history 5'


# test for color db for ls and define env-var LS_COLORS
if [ -x /usr/bin/dircolors ]; then

    if [ -r ~/.dircolors ] ; then
		eval "$(dircolors -b ~/.dircolors)"
    else 
		eval "$(dircolors -b)"
		# tweak default ls colors as seen output from '> dircolors -p'
		LS_COLORS="${LS_COLORS}:tw=31;43:ow=01;37;43"
		export LS_COLORS
    fi

    alias less='\less -R'  # recognized ANSI color codes as input to be interpreted by terminal
	alias ls='\ls -F --color=auto'	# option -F to classify with */=>@|
	#alias ls='\ls -F --color=always | \less -r'	# option -F to classify with */=>@|
	alias la='\ls -AC --color'			# list "almost all", by column
	alias lsa='\ls -AF --color=auto'
    alias lsi='\ls -1iqF --color=auto'  # list inode numbers and file names
	alias ll='\ls -lsAF --time-style=+%Y%m%d-%H%M%S --color'
										# as before +long formats +size in blocks
	alias lc='\ls -CF --color=auto'		# list entry by column, classify 
#	lld () {\ls -AlF --color=auto $1 | egrep "^d";}	# long list dir only
	alias dir='dir -AF --color=auto'	# equal to '\ls -C -b -AF'
	alias vdir='vdir -AF --color=auto'	# equal to '\ls -l -b -AF'
	cdv () { 
	    # change dir + list target content
		case x"$1" in
			"x" )
				cd || exit ; \ls -AF --color=auto;;
			* )
				cd "$1" || exit ; \ls -AF --color=auto;;
		esac
		} 
	alias grep='grep --color=auto'
	alias sgrep='grep -Hn --color=auto'  # grep with each match's filename and line nbr
	alias fgrep='fgrep --color=auto'
	#alias egrep='egrep --color=auto'    # deprecated
else
	alias ls='\ls -F'		# option -F to classify with */=>@|
	alias la='\ls -A'		# list "almost all"
	alias lsa='\ls -AF'
	alias ll='\ls -lsAF --time-style=+%Y%m%d-%H%M%S'
							# as before +long formats +size in blocks
	alias lc='\ls -CF'		# list entry by column, classify 
	alias dir='dir -AF'		# equal to '\ls -C -b -AF'
	alias vdir='vdir -AF'	# equal to '\ls -l -b -AF'
	cdv () { cd "$1" || exit ; \ls -AF; } # change dir + list target content
fi

#alias less='\less -R'	# maintain screen appearance in presence of ANSI "color" escape sequences 
						#+ of type 'ESC [ ... m`  where ... are zero or more color spec characters.
alias cdl='cd -L'		# follow symbolic links
alias cdp='cd -P'		# use physical directory structure,
						#+ don't follow symbolic links

alias j='jobs -l'		# option -l shows PID
## below 'cat' alias conflicts with 'pyenvvirtualenvwrapper' script and 'workon' cmd.
#  [ckb]   Thu 18 Apr 2019 20:21:52 CEST
#alias cat='cat -n'		# option -n  numbers all output lines
alias ps='\ps -eF --headers | less'
alias pstopcpu='\ps -auxf | sort -nr -k 4 | head -10'
alias c='clear'
alias cl='clear'
alias claer='clear; echo "$(uname) assumed that command \clear\ was meant."'
alias bc='bc -lq' 	# invokes built-in Unix calculator with standard math 
alias calc='bc -lq'	#+ library in quiet mode.

# list ps while avoiding matching the 'grep' command line itself
sps() { \\ps aux | grep "$@" | grep -v 'grep'; }

# overload 'man' -- allow info on builtins in pseudo man-page format
# Author: Radu Rädeanu in AU's question 439410
function man () {
    case "$(type -t -- "$1")" in
    builtin|keyword)
        help -m "$1" | sensible-pager
        ;;
    *)
        command man "$@"
        ;;
    esac
}

# Overload `umount' -- allow unmounting in any situation
# Only one parameter (mount point or device path) is allowed
# Include special cases of 'root' user or lone option parameter
function umount () {
	if [ "$(id -un)" == "root" ] || 
       [ $# -ne 1 ] ||  
       [ "${1:0:1}" == "-" ]; then
		command umount "$@"
	else
		/usr/bin/gvfs-mount -u "$1"
	fi
}

# Disable touchpad for given number of seconds
function padoff () {
	if [ ! $# -eq 1 ] ; then
		printf "Exactly one numeric argument (time in seconds) required.\\n"
		printf "Abort.\\n"
	else
		# strip all digits to test whether numeric
		isnbr="$(sed 's/[0-9]*//g' < <(echo "$1"))"
		if  [ -n "$isnbr" ]; then
			# if not zero length after stripping all digits
			printf "Argument must be numeric (time in seconds).\\n"
			printf "Abort.\\n"
		else
			ID_touchpad="$(cut -f1 < <(awk -F "=" '/Touchpad/ {print $2}' \
				< <(/usr/bin/xinput list)))"
			(/usr/bin/xinput --disable "${ID_touchpad}" ; 
			printf "Touchpad disabled for the next %d seconds\\n" "$1";
			sleep "$1";
			/usr/bin/xinput --enable "${ID_touchpad}") &
		fi
	fi
}

# Enable pad
function padon () {
	ID_touchpad="$(cut -f1 < <(awk -F "=" '/Touchpad/ {print $2}' \
		< <(/usr/bin/xinput list)))"
	/usr/bin/xinput --enable "${ID_touchpad}"
	printf "Touchpad enabled.\\n"
}

# Display members of a group, where "group" is  provided as argument $1
function groupmember () { 
    awk -F":" '{print $1, ": ", $4}' < <(grep -e "^${1}:.*" /etc/group) 
}
alias grpmbr='groupmember'

# alias below aplies to erl v16.b3
# alias erlg='erl -s toolbar' # start erlang with toolbar GUI applet

function nicMacAddress () { 
    awk '{print $2,$(NF-2)}' <(ip -o link) 
}
alias nicmac='nicMacAddress'

alias battery='watch -n0 cat /sys/class/power_supply/BAT0/capacity'
                # display battery charge info in real time
alias swinfo='lsb_release -cd; printf "%s\t\t%s\n" "Kernel:" "$(uname -rsi)"' 
				                        # prints distro specific info
alias portinfo='netstat -tulanp'        # quickly list all TCP/UDP ports on $HOST
				# -t for "tcp" port
				# -u for "udp" port
				# -l for "listening" port
				# -a for "all"
				# -n for "numeric"
				# -p for "program"
alias cpuinfo='lscpu'			        # all info about the CPU
alias ipinfo1='wget http://ipinfo.io/ip -qO -'
alias ipinfo2='curl -s checkip.dyndns.org | sed -e "s/.*Current IP Address: //" -e "s/<.*$//"'
alias ipinfo3='curl -s ifconfig.co'     # displays plain unproxied ip

alias hwinfo='sudo dmidecode -q > ~/Documents/Backups/hw-profile.txt; printf "%s\n" "Hardware profile in file: ~/Documents/Backups/hw-profile.txt"'
alias bioinfo='sudo dmidecode --type 0'  # requires sudo passwd
alias meminfo='sudo dmidecode --type 17' # requires sudo passwd
alias gpuinfo='lspci -k | grep -EA2 "VGA|3D"'

# send 'dmesg' content to pastebin
alias bindmesg='dmesg | curl -F "f:1=<-" ix.io' 

# send 'journalctl -b' content to pastebin
alias binbootjournal='sudo /usr/bin/journalctl -b | /usr/bin/curl -F '\''f:1=<-'\'' ix.io'

function finduserspace () {
    # print disk space usage for non-root users
    awk -F: '/bash/ && /home/ {print "/home/"$1}' /etc/passwd | xargs -l sudo du -sm
}
alias userspace='finduserspace'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? -eq 0 ] && echo terminal || echo error)" "$(history|tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\''\)"'


## Swappiness tweaking
# Default value of swappiness=60 means kernel starts swapping when RAM use
#+ hits 40% of available RAM capacity
## current session swappiness 
alias swapinfo='printf "%s" "Current session swappiness is "; \cat /proc/sys/vm/swappiness' 
# set swappiness for session
#alias setswap='printf "%s" "Current session swappiness set to: "; sudo ...=$1' 

## Date
alias datestamp='/bin/date +%Y%m%d' # format yyyymmdd
alias timestamp='/bin/date +%H%M%S' # format hhmmss
alias lastmod='/opt/bin/lastmod.sh' # last modif stamp by '$USER' (w/ CR)
alias partmod='/opt/bin/partmod.sh' # partial modif stamp by '$USER' (w/o CR)
alias scripthead='/opt/bin/scripthead.sh' 
                                    # script creation stamp

## Screenshot
alias sshoot='/opt/scripts/screen-capture'
                                    # access to gnome-screenshot script 
                                    # with custom save folder 

## vim
alias svi='sudo -e'
alias svim='sudo -e'
alias edit='vim'
alias vimsi='vim "+set si"'         # vim with 'smartindent' option enabled 
						            # Similarly 'set ai', (autoindent) offers a less
						            # sophisticated alternative to 'indentexpr' but
						            # works in case the file type being edited remains
						            # unrecognized

## Safety nets
set -o noclobber                    # disallow clobbering file with output redirection '>'
alias ln='ln -i'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i --preserve-root'    # with -I flag, only asks when removing 
                                    # 3 or more files
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'	# change group

alias df='df -kP'                   # check available space on volume of 
                                    # named directory by default check all 
                                    # mounted volumes

# alias cpprogress='rsync --progress -ravz' 
                                    # cp with progress bar ??
# alias asuf='cp "$1" "$1""$2"'     # needs work

## Network
alias ping='\ping -c 5'

# find available wlan networks in vicinity
alias wifiscan='sudo /usr/bin/iw wifi0 scan | grep SSID'
alias scanwifi='sudo /usr/bin/wpa_cli -i wifi0 scan_results'

function whereisip() {
    # finds where an IP's exit node is located
    [ $# != 1 ] && printf "\nPlease provide exactly one IP address as argument.\n\n" && return
    curl ipinfo.io/"$1"
    printf "\n"
}

# finds where my own external IP's exit node is located
alias myip='curl ipinfo.io/"$(curl -s icanhazip.com)";printf "\n"'

function expandurl() {
    # expands shortened url
    [ $# != 1 ] && printf "\nPlease provide exactly one URL as argument.\n\n" && return
    curl -sIL "$1" | grep ^Location
}

function iswebup() {
    # details whether given web site is up and running
    [ $# != 1 ] && printf "\nPlease provide exactly one web site as argument.\n\n" && return
    curl --head -s "$1" -L | grep HTTP/
}

## System
alias halt='sudo halt'              # halt processes and machine with no 
alias reboot='sudo /sbin/shutdown -r'
                                    # arg is either "now" or an integer 
					                # value in minutes; same as 'sudo reboot'
alias shutdown='sudo /sbin/shutdown -h'
                                    # arg as above
alias nocomment='grep -Ev '\''(#|$)'\'''
                                    # filter out comments in a grepped file

## Gadgets
function weather() {
    # prints weather forecast in plain text on screen
    [ $# != 1 ] && printf "\nPlease provide exactly one city name as argument.\n\n" && return
    curl wttr.in/"$1"
}

# =====================================================================
# PACKAGE OR ENVIRONMENT SPECIFIC SHORTCUTS AND FUNCTIONS
#

# =============================
# VENV
alias vpython='python -m venv --system-site-packages --prompt VENV'
#alias vpython='python -m venv --without-pip --system-site-packages --prompt VENV'

# =============================
# TMUX
alias gtmux='~/.tmux/gnome-term-session.sh'

# =============================
# GITHUB
# staging function
function gitsta() {
    case $1 in
	    -[aA]|-[aA][lL][lL]) 
            git add -u
            git add -- *
            ;;
        *)
	        git add "$@"
            ;;
    esac
}

# commit function
function gitcom() {
    # "$*" makes all arguments to one
    git commit -m  "$*"
}

alias gitlog='git log --pretty=format:"%h: %an-%cn %cr: %s" --graph'

# =============================
# TRIPWIRE
alias twcfgbld='path="/mnt/TW_db-bin"; sudo twadmin -m F -c ${path}/tw.cfg -S ${path}/site.key ${path}/twcfg.txt'  # build and sign tw.cfg info coreutils 'groups invocation'
alias twpolbld='path="/mnt/TW_db-bin"; sudo twadmin -m P -c ${path}/tw.cfg -p ${path}/tw.pol -S ${path}/site.key ${path}/twpol.txt'  # build and sign tw.pol
alias twdbbld='path="/mnt/TW_db-bin"; sudo ${path}/tripwire -m i -c /tw.cfg -p ${path}/mnt/TW_db-bin/tw.pol -S ${path}/site.key -L ${path}/${HOSTNAME}-local.key -d ${path}/${HOSTNAME}.twd'  # initiate db w/ new tw.cfg and/or tw.pol files
alias twiic='nowdir=$PWD; path="/mnt/TW_db-bin"; cd "${path}"; sudo tripwire -m c -c ${path}/tw.cfg -I; cd $nowdir'
# alias twdbupd='nowdir=$(pwd);cd /mnt/TW_db-bin/report; lastrpt=$(/bin/ls -1 *.twr | /usr/bin/tail -1); sudo tripwire -m u -a -c /mnt/TW_db-bin/tw.cfg -p /mnt/TW_db-bin/tw.pol -S /mnt/TW_db-bin/site.key -L /mnt/TW_db-bin/${HOSTNAME}-local.key -d /mnt/TW_db-bin/${HOSTNAME}.twd -r ${lastrpt}; cd $nowdir'  # automatic update db 

# =============================
# AWS 
sshaws() { 
	printf "Connect to AWS instance %s@%s" "$1,$2\\n"
	ssh -i "$3" "$1"@"$2"
    # For UPC/FIB/MIRI/DS projecti use:
    #   $1: "ubuntu"
    #   $2: internet domain
    #   $3: "~/Documents/Academic/UPC/MIRI/Subjetcs/DS_decentralized-systems/Project/upcfib_ds.pem"
}
#
# CLI ENVIRONMENT VARIABLES
# test for the existence of ~/.aws/{config,credentials} filesi, before
# export of AWS env variables
if [ -f "$HOME"/.aws/credentials ]; then
	parsefile="$HOME"/.aws/credentials
	AWS_ACCESS_KEY_ID=$(awk '/aws_access_key_id/ {print $3}' "$parsefile")
	export AWS_ACCESS_KEY_ID
	AWS_SECRET_ACCESS_KEY=$(awk '/aws_secret_access_key/ {print $3}' "$parsefile")
	export AWS_SECRET_ACCESS_KEY
fi
if [ -f "$HOME"/.aws/config ]; then
	parsefile="$HOME"/.aws/config
	AWS_DEFAULT_REGION=$(awk '/region/ {print $3}' "$parsefile")
	export AWS_DEFAULT_REGION
fi
#
# set up cmd completion for AWS CLI
complete -C '/home/ckb/anaconda2/bin/aws_completer' aws 

#
# =============================
# ARCH LINUX

alias aurvote='ssh aur@aur.archlinux.org vote'
alias ifplugd='sudo systemctl start netctl-ifplugd@net0'
alias upcvpn='sudo /usr/bin/openvpn --config /etc/openvpn/vpn.upc.edu.ovpn'
alias basetisvpn='sudo /usr/bin/openvpn --config /etc/openvpn/vpn.basetis.com.ovpn'
alias kubikvpn='sudo /usr/bin/openvpn --config /etc/openvpn/vpn.kubikdata.com.ovpn'
alias upcssh='ssh bhihe@arvei.ac.upc.edu' # passwd: [usual_upc]
alias paccacheclean='paccache -rk2'  # add '-u' to remove only uninstalled packages
alias pacorphanclean='sudo pacman -Rns $(pacman -Qtdq)' # orphans' + conf files' recursive removal  


#
# =============================
# PYTHON
alias pythonpath='python -c "import sys; print('\''\n'\''.join(sys.path))"'

# 
# =============================
# DEBIAN-BASED LINUX

# alias setswap='printf "%s" "Current session swappiness set to: "; sudo sysctl vm.swappiness=$1' 

# apt-get shortcuts
#alias sac='sudo apt-cache'           # shortcut followed by 'show','showpkg'
                                     # 'search','pkgnames',  
#alias sacs='sudo apt-cache stats'    # shows overall statistics of cache
#alias sacd='sudo apt-cache depends'  # shows dependencies
#alias sacr='sudo apt-cache rdepends' # shows reverse dependencies 
#alias sacp='sudo apt-cache policy'   # prints out priorities of each source
                                     #+ (no arg) || prints out info on 
                                     #+ priority selection of named package.
#alias sag='sudo apt-get'
#alias sagu='sudo apt-get update'
#alias sagy='sudo apt-get --yes'
#alias suuc='sudo apt-get update; sudo apt-get dist-upgrade; sudo apt-get \
#	upgrade; sudo apt-get clean; sudo apt-get autoremove'
#alias sagc='sudo apt-get check'      # diagnoses broken dependencies
#alias saga='sudo apt-get autoclean'  # deletes all .deb files from 
                                     # /var/cache/apt/archives to free MB.
#alias sagr='sudo apt-get autoremove' # removes package with all dependencies 
                                     # provided they aren't used anymore
#alias saar='sudo add-apt repository' # adds repo

#alias hwinfo='sudo lshw -html -numeric -sanitize >/Backups/hw-profile.html; \
#    printf "%s\n" "Sanitized hardware profile in html file:///Backups/hw-profile.html"'


## Display all manually installed packages since last fresh install
## Modified from http://askubuntu.com -- question 2389
#function mipinfo1 () {
#	datestp="$(/bin/date +\%Y\%m\%d-\%H\%M\%S)"
#    ofile="/Backups/mpi1_$datestp"
#    printf "%s\n" "-- Results kept in $ofile"
#    printf "%s\n" "======  Manually installed packages  ======" > "$ofile"
#    printf "%s\n\n" "as of $datestp" > "$ofile"
#    comm -23 <(apt-mark showmanual | sort -u) \
#		<(gzip -dc /var/log/installer/initial-status.gz \
#		| sed -n 's/^Package: //p' | sort -u) \
#		>> "$ofile" 
#}
#alias mpi1="mipinfo1"

## Diplay all manually installed packages since last fresh install
## Modified from http://serverfault.com -- question 175504
#function mipinfo2 () 
#{    
#	datestp="$(/bin/date +\%Y\%m\%d-\%H\%M\%S)"
#    ofile="/Backups/mpi2_$datestp"
#    printf "%s\n" "-- Results kept in $ofile"
#    printf "%s\n" "======  Manually installed packages  ======" > "$ofile"
#    printf "%s\n\n" "as of $datestp" > "$ofile"
#    comm -23 <(dpkg --get-selections | sed -n 's/\t\+install$//p' | sort) \
#         <(</var/lib/apt/extended_states \
#           awk -v RS= '/\nAuto-Installed: *1/ {printi $2}' |sort) >> "$ofile"
#}
#alias mpi2="mipinfo2"

## UPC VPN connect / status / kill
#alias upcvpn='/usr/local/pulse/PulseClient.sh -h vpn.upc.edu -u sedric.bhihe -r Estudiants -U https://vpn.upc.edu'
#alias upcvpnstat='/usr/local/pulse/PulseClient.sh -S'
#alias upcvpnkill='/usr/local/pulse/PulseClient.sh -K'
