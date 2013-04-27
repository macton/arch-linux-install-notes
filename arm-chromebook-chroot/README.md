# PART 1: Install

My steps for installing ArchLinux userspace on ChromeOS on external sdcard
YMMV. -- [@mike_acton](http://www.twitter.com/mike_acton)

I am using a 32GB Lexar sdcard. I don't recommend any smaller than 32GB if you're going to 
be building multiple gcc toolchains. (If you're using pre-built toolchains, something smaller
will work fine. 4GB or 8GB is probably fine for most uses.) 

Reference:

* http://devwithopinions.blogspot.ca/2012/06/welcome-back-gnu-my-revenge-on-android.html
* http://lrvick.net/blog/arch_linux_terminals_in_android/
* http://solvitor.com/2013/01/02/lamp-stack-on-an-arm-chromebook/
* https://gist.github.com/2759578
* http://elinux.org/ArchLinux_Install_Guide
* https://github.com/dnschneid/crouton
* https://docs.google.com/document/d/1IVABFl9TJMFPqoE_c0vWP7YhA_mXdpThG2UIZsYOCgU/edit

## Open up crosh shell
See: http://www.chromium.org/chromium-os/poking-around-your-chrome-os-device

## Format external sd card as ext3 and name volume 'arch'

    $ sudo umount /dev/mmcblk1p1 
    $ sudo mkfs.ext3 -L arch /dev/mmcblk1p1 

## Reboot

    $ sudo reboot

## Remount sdcard with exec+suid

At this point ChromeOS will automount to /media/removable/arch as noexec and nosuid

* You need to remount it so you can execute stuff on it.
* You need to do this every boot, so it'll be part of the startup script later.

Mount card:

    $ sudo mount -i -o remount,exec,suid /media/removable/arch/

## Download arch linux tarball

    $ cd /media/removable/arch
    $ sudo wget http://archlinuxarm.org/os/ArchLinuxARM-imx6-latest.tar.gz

## Decompress tarball

IMPORTANT: You should NOT get any errors/warnings from tar.

If you do, look for differences from the notes where you might be:

* Not decompressing as root
* Not using a non ext3 filesystem (ext3 isn't strictly required, but fat32 isn't going to work.)

Decompress:

    $ sudo mkdir arch
    $ cd arch
    $ sudo tar xzvf ../ArchLinuxARM-imx6-latest.tar.gz

# PART 2!

Now that you have arch linux installed. You need to set it up properly.

## Get chroot script.

Download and install arch_start.sh

    $ cd /media/removable/arch/
    $ wget https://raw.github.com/macton/arch-linux-install-notes/master/arm-chromebook-chroot/arch_start.sh --no-check-certificate

## Go for Linux!

    $ /bin/sh arch_start.sh

## Setup pacman

pacman is the Arch package manager. (No surprise.) More info? https://wiki.archlinux.org/index.php/Pacman_-_An_Introduction

Note: the pacman-key step can take a while.

    $ pacman -Sy pacman
    $ pacman-key --init
    $ pacman -Syu

## Clean up some warnings

You may notice some warnings that look like this when running pacman

    warning: could not get filesystem information for /mnt/stateful_partition: No such file or directory
    warning: could not get filesystem information for /mnt/stateful_partition/encrypted: No such file or directory
    warning: could not get filesystem information for /home/chronos: No such file or directory
    warning: could not get filesystem information for /var/lock: No such file or directory
    warning: could not get filesystem information for /sys/fs/cgroup/cpu: No such file or directory

Those warnings are safe to ingore and don't indicate a real problem.

* To disable them, edit /etc/pacman.conf
* Comment out the line that begins with "CheckSpace"

## Add sudo and adduser packages

    $ pacman -S sudo adduser

## Allow wheel group to sudo

edit /etc/sudoers file
find and uncomment the line below...

    %wheel ALL=(ALL) ALL
 
## Add a user

Follow the prompts. 
For "additional groups" I use: audio floppy video power lp scanner wheel

    $ adduser


## Change to your user and home directory

    $ su <user>
    $ cd ~

## Check wget

Make sure you have normal network services as user

    $ wget http://www.w3.org/History/1989/proposal.rtf

** ONLY DO THE FOLLOWING IF WGET FAILS **
Note: may only be a problem on some older Arch Linux images.

    $ sudo groupadd -g 3004 inet
    $ sudo usermod -g inet <user>

## Check ping

Make sure you can ping as user

    $ ping -c 3 google.com

** ONLY DO THE FOLLOWING IF PING FAILS **

* Note: may only be a problem on some older Arch Linux images.
* Also: This can also be symptomatic of nosuid set on the device. (did you remount the sdcard?)

Fix ping:

    $ sudo chmod u+s /usr/bin/ping
    $ sudo setcap cap_net_raw=ep /usr/bin/ping

## Install packages for general development. 

Your needs may vary. I need development tools and tools to re-build the gcc toolchain. 
It's safe to get all this stuff though, even if you don't use all of it.

    $ sudo pacman -S binutils elfutils gcc git gperf python2 subversion unzip zip base-devel

## Check that you can build and run a native executable.

Make a quick hello world program, compile and run to make sure gcc's working okay.

    $ echo -e '#include <stdio.h>\nmain(){printf("hello world\\n");}' | gcc -o hello -xc -
    $ ./hello

## Set up git/github.

If you're reading this, you probably use github.

Config ssh keys for github
See: https://help.github.com/articles/generating-ssh-keys

    $ ssh-keygen -t rsa -C "your_email@youremail.com"
    $ cat ~/.ssh/id_rsa.pub

Copy and paste to https://github.com/settings/ssh

Config git
See: http://git-scm.com/book/en/Customizing-Git-Git-Configuration 

    $ git config --global user.name "John Doe"
    $ git config --global user.email johndoe@example.com
    $ git config --global push.default matching

## Test git
git clone something to make sure that works.

    $ cd ~
    $ git clone git@github.com:macton/arch-linux-install-notes.git

git push something to make sure that works.
... I'm sure you have your own repo for this. But I recommend you do test it now.

## Install user .bashrc

This is mine. There's nothing special about the setup here. If you already have one you like, use yours 
without any modification.

    $ cd ~
    $ wget https://raw.github.com/macton/arch-linux-install-notes/master/common/.bashrc --no-check-certificate

## Install crosh/arch startup script

This will give you the option to either go to a crosh or arch bash shell when you open a crosh 
tab and type 'shell'

Go back to root in arch

    $ exit

Go back to chronos in crosh

    $ exit

Install .bashrc which gives startup choice. (If you have a custom .bashrc, you will want to modify it instead.)

    $ cd ~
    $ wget https://raw.github.com/macton/arch-linux-install-notes/master/arm-chromebook-chroot/.bashrc --no-check-certificate

## Set auto-login as user

Edit /media/removable/arch/arch_start.sh

Look for this line:

    sudo chroot /media/removable/arch/arch /bin/su - root

Change root to your user name and save.

## Test it!

Exit back to crosh menu

    $ exit

Select shell as usual. 

You should be presented with an option like this:

    bash prompt: Press ESC to continue to ChromeOS (default). Any other key for Arch Linux userspace

Make sure to test both.

## You're done! Read some tips!

    $ curl https://raw.github.com/macton/arch-linux-install-notes/master/common/arch_tips.txt 
    $ curl https://gist.github.com/macton/4641761/raw/cc15ab1bdda40d6a3be6adf0f369868263ec81ec/chromebook_tips.txt

* Thanks @pkeir!
* Thanks @shaunhey!
* Thanks @gcto!
