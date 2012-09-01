#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# .bashrc
# Copyright 2009 - 2011 Stephen Niedzielski. Licensed under GPLv3+.

# ------------------------------------------------------------------------------
# Interactive Shell Check
[[ "$-" == *i* ]] || return

# ------------------------------------------------------------------------------
# History

# Don't record adjacent duplicate commands or command lines starting with a
# space.
HISTCONTROL=ignoredups:ignorespace

# Set max commands and lines in Bash history.
HISTSIZE=50000
HISTFILESIZE=50000

# Timestamp entries.
HISTTIMEFORMAT='%F-%H-%M-%S '

# Preserve multi-line commands in one history entry.
shopt -s cmdhist

# Append to the history file, don't overwrite it.
shopt -s histappend

# Don't replace newlines with semicolons in multi-line commands.
shopt -s lithist

# ------------------------------------------------------------------------------
# Globbing

# Enabled extended globbing.
shopt -s extglob

# Enable recursive globbing using **.
shopt -s globstar

# Ignore case.
shopt -s nocaseglob

# ------------------------------------------------------------------------------
# Completion

# Don't attempt to complete empty command lines otherwise it'll hang the prompt
# for a bit.
shopt -s no_empty_cmd_completion

# Attempt to correct directory names when completing.
#  These don't seem to correct prior to passing to prog.
# shopt -s dirspell

# Source default Bash completions.
[[ -f /etc/bash_completion ]] && . /etc/bash_completion

# ------------------------------------------------------------------------------
# Miscellaneous Options

# Don't overwrite an existing file when using redirection.
set -C

# The return value of a pipeline is that of the rightmost command to exit with a
# non-zero status, or zero if all commands exit successfully.
set -o pipefail

# Use VI style command line editing.
set -o vi

# Check for active jobs before exiting.
shopt -s checkjobs

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# ------------------------------------------------------------------------------
log() { echo "$@"|tee -a ${log_file:+"$log_file"}; }
log-ok()   {   printf '\033[22;32m'; log "$@"; printf '\033[00m';        } # Green
log-warn() { { printf '\033[22;33m'; log "$@"; printf '\033[00m'; } >&2; } # Yellow
log-ng()   { { printf '\033[22;31m'; log "$@"; printf '\033[00m'; } >&2; } # Red

# ------------------------------------------------------------------------------
# Prompt and Window Title

# HACK: Bash won't read updates to PS1 made in readline.
#force_update_term_title() { echo -en "\033]0;$USER@${debian_chroot:-$HOSTNAME}:$PWD\007"; }
# TODO: consider the following for strapping into a CD hook: http://stackoverflow.com/questions/3276247/is-there-a-hook-in-bash-to-find-out-when-the-cwd-changes
PS1='\[\e]0;\u@${debian_chroot:-\h}:\w\a\]'

# "$ " colored green for zero exit status, red otherwise.
PS1+='$( [[ $? -eq 0 ]] && echo "\[\033[22;32m\]" || echo "\[\033[22;31m\]" )'

# Colorless.
PS1+='\$ \[\033[00m\]'

# ------------------------------------------------------------------------------
# Simple Shell Supplements

# Miscellaneous.
alias   cp='cp -ai' # Prompt on overwrite, preserve all.
alias    e='echo'

# Extended regex, color, skip binaries, devices, sockets, and dirs.
alias    g='grep --color=auto -EID skip -d skip'
alias   mv='mv -i' # Prompt on overwrite.
alias    m='mv'
alias   md='mkdir'
alias   rm='rm -i' # Always prompt.
alias    r='rm'
#alias  sed='sed -r' # Extended regular expression... but Sed won't permit -rrrrrrrrrr.
alias    s='sed -r'
alias    t='touch'
alias    x='xargs -d\\n ' # Xargs newline delimited + expansion. Use -r to not run on empty input.
# Notes:
# - Copy ex: x cp --parents -t"$dst"
# - TODO: Figure out general case. x -i implies -L1. Use
#   xargs --show-limits --no-run-if-empty < /dev/null?
alias diff='colordiff -d --speed-large-files --suppress-common-lines -W$COLUMNS -y'
export LESS='-ir' # Smart ignore-case + output control chars.

