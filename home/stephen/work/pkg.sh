#!/usr/bin/env bash

# TODO: investigate why "sudo dpkg --set-selections" fails.
pkgs+=(autossh ssh-import-id)
pkgs+=(bash-completion)
pkgs+=(ccache)
pkgs+=(cscope)
pkgs+=(curl wget)
pkgs+=(espeak)
pkgs+=(g++)
pkgs+=(gcc)
pkgs+=(gdb)
pkgs+=(gimp)
pkgs+=(git git-gui gitk github-cli)
pkgs+=(gnome-specimen)
pkgs+=(gparted unetbootin)
pkgs+=(graphviz)
pkgs+=(idle ipython)
pkgs+=(imagemagick)
pkgs+=(iodine)
pkgs+=(iperf)
pkgs+=(lsb-release)
pkgs+=(lshw)
pkgs+=(lsof)
pkgs+=(lynx)
pkgs+=(make)
pkgs+=(meld colordiff)
pkgs+=(moreutils)
pkgs+=(rar unrar p7zip p7zip-rar)
pkgs+=(pbuilder)
pkgs+=(python-beautifulsoup)
pkgs+=(qemu qemu-kvm qemubuilder)
pkgs+=(rsync)
pkgs+=(screen)
pkgs+=(skype)
pkgs+=(sqlitebrowser)
pkgs+=(telnet)
pkgs+=(usbutils)
pkgs+=(vim-gnome)
pkgs+=(virtualbox virtualbox-guest-additions-iso)
pkgs+=(vlc)
pkgs+=(winbind)
pkgs+=(xclip)
pkgs+=(xdotool wmctrl)

# eagle logic
# openscad inkscape blender

sudo apt-get install "${pkgs[@]}"
