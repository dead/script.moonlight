#! /bin/sh
cpath=`pwd`
export LD_LIBRARY_PATH=$cpath/libs:$LD_LIBRARY_PATH

if pgrep "kodi.bin" > /dev/null
then
	systemctl stop kodi
fi

modprobe snd_bcm2835
bin/moonlight $@
rmmod snd_bcm2835
systemctl start kodi