alias timestamp='date +%F-%H-%M-%S-%N'

# Directory listing.
alias  ls='ls -Ap --color=auto' # Alphabetically.
alias   l=ls
alias lex='l -X'                   # By extension.
alias lsi='l -S'                   # By size.
alias lct='l -c'                   # By creation time.
alias lmt='l -t'                   # By mod time.
alias lat='l -u'                   # By access time.
[[ -x /usr/bin/dircolors ]] && eval "$(dircolors -b)" # Enable color support.

alias rsync='rsync -azv --partial-dir=.rsync-partial --partial'

# ------------------------------------------------------------------------------
# Less Simple Shell Supplements

# Directory navigation.
dirs()
{
  local color=3
  builtin dirs -p|while read path
  do
    printf "\033[22;3${color}m%s\033[00m " "$path"

    # Alternate the color after the first path.
    [[ $color -eq 4 ]] && color=5 || color=4;
  done
  echo # Newline.
}
alias d=dirs
c() { cd "$@"; d; }
p() { pushd "$@" > /dev/null; d; } # Change directory.
alias pb='p +1' # Previous directory.
alias pf='p -0' # Next directory.
P() { popd > /dev/null; d; }

#  These don't seem to correct prior to passing to prog.
shopt -s autocd cdable_vars # cdspell dirspell


shopt -s checkjobs
shopt -s checkwinsize


shopt -s hostcomplete

shopt -u huponexit
shopt -s no_empty_cmd_completion

set -b
#set -u

alias abspath='readlink -m'

v() { gvim -p "$@" 2> /dev/null; } # One tab per file.

lynx() { command lynx -accept_all_cookies "$@" 2> /dev/null; }

# Find with a couple defaults.
f()
{
  # The trouble is that -regextype must appear after path but before expression.
  # HACK: "-D debugopts" unsupported and -[HLPO] options assumed to before dirs.
  local a=()
  while [[ -n "$1" ]] && ( [[ ! "${1:0:1}" =~ [-!(),] ]] || [[ "${1:0:2}" =~ -[HLPO] ]] )
  do
    a+=("$1")

    # Eliminate arg from @.
    shift
  done

  find -O3 "${a[@]}" -nowarn -regextype egrep "$@"
}
# Notes:
# - Pruning ex: find rubadub moon \( -path moon/.git -o -path rubadub/.git \) -prune -o \( -type f -o -type l \)
#   Note: still prints pruned dir.

# Find non-binary files.
ftxt() { f "$@"|file --mime-encoding -Nf-|grep -v binary\$|s 's_(.+): .+$_\1_';}

# Clipboard for GUI integration.
cb()
{
  if [[ ! -t 0 ]] # ifne
  then
    xclip -sel c
  else
    xclip -sel c -o
  fi
}

case "$OSTYPE" in
  cygwin)      gui() { explorer "${@:-.}"; } ;;
  linux-gnu|*)
esac

if pgrep Thunar &> /dev/null
then
  gui() { thunar "${@:-.}"; }
elif pgrep nautilus  &> /dev/null
then
  gui() { nautilus "${@:-.}"; }
elif pgrep explorer &> /dev/null
then
  gui() { explorer "${@:-.}"; }
fi

# ssh-keygen -t rsa
ssh_auth()
{
  ssh "$1" '[[ -d .ssh ]] || mkdir .ssh; cat >> .ssh/authorized_keys' < ~/.ssh/id_rsa.pub
}

# ------------------------------------------------------------------------------
# Find Files with Extension

