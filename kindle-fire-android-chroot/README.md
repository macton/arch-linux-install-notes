# Install
My steps for installing ArchLinux userspace on Android 4.2.1 running on Kindle Fire
YMMV. [@mike_acton](http://www.twitter.com/mike_acton)

## Presumably Android 4.2.1 is already installed. If not

* See: http://liliputing.com/2012/12/install-android-4-2-on-the-original-amazon-kindle-fire.html
* Updated links: http://forum.xda-developers.com/showthread.php?t=1859851

I'm using: cm-10.1-20130108-UNOFFICIAL-otter.zip and gapps-jb-20121212-signed.zip

## Reference:

* http://devwithopinions.blogspot.ca/2012/06/welcome-back-gnu-my-revenge-on-android.html
* http://lrvick.net/blog/arch_linux_terminals_in_android/
* http://solvitor.com/2013/01/02/lamp-stack-on-an-arm-chromebook/
* https://gist.github.com/2759578
* http://elinux.org/ArchLinux_Install_Guide

## Notes:

* Machine has root
* Busybox is installed via Android app store


## Open shell

    su
    bash

## Specify irectories, files...

    img=/sdcard/linux.img
    dir=/sdcard/linux/
    url=http://archlinuxarm.org/os/ArchLinuxARM-omap-smp-latest.tar.gz 
    tarball=ArchLinuxARM-omap-smp-latest.tar.gz

## Install files...

    cd /sdcard
    mkdir "$dir"
    dd if=/dev/zero of="$img" bs=1024 count=1048576 # Wait a long time...
    mkfs.ext2 -F "$img" 
    mknod /dev/loop256 b 7 256
    losetup /dev/loop256 "$img" 
    mount -t ext2 /dev/loop256 "$dir"
    cd "$dir"
    wget "$url"
    tar xzfv "$tarball"

## Mount available directories...

    mount -o bind /dev/ "$dir/dev"
    mkdir "$dir/media/sdcard"
    mount -o bind /sdcard "$dir/media/sdcard"

## Setup

    chroot "$dir" /bin/bash
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "export TERM=xterm" >> /etc/profile
    echo "export HOME=/root" >> /etc/profile
    /etc/rc.sysinit
    exit

## Create startup script (~/arch.sh)

    cd ~
    wget https://raw.github.com/macton/arch-linux-install-notes/master/kindle-fire/arch.sh --no-check-certificate

## Create init script ($dir/init.sh)

    cd $dir
    wget https://raw.github.com/macton/arch-linux-install-notes/master/kindle-fire/init.sh --no-check-certificate

## Go for Linux

    bash ~/arch.sh

## Cleanup rc.sysinit

If you have some errors and problems after startup (e.g. the Android GUI isn't responding)
Comment out the following lines in /etc/rc.sysinit (remember this is after you're in ArchLinux)

    # log all console messages
    # bootlogd -p /run/bootlogd.pid

    # Start/trigger udev, load MODULES, and settle udev
    # udevd_modprobe sysinit

    # this must be done after udev has loaded the KMS modules
    # status 'Configuring virtual consoles' /usr/lib/systemd/systemd-vconsole-setup

    # stat_busy "Saving dmesg log"
    # if [[ -e /proc/sys/kernel/dmesg_restrict ]] &&
    # (( $(< /proc/sys/kernel/dmesg_restrict) == 1 )); then
    # install -Tm 0600 <( dmesg ) /var/log/dmesg.log
    # else         
    # install -Tm 0644 <( dmesg ) /var/log/dmesg.log
    # fi           
    # (( $? == 0 )) && stat_done || stat_fail

## Reboot android

You can reboot android from the command line with "reboot"

## Make a place to put removed startup scripts

    mkdir /etc/rc.d.removed

## Remove SysLog-NG

If you're getting errors starting up SysLog-NG, you can just remove it
(If someone spends a few minutes to just fix it instead, I'd appreciate a note to update this.)

    mv /etc/rc.d/syslog-ng rc.d.removed/

## Remove network init

If you're getting a warning "Network is already running. Try 'network restart'" remove the startup:

    mv /etc/rc.d/network rc.d.removed/

## Remove crond startup

I also removed the crond daemon startup:

    mv /etc/rc.d/crond rc.d.removed/

## Get some common stuff

    pacman -Syu
    pacman -S gcc
    pacman -S git
    pacman -S sudo
    pacman -S make

## edit /etc/sudoers file

find and uncomment the line below...

    %wheel ALL=(ALL) ALL

## Add user. 

Follow prompts. Add "wheel" to additional groups when prompted.

    adduser

## Allow user to use network interface

    groupadd -g 3004 inet
    usermod -g inet <user>

## Login as user

    su <user>

## Test gcc

Make a quick helloworld.c, compile and run to make sure gcc's working okay.

## Setup github

* Config ssh keys for github: https://help.github.com/articles/generating-ssh-keys
* Config git: http://git-scm.com/book/en/Customizing-Git-Git-Configuration 
* git clone something to make sure that works.
* git push something to make sure that works.

## Automatically login as user. 

edit init.sh
before this line:

    /bin/bash -i   # Start a Shell

Add:

    su <user>

## Install .bashrc; This is mine. Put yours if you have one.

    cd ~
    wget https://raw.github.com/macton/arch-linux-install-notes/master/common/.bashrc --no-check-certificate


## That's it! Whew!

Done.

## Bonus: Running an HTTP server

In case you're interested, I'm using mongoose to run a simple, local http server for various dev testing stuff.
Builds and runs out of the box in this environment. https://code.google.com/p/mongoose/
