# Create SD card image and boot

Link under "Installation"
http://archlinuxarm.org/platforms/armv6/raspberry-pi

# Configure network
I use a static IP address.
https://wiki.archlinux.org/index.php/Netcfg

  - delete any eth0 startup from /etc/systemd/system/...
  - cp /etc/netctl/examples/ethernet-static /etc/netctl/eth0
  - vi /etc/netctl/eth0
   
# Resize sdcard partition
http://archlinuxarm.org/forum/viewtopic.php?f=31&t=3119#p18160
    
# Make swap file
https://wiki.archlinux.org/index.php/Swap#Swap_file
     
# Change timezone

    $ vi /etc/timezone
Change to: America/Los_Angeles
      
# Change hostname

    $ hostnamectl set-hostname myhostname

* Hostname generator: http://computernamer.com/
* Hostname generator: http://online-generator.com/name-generator/product-name-generator.php
       
# Update 

    $ pacman -Sy pacman
    $ pacman-key --init # TAKES A LONG TIME! Also recommended: Do some random stuff on machine while running.
    $ pacman -Syu
    $ pacman -S sudo adduser
        
# Update sudo
edit /etc/sudoers file
find and uncomment the line below...

    %wheel ALL=(ALL) ALL
         
# Add user
Add user. Follow prompts. 
For additional groups: audio floppy video power lp scanner wheel

    $ adduser
    $ su <user>
          
# Install packages for general development. 
Also, BTW most of these packages are needed to compile the gcc toolchain. (If you happen to want to do that...)

    $ sudo pacman -S binutils elfutils gcc git gperf python2 subversion unzip zip base-devel
           
# Test gcc
Make a quick hello world program, compile and run to make sure gcc's working okay.

    $ echo -e '#include <stdio.h>\nmain(){printf("hello world\\n");}' | gcc -o hello -xc -
    $ ./hello
            
# Fix the time
https://wiki.archlinux.org/index.php/NTPd

Install ntp (uninstall openntp if installed)

    $ sudo pacman -S ntp
              
Create /etc/systemd/system/ntp-once.service

    [Unit]
    Description=Network Time Service (once)
    After=network.target nss-lookup.target 
    
    [Service]
    Type=oneshot
    ExecStart=/usr/bin/ntpd -q -g -u ntp:ntp ; /sbin/hwclock -w
    
    [Install]
    WantedBy=multi-user.target
                 
Enable ntp

    $ sudo systemctl enable ntpd
                  
Get updated time
Note: There were some zombie ntpds I had to kill to get the time to update.

    $ sudo ntpd -qg
                   
# Set up git/github.
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
                         
# Test git
git clone something to make sure that works.
                          
    $ git clone https://gist.github.com/4632677.git
                           
git push something to make sure that works.
... I'm sure you have your own repo for this. But I recommend you do test it now.
                            
# Test sdcard speed
http://marks-space.com/2012/12/27/how-to-test-the-sd-card-speed-on-your-raspberry-pi/
                             
    $ sudo pacman -S hdparm
    $ hdparm hdparm -tT /dev/mmcblk0
                              
e.g.
    /dev/mmcblk0:
    Timing cached reads:         292 MB in  2.01 seconds = 145.14 MB/sec
    Timing buffered disk reads:   56 MB in  3.10 seconds =  18.07 MB/sec

# Get .bashrc

    $ cd ~
    $ wget https://raw.github.com/macton/arch-linux-install-notes/master/common/.bashrc --no-check-certificate

# Build a raspberri pi sample
Copy to home

    $ cd ~
    $ cp -R /opt/vc/src/hello_pi .
    $ cd hello_pi/hello_triangle
    $ make
                                  
Should see spinning textured cube

    $ ./hello_triangle.bin