# $1  Optional iregex for file extension.
# ... Optional arguments passed to find
fx()
{
  local rex=
  if [[ $# -gt 0 ]]
  then
    rex="($1)"
    shift
  fi

  f -type f -iregex '^.*'"${rex}"'$' "$@"
}

# C / C++.
alias  fxcpp="fx '\.c|\.cpp'"
alias  fxhpp="fx '\.h|\.hpp'"
alias fxchpp="fx '\.c|\.cpp|\.h|\.hpp'"

# Sometimes I distinguish similar directories with a little nothing file. For
# example, eng_build_verbose.dsc.
alias fxdsc='f -iname "*.dsc" -maxdepth 2'

# ------------------------------------------------------------------------------
# Misc

# Source Android configuration, if present.
[[ -f ~/.bashrc_android ]] && . ~/.bashrc_android

# Source Perforce configuration, if present.
#[[ -f ~/.bashrc_p4 ]] && . ~/.bashrc_p4

# Source QEMU configuration, if present.
[[ -f ~/.bashrc_qemu ]] && . ~/.bashrc_qemu

# Source private configuration, if present.
[[ -f ~/.bashrc_home ]] && . ~/.bashrc_home

# Source work configuration, if present.
[[ -f ~/.bashrc_work ]] && . ~/.bashrc_work

rubadub_root="$(readlink -e "$(dirname "$(readlink -e "$BASH_SOURCE")")/../..")"
init_links()
{
  # TODO: rename function.
  # TODO: make this pretty and maybe isolate these to files?
  dpkg-query -l autossh vim-gnome git-all valgrind xclip build-essential samba \
    smbfs meld openssh-server winbind gmrun gconf-editor nfs-common \
    nfs-kernel-server cachefilesd curl ccache colordiff dos2unix gimp \
    html2text libdevice-usb-perl lynx p7zip screen htop > /dev/null

  [[ -d "$rubadub_root" ]] || return

  # Make some directories.
  [[ -d ~/bin ]] || mkdir ~/bin
  [[ -d ~/opt ]] || mkdir ~/opt

  log-warn 'etc/default/cachefilesd requires manual linking'
  log-warn 'etc/nsswitch.conf requires manual linking (sudo ln -s ~/work/rubadub/etc/nsswitch.conf /etc/nsswitch.conf)'
  log-warn 'etc/udev/rules.d/51-android.rules requires manual linking and a system reboot (sudo ln -s ~/work/rubadub/etc/udev/rules.d/51-android.rules /etc/udev/rules.d/)'
  log-warn 'etc/udev/rules.d/saleae.rules requires manual linking and a system reboot (sudo ln -s ~/work/rubadub/etc/udev/rules.d/saleae.rules /etc/udev/rules.d/)'
  log-warn 'etc/udev/rules.d/ftdi-ft232.rules requires manual linking and a system reboot (sudo ln -s ~/work/rubadub/etc/udev/rules.d/ftdi-ft232.rules /etc/udev/rules.d/)'
  log-warn 'etc/bash_completion.d/android requires manual linking (sudo ln -s ~/work/rubadub/etc/bash_completion.d/android /etc/bash_completion.d/android)'

  # Link home files.
  local target_home="$rubadub_root/home/stephen"
  for f in \
    .android/ddms.cfg \
    .bashrc \
    .bashrc_android \
    .bashrc_p4 \
    .bashrc_qemu \
    bin/4tw \
    bin/chrome \
    bin/snap \
    ,config/touchegg \
    .gconf/apps/metacity \
    .inputrc \
    .profile \
    .screenrc \
    .tmux.conf \
    .vimrc \
    .xmonad \
    opt/eclipse/eclipse.ini \
    opt/signapk \
    opt/apktool \
    work/.metadata/.plugins/org.eclipse.core.runtime/.settings/com.android.ide.eclipse.ddms.prefs \
    .Xmodmap
  do
    ln -s "$target_home/$f" ~/"$(dirname $f)"
  done

  ln -s /usr/bin/google-chrome ~/bin/chrome
  ln -s /usr/bin/gnome-terminal ~/bin/term
  ln -s ~/opt/eclipse/eclipse ~/bin/eclipse
  ln -s ~/opt/logic/Logic ~/bin/logic
  ln -s ~/opt/apache-ant-1.8.4/bin/ant ~/bin/ant
}

up_file()
{
  local f="$1"
  local pwd="$PWD"
  local err=1

  while :
  do
    if [[ -e "$f" ]]
    then
      err=0
      echo "$PWD/$f"
      break
    fi
    [[ "$PWD" != "/" ]] && builtin cd .. || break
  done

  builtin cd "$pwd" && return $err
}

# TODO: use up_file to find existing db.
alias udb='updatedb -l0 -oindex.db -U .'
loc()
{
  locate -ePd"$(up_file index.db)" --regex "${@:-.}"
}

# Power cycles the embedded webcam on my System76 Gazelle Professional laptop,
# which malfunctions regularly. Since it's builtin, I can't cycle the cable
# manually and the bus and port stay the same (2-1.6).
# TODO: how to unbind /sys/bus/usb/drivers/uvcvideo/*?
reset_webcam()
{
  echo '2-1.6'|sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null
  sleep 1
  echo '2-1.6'|sudo tee /sys/bus/usb/drivers/usb/bind  > /dev/null
}
# TODO: reset_usb for when the whole stack tanks.

reset_mouse()
{
  sudo modprobe -r psmouse
  sudo modprobe psmouse
}

# dic() { ! wn "$@" -over; } # Dictionary definition.
# alias gd='aspell dump master|g -i' # Grep mediocre dictionary.

# ------------------------------------------------------------------------------
# Behave Like Windows

# Mimic Explorer style directory navigation. I just really don't like having to
# type distinct commands to change directories. Set a-up, down, right, and left
# to unused keys.
# See also: http://unix.stackexchange.com/questions/9664/how-to-configure-inputrc-so-altup-has-the-effect-of-cd
# Note: these cause a potential mismatch between PS1's \w and actual PWD.
case "$OSTYPE" in
  cygwin)
    # HACK: I'm not sure what program to use to get key codes on Windows. I
    # used Zsh and switched to the rudimentary .safe keymap which just prints
    # control sequences directly on the prompt: bindkey -A .safe main. Try
    # "cat -A" next time.
    bind '"\e\e[A":"\201"'
    bind '"\e\e[B":"\202"'
    bind '"\e\e[C":"\203"'
    bind '"\e\e[D":"\204"'
  ;;
  linux-gnu|*)
    bind '"\e[1;3A":"\201"'
    bind '"\e[1;3B":"\202"'
    bind '"\e[1;3C":"\203"'
    bind '"\e[1;3D":"\204"'
  ;;
