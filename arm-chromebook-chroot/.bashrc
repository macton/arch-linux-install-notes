# .bashrc for chromeos /bin/bash to boot to ArchLinux installed on sdcard
# This should go in /home/chronos/user/.bashrc (ChromeOS)

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
  # Shell is non-interactive.  Be done now!
  return
fi

#
# Optional launch into ArchLinux...
#

_key()
{
  local kp
  ESC=$'\e'
  _KEY=
  read -d '' -sn1 _KEY
  case $_KEY in
    "$ESC")
        while read -d '' -sn1 -t1 kp
        do
          _KEY=$_KEY$kp
          case $kp in
            [a-zA-NP-Z~]) break;;
          esac
        done
    ;;
  esac
  printf -v "${1:-_KEY}" "%s" "$_KEY"
}

echo "bash prompt: Press ESC to continue to ChromeOS (default). Any other key for Arch Linux userspace."

_key x

case $x in
  $'\e[11~' | $'\e[OP') key=F1 ;;
  $'\e[12~' | $'\e[OQ') key=F2 ;;
  $'\e[13~' | $'\e[OR') key=F3 ;;
  $'\e[14~' | $'\e[OS') key=F4 ;;
  $'\e[15~') key=F5 ;;
  $'\e[16~') key=F6 ;;
  $'\e[17~') key=F7 ;;
  $'\e[18~') key=F8 ;;
  $'\e[19~') key=F9 ;;
  $'\e[20~') key=F10 ;;
  $'\e[21~') key=F11 ;;
  $'\e[22~') key=F12 ;;
  $'\e') key=ESC ;;
  $'\e[A' ) key=UP ;;
  $'\e[B' ) key=DOWN ;;
  $'\e[C' ) key=RIGHT ;;
  $'\e[D' ) key=LEFT ;;
  ?) key=$x ;;
  *) key=??? ;;
esac

if [ "$key" == "ESC" ]; then
  echo "Starting ChromeOS root..."
else
  if [ -e /media/removable/arch/arch_start.sh ]; then
    echo "Changing root to Arch Linux..."
    /bin/sh /media/removable/arch/arch_start.sh
  else
    echo "ArchLinux not found. Is /media/removable/arch mounted?"
  fi
fi

# Go home, user local settings (either environment)
cd ~
export PATH=$PATH:~/bin
