#!/bin/sh

. /etc/profile

oe_setup_addon script.moonlight

export LD_LIBRARY_PATH=$ADDON_DIR/libs:$LD_LIBRARY_PATH

chmod a+x $ADDON_DIR/bin/*

while [ 1 ]
do
	if [ -f $ADDON_DIR/start_moonlight.tmp ]
	then
		oe_setup_addon script.moonlight
		
		MOONLIGHT_APP=`cat $ADDON_DIR/start_moonlight.tmp`
		
		rm $ADDON_DIR/start_moonlight.tmp
		
		MOONLIGHT_ARG=""

		if [ "$MOON_PACKETSIZE" != "0" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -packetsize $MOON_PACKETSIZE"
		fi

		if [ "$MOON_BITRATE" != "0" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -bitrate $MOON_BITRATE"
		fi

		if [ "$MOON_RESOLUTION" = "720p" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -720"
		else
			MOONLIGHT_ARG="$MOONLIGHT_ARG -1080"
		fi

		if [ "$MOON_FRAMERATE" = "60" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -60fps"
		else
			MOONLIGHT_ARG="$MOONLIGHT_ARG -30fps"
		fi

		if [ "$MOON_FORCEHW" = "true" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -forcehw"
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

		if [ "$MOON_MAPPING" != "" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -mapping \"${ADDON_DIR}/bin/mappings/${MOON_MAPPING}.conf\""
		fi
		
		if [ "$MOONLIGHT_APP" != "" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG -app \"${MOONLIGHT_APP}\""
		fi
		
		MOONLIGHT_ARG="$MOONLIGHT_ARG -keydir \"${ADDON_HOME}/keys\""

		if [ "$MOON_SERVER_IP" != "0.0.0.0" ]; then
			MOONLIGHT_ARG="$MOONLIGHT_ARG $MOON_SERVER_IP"
		fi
		
		if pgrep "kodi.bin" > /dev/null
		then
			systemctl stop kodi
		fi
		
		modprobe snd_bcm2835
		echo $MOONLIGHT_ARG >> $ADDON_LOG_FILE
		/bin/sh -c "${ADDON_DIR}/bin/moonlight ${MOONLIGHT_ARG} stream >> ${ADDON_LOG_FILE} 2>&1"
		rmmod snd_bcm2835
		systemctl start kodi
	fi
	
	sleep 1
done