esac

# Map unused keys to push parent, pop, next, and previous directory.
bind -x '"\201":..'
bind -x '"\202":P'
bind -x '"\203":pf'
bind -x '"\204":pb'

# c-left, c-right.
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'

# TODO: investigate highlighting / marking for c-s-left, c-s-right, ...
#"\e[1;6C": ...
#"\e[1;6D": ...

# c-del, c-] (c-bs == bs and c-\ is some kind of signal).
bind '"\e[3;5~": kill-word'
bind '"\C-]": backward-kill-word'

# TODO: quote param.
#"\C-xq": "\eb\"\ef\""

# TODO: info rluserman

#TODO: pull in old zsh
alias cls=printf\ '\033\143' # TODO: figure out alternative sln for screen.
# consider reset

# shopt's huponexit is only applicable to login shells. The following covers
# nonlogin shells too.
# trap 'kill -HUP -$$' exit
# trap 'kill -9 -$$' exit

# huponexit is only applicable to login shells, this covers nonlogin too.
# trap_and_hup() { trap 'kill -HUP -$$' exit; } # kill -9
# trap_and_hup
# ps --ppid $$|wc -l -gt 2
# kill -0 $pid

# No way to catch change directory and update term title? Is that Zsh only?
# Assume command names that are directory names are the arguments to cd.
#shopt -s autocd
# Assume that non-directory arguments to cd are variables with directory values.
#shopt -s cdable_vars

