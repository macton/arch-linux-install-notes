#!/bin/bash

echo "Booting ArchLinux environment..."
/etc/rc.sysinit # ArchLinux init scripts.
/etc/rc.multi   # Start Deamons.

. /etc/profile # Get your settings
/bin/bash -i   # Start a Shell
