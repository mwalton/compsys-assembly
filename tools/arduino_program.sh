#!/bin/bash

# Make sure to install drivers for Mac: http://www.ftdichip.com/Drivers/VCP.htm

# Check proper usage
if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` [file.hex]"
	oldmodes=`stty -g`
	stty -echo
	read -n1 -r -p "Press any key to continue . . ." key
	echo -e "\n"
	stty $oldmodes
	exit 65
fi

# Set the path so we can run MPIDE programs
MPIDE_PATH=/Applications/mpide.app/Contents/Resources/Java
export PATH=$PATH:$MPIDE_PATH/hardware/tools/avr/bin

SERIAL=`ls /dev | grep "tty.usbserial"`
avrdude "-C$MPIDE_PATH/hardware/tools/avr/etc/avrdude.conf" -p32MX320F128H -P\/dev/$SERIAL -cstk500v2 -b115200 -Uflash:w:$1:i

echo "Done! (Were there any errors or warnings?)"
oldmodes=`stty -g`
stty -echo
read -n1 -r -p "Press any key to continue . . ." key
echo -e "\n"
stty $oldmodes