# job& spin& fg %job
# $1 pid
spin()
{
  # HACK: I don't know of a way to guarantee the PID or job isn't recycled in
  # Bash.

  local pid=$1
  local rest=${2:-10}
  local cmd="$3"
  while kill -0 $pid 2> /dev/null
  do
    local log="$(last_log)"
    # Periodically update the user.
    echo "$(date +%F-%H-%M) $(wc -l "$log"|s 's_([0-9]+).*_\1_'): $(tail -qn1 "$log")"
    sleep $rest
  done
}

# proc&
# spin&
# wait pid
# Prefix args. "${@/#/$i}"
alias ps='ps -eF fe'
xprop_pid()
{
  # Only print the PID if it's not a dead parent.
  ps $(xprop -f _NET_WM_PID 0c ' = $0\n' _NET_WM_PID|
       sed -r 's_.* = ([0-9]+)_\1_')
}
#pidof
#TODO: declare / readonly / local

alias top=htop

#naut() { nautilus "${@:-.}"; }

# Use "eval $(antialias foo)" to invoke as a command.
antialias()
{
  # "alias" does escaping, so use "type" instead.
  type "$1"|
  sed -r 's%'"$1"' is aliased to `(.*)'\''%\1%'
}

index-pwd()
{
  udb &&
  loc|s 's_\\_\\\\_g; s_"_\\"_g; s_^|$_"_g' >| cscope.files &&
  cscope -eq
}

set -o pipefail

# ------------------------------------------------------------------------------
# Notes
# du -sh, df -h /
# [ ! -t 0 ] # stdin
# f -iregex '.*(ehci|usb).*\.(c|h|inf)'|x sed -ri 's_Portions Copyright_Portions copyright_' # search and replace
# f \( -ipath './edk2/Build' -o -ipath './edk2/Conf' \) -prune -o -iname 'usb*' -print # find exclude
# paste, join, cut
# rsync -vruK audio barnacle:~
# g '\<foo\>' # grep word foo
# ls -Ad --color=always */ .*/ # List directories in PWD.
# TODO python sub: Python regex grep / substituion (without sub, use match?).
# TODO python sub: python -c 'import re, sys; sys.stdout.write(re.sub("/\*(.|\r?\n)*?\*/", "", sys.stdin.read(), 0))'
# strings -a
# pdftotext -layout
# tac: reverse list
# TODO: email
# f -type f -printf '%T@ %p\n'|sort
# TODO: git grep
#cat *|sort|uniq -dc|sort  -r
# increntmal multi-line search working? not very practical so far, not to stop anyway
# dd bs=1M count=1 if=/dev/zero of=1M.bin - gen big fat file
# find duplicates - sort|uniq -d
# 2>&1 stderr to stdout
# &> stderr and stdout to file
# echo {1..5} # print 1 2 3 4 5
# dd if=/dev/dvd of=dvd.iso
# cat -v

# TODO: javac colorize / format warnings and errors.
# sudo lshw -C network; lspci|grep -i eth; lspci -nn|grep Eth
# git, gitk
# info crontab @reboot
# ${BASH_REMATCH[0]} 
# gnu moreutils
# echo -e 'a\nb\nc'|sed -r -e '$a\foo' -e '$a\bar'
# gnu parallel

# TODO: man ps, man bash -> LC_TIME
# echo foo{,,,,,,}
# {1..10} --> 1 2 3 4 5 6 7 8 9 10
# man watch
# echo() { printf "%b\n" "$*"; }
# complete -G
#watch -n 1 --precise 'df -h /'
# TODO: rename files or functions with -?
# vboxmanage list runningvms
# VBoxManage controlvm "<name>" savestate
# unp -u * # unpack (extract, decompress, unzip) archive
# aspell dump master # dump mediocre dictionary
# ctags -R

#sudo chroot ~/work/chroot/lucid/ su - $USER
#last-log -> last-glob-n, keybind to shift tab or something.
#time mm -j -l2.5
alias mtime='date +%s'
# trap 'kill -HUP -$$' exit
#udevadm
#lsb_release --short --codename
#dpkg --print-architecture
#dpkg -l pbuilder or dpkg-query -l pbuilder? wildcard?
# TODO: need an alias for sudo screen /dev/ttuUSB0 115200. TODO: need udev rules too.
# git gui
# nohup
# sudo netstat -lepunt, lsof -i
# find -exec vs xargs. which is fastest
# awk, columns
# getopts

