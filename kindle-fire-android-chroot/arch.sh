dir=/sdcard/arch/
img=/sdcard/arch.img
                    
if uname -a | grep -q PREEMPT ; then
echo "Changing root to ArchLinux..."
busybox mknod /dev/loop256 b 7 256  
busybox losetup /dev/loop256 "$img"
busybox mount -t ext2 /dev/block/loop256 "$dir"
busybox mount -o bind /dev "$dir/dev"          
busybox mount -o bind /sdcard/ "$dir/media/sdcard/"
echo $HOSTNAME > "$dir/etc/hostname"
busybox chroot "$dir" /bin/bash /init.sh           
echo "Returning from ArchLinux..."      
busybox umount "$dir/media/sdcard/"  
else                                 
echo "Already in ArchLinux environment...?"
busybox chroot "$dir" /bin/bash -i # Enter and start a shell.
fi                                                           
