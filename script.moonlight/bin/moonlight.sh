#!/bin/sh

. /etc/profile

oe_setup_addon script.moonlight

# copy gamecontrollerdb.txt to folder
MOONLIGHT_CONF_DIR="/storage/.config/moonlight"

if [ ! -f "$MOONLIGHT_CONF_DIR/gamecontrollerdb.txt" ]; then
  mkdir -p $MOONLIGHT_CONF_DIR
  cp $ADDON_DIR/etc/gamecontrollerdb.txt $MOONLIGHT_CONF_DIR
fi

while [ 1 ]; do
	if [ -f $ADDON_DIR/start_moonlight.tmp ]; then

		MOONLIGHT_APP=`cat $ADDON_DIR/start_moonlight.tmp`

		rm $ADDON_DIR/start_moonlight.tmp

		MOONLIGHT_ARG="stream"

		if [ "$MOON_PACKETSIZE" != "0" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -packetsize $MOON_PACKETSIZE"
		fi

		if [ "$MOON_BITRATE" != "0" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -bitrate $MOON_BITRATE"
		fi

		if [ "$MOON_RESOLUTION" = "720p" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -720"
		elif [ "$MOON_RESOLUTION" = "1080p" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -1080"
		else
			MOONLIGHT_ARG="$MOONLIGHT_ARG -width $MOON_WIDTH_RESOLUTION -height $MOON_HEIGHT_RESOLUTION"
		fi

		if [ "$MOON_FRAMERATE" = "60" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -fps 60"
		else
			MOONLIGHT_ARG="$MOONLIGHT_ARG -fps 30"
		fi

		if [ "$MOON_SURROUND" = "true" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -surround"
		fi

		if [ "$MOON_LOCALAUDIO" = "true" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -localaudio"
		fi

		if [ "$MOON_NOSOPS" = "true" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -nosops"
		fi

		if [ "$MOON_REMOTE" = "true" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -remote"
		fi

		if [ "$MOON_AUDIO" != "sysdefault" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -audio $MOON_AUDIO"
		fi

		if [ "$MOONLIGHT_APP" != "" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -app \"${MOONLIGHT_APP}\""
		fi

		MOONLIGHT_ARG="$MOONLIGHT_ARG -keydir \"${ADDON_HOME}/keys\""

		if [ "$MOON_SERVER_IP" != "0.0.0.0" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG $MOON_SERVER_IP"
		fi

		if pgrep "kodi.bin" > /dev/null; then
			systemctl stop kodi
		fi

		modprobe snd_bcm2835 || :
		echo "${MOONLIGHT_ARG}" >> ${ADDON_LOG_FILE}
		/bin/sh -c "${ADDON_DIR}/bin/moonlight ${MOONLIGHT_ARG} > ${ADDON_LOG_FILE} 2>&1"
		rmmod snd_bcm2835 || :
		systemctl start kodi
	fi
	sleep 1
done