# (Last sorted argument.)
larg()
{
  [[ "${1:0:1}" == "-" ]] &&
  {
    local a=("$@")
    local i=0
    local n=$(($# - 1))

    while [[ $i -lt $n ]] && [[ "${a[$i]}" != "--" ]] && shift
    do
      shift
      let i+=1
    done

    shift
    let i+=1
    a=("${a:0:$i}")
  }

e "${a[@]}"
e "$@"

  printf "%s\n" "$@"|sort "${a[@]}"|tail -n1
}
#--, - arg parsing







# dpkg-query -L udev | grep rules
# tail -f -n 0 /var/log/kern.log
# find /sys ! -type l -iname ttyUSB0
# udevadm info --attribute-walk --path=/sys/class/tty/ttyUSB0
# udevadm monitor --environment --property
# udevadm info -a --attribute-walk --root --name=/dev/ttyUSB0
# screen /dev/ttyUSB0 115200
# diff <(cmd1) <(cmd2)
# apt-cache search jar

# coproc
# IFS= read -r
# LC_COLLATE=C tr A-Z a-z OR tr '[:upper:]' '[:lower:]'
# mapfile
# flock


# Prints Bash environment.
envy()
{
  alias
  declare -p
  declare -f
  hash -l
  trap -p
  bind -psv
  # TODO: go through Bash source to understand what other attributes a shell
  # maintains.

  # TODO: copy / overwrite env.
  # Shopt Options (all stored in read-only variable BASHOPTS?)
  # shopt -p
  # Set Options (all stored in read-only variable SHELLOPTS? Superset of -?)
  # TODO: how to set readonly vars?
  # TODO: PWD
  # env -i bash --norc ... empty shell
}

# readonly
# mapfile
# compgen
# complete
# getopts
# coproc
# compopt
# bind
# help read, read -r, ifs
# #!/usr/bin/env foo params?
# TODO: init link warty
# TODO: PS for pwd on ssh / chroot / name only cd broken.
# TODO: NDK location should link to versioned location.

# From Matt Mead. Need to review.
export LESS_TERMCAP_mb=$'\E[01;31m'      # begin blinking
export LESS_TERMCAP_md=$'\E[01;34m'      # begin bold
export LESS_TERMCAP_me=$'\E[0m'          # end mode
export LESS_TERMCAP_se=$'\E[0m'          # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'   # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'          # end underline
export LESS_TERMCAP_us=$'\E[01;32m'      # begin underline

# cal
# iodine
# truncate - shrink or extend the size of a file to the specified size.
# gnome-specimen - fonts
# at aspell, emacs completion
# google docs list -f audio
# sg3-utils, lsscsi, lspci -- sg_scan, sg_ses, sg_inq /dev/sg5, dmesg, /var/log/syslog
# pwd -P = readlink -m .
#git --no-pager show --pretty="format:" --name-only f38f3c27d6461d8ae5a97f79c6b41bfd27675bf2
#PWD="$(cygpath -w $(pwd))" p4 -x- edit
#cb|xargs -rd\\n git add -n
# pushd "$(git rev-parse --show-toplevel)" && { git status --porcelain|sed -rn 's_ M (.+)_\1_p'|xargs -rd\\n git add -n; popd; }

#rdp() {
#  # HACK: Xmonad doesn't support _NET_WORKAREA.
#  declare -ai wh=( $(xwininfo -root|sed -nr '/^  Width: /N; s_^  Width: ([0-9]+)\n  Height: ([0-9]+)_\1 \2_p') )
#  let wh[1]-=25 # HACK: allow for dock bar.
#  rdesktop -g${wh[0]}x${wh[1]} -z -xm -P "$@"
#}
alias rdp='rdesktop -zKPxm -gworkarea'
#iodine, pkg.sh
#git update-index --assume-unchanged $files
#git ls-files -v|grep '^h'
#git update-index --no-assume-unchanged $files
