# My steps for installing ArchLinux userspace on ChromeOS on external sdcard
YMMV. -- @mike_acton

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

# Open up crosh shell
See: http://www.chromium.org/chromium-os/poking-around-your-chrome-os-device

# Format external sd card as ext3 and name volume 'arch'

    $ sudo umount /dev/mmcblk1p1 
    $ sudo mkfs.ext3 -L arch /dev/mmcblk1p1 

# Reboot

    $ sudo reboot

# Remount sdcard with exec+suid

At this point ChromeOS will automount to /media/removable/arch as noexec and nosuid

* You need to remount it so you can execute stuff on it.
* You need to do this every boot, so it'll be part of the startup script later.


    $ sudo mount -i -o remount,exec,suid /media/removable/arch/

# Download arch linux tarball

    $ cd /media/removable/arch
    $ sudo wget http://archlinuxarm.org/os/ArchLinuxARM-imx6-latest.tar.gz

# Decompress tarball

IMPORTANT: You should NOT get any errors/warnings from tar.

If you do, look for differences from the notes where you might be:

* Not decompressing as root
* Not using a non ext3 filesystem (ext3 isn't strictly required, but fat32 isn't going to work.)


    $ sudo mkdir arch
    $ cd arch
    $ sudo tar xzvf ../ArchLinuxARM-imx6-latest.tar.gz

