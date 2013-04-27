# Remount sdcard for exec, suid
sudo mount -i -o remount,exec,suid /media/removable/arch/

# Open port 22 for ssh
sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT

# Open port 80 for http
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Open port 8080 for http
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# Simple refcount of mounts to support opening up multiple crosh + ArchLinux tabs.
arch_dev_mnt="/media/removable/arch/arch/dev";
mount_count=$(mount | grep "on ${arch_dev_mnt}" | wc -l)
if [ $mount_count -eq 0 ] ; then
# delete any old locks in case the machine crashed or something...
echo "Devices for ArchLinux not mounted yet. Removing any stale locks first..."
sudo rm /tmp/arch_start.lock.* 2> /dev/null
fi

lock_id=$$
echo $lock_id > /tmp/arch_start.lock.$lock_id
count=$(ls -1 /tmp/arch_start.lock.* 2> /dev/null | wc -l)
if [ $count -eq 1 ]; then
  echo "Mounting devices for ArchLinux..."
  if [ -f /etc/resolv.conf ]; then
  sudo cp /etc/resolv.conf /media/removable/arch/arch/etc/resolv.conf
  fi
  sudo mount -o bind /dev /media/removable/arch/arch/dev/
  sudo mount -t devpts -o rw,nosuid,noexec,relatime,mode=620,gid=5 none /media/removable/arch/arch/dev/pts
  sudo mount -t proc proc /media/removable/arch/arch/proc/
  sudo mount -t sysfs sys /media/removable/arch/arch/sys
  sudo mkdir -p /media/removable/arch/arch/mnt/Downloads
  sudo mount -o bind /home/chronos/user/Downloads /media/removable/arch/arch/mnt/Downloads
else
  echo "Another ArchLinux session open. Devices not re-mounted."
fi

# Comment out this line after you create a user inside Arch
sudo chroot /media/removable/arch/arch /bin/su - root

# Uncomment this line and change <your_user_name> after you create a user inside Arch
# sudo chroot /media/removable/arch/arch /bin/su - <your_user_name>

rm /tmp/arch_start.lock.$lock_id
count=$(ls -1 /tmp/arch_start.lock.* 2> /dev/null | wc -l)
if [ $count -eq 0 ]; then
  echo "Unmounting devices for ArchLinux..."
  sudo umount /media/removable/arch/arch/sys/
  sudo umount /media/removable/arch/arch/proc/
  sudo umount /media/removable/arch/arch/dev/pts/
  sudo umount /media/removable/arch/arch/dev/
  sudo umount /media/removable/arch/arch/mnt/Downloads
else
  echo "Another ArchLinux session open. Not unmounting devices."
fi